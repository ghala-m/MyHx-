import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/patient.dart';
import '../utils/colors.dart'; // نحتاجه لبعض الألوان الثابتة
import 'patient_record_screen.dart';
import 'add_patient_screen.dart';
import 'settings_screen.dart';
import 'reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final DatabaseService _dbService = DatabaseService();

  late Future<List<Patient>> _patientsFuture;
  List<Patient> _allPatients = [];
  List<Patient> _foundPatients = [];
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshPatients();
  }

  void _refreshPatients() {
    _patientsFuture = _dbService.getPatients();
    _patientsFuture.then((patients) {
      if (mounted) { // التأكد من أن الويدجت لا يزال في الشجرة
        setState(() {
          _allPatients = patients;
          _foundPatients = patients;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _runFilter(String enteredKeyword) {
    List<Patient> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allPatients;
    } else {
      results = _allPatients.where((patient) => patient.name.toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
    }
    setState(() { _foundPatients = results; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: FutureBuilder<List<Patient>>(
          future: _patientsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }
            
            final List<Widget> widgetOptions = <Widget>[_buildDashboard(), _buildAllPatients()];
            return widgetOptions.elementAt(_selectedIndex);
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
        elevation: 8.0,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', index: 0),
              _buildAddPatientButton(),
              _buildNavItem(icon: Icons.people_outline, label: 'All Patients', index: 1),
            ],
          ),
        ),
      ),
    );
  }

  // --- كل دوال بناء الواجهة تم نقلها إلى هنا (داخل الكلاس) ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_add_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No Patients Found', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add your first patient to get started.', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Patient'),
            onPressed: () async {
              final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddPatientScreen()));
              if (result != null) {
                _refreshPatients();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAllPatients() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _runFilter,
            decoration: const InputDecoration(hintText: 'Search by patient name...'),
          ),
        ),
        Expanded(
          child: _foundPatients.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _foundPatients.length,
                  itemBuilder: (context, index) => _buildPatientCard(_foundPatients[index]),
                )
              : const Center(child: Text('No matching patients found.')),
        ),
      ],
    );
  }

  Widget _buildPatientCard(Patient patient) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => PatientRecordScreen(patient: patient))),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(patient.name.split(' ').map((n) => n[0]).take(2).join(), style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 4),
                    Text('${patient.age} years • ${patient.gender}', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                    if (patient.symptoms.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(patient.symptoms.join(', '), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              Text(
                _formatTime(patient.createdAt),
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final bool isSelected = _selectedIndex == index;
    final color = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    return InkWell(
      onTap: () => setState(() { _selectedIndex = index; }),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildAddPatientButton() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddPatientScreen()));
        if (result != null) {
          _refreshPatients();
        }
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [AppColors.primaryCyan, AppColors.primaryTeal], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: AppColors.primaryTeal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatisticsCards(),
          const SizedBox(height: 24),
          _buildRecentPatients(),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good Morning, Dr. Smith', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground)),
              const SizedBox(height: 4),
              Text('Internal Medicine • 5th Year', style: TextStyle(fontSize: 16, color: theme.colorScheme.onBackground.withOpacity(0.7))),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen())),
          icon: Icon(Icons.account_circle, size: 32, color: theme.colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Today\'s Patients', _allPatients.length.toString(), Icons.people, AppColors.primaryCyan)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Completed', '0', Icons.check_circle, AppColors.success)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Urgent Cases', '0', Icons.warning, AppColors.warning)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildRecentPatients() {
    final theme = Theme.of(context);
    // عرض أول 3 مرضى فقط
    final recent = _allPatients.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Recent Patients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground)),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() { _selectedIndex = 1; }),
              child: Text('View All', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recent.length,
          itemBuilder: (context, index) => _buildPatientCard(recent[index]),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _buildActionCard('Add New Patient', Icons.person_add, Theme.of(context).colorScheme.primary, () async {
          final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddPatientScreen()));
          if (result != null) { _refreshPatients(); }
        })),
        const SizedBox(width: 12),
        Expanded(child: _buildActionCard('View Reports', Icons.analytics, Colors.blue, () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReportsScreen())))),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
