import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/database_service.dart';
import 'medical_history_screen.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _wardController = TextEditingController();
  final _roomController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _selectedDate;
  String _selectedGender = 'Male';
  String? _selectedDepartment;
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _departments = ['Pediatrics', 'Internal Medicine', 'Surgery', 'Cardiology', 'General'];

  final DatabaseService _dbService = DatabaseService();

  @override
  void dispose() {
    _nameController.dispose();
    _wardController.dispose();
    _roomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleNextStep() async {
    if (!_formKey.currentState!.validate() || _selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields, including department.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final age = _selectedDate != null ? DateTime.now().year - _selectedDate!.year : 0;
    
    // --- *** هذا هو الجزء الذي كان يسبب المشكلة وتم تصحيحه نهائياً *** ---
    final newPatient = Patient(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      age: age,
      gender: _selectedGender,
      dateOfBirth: _selectedDate ?? DateTime.now(),
      createdAt: DateTime.now(),
      notes: _notesController.text.trim(),
      
      // --- تمرير الحقول الإجبارية ---
      department: _selectedDepartment!,
      wardNumber: _wardController.text.trim(),
      roomNumber: _roomController.text.trim(),
    );

    try {
      await _dbService.addPatient(newPatient);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MedicalHistoryScreen(patient: newPatient, department: _selectedDepartment!)),
        );
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Patient')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name *'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(context: context, initialDate: DateTime(2000), firstDate: DateTime(1900), lastDate: DateTime.now());
                          if (date != null) setState(() => _selectedDate = date);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Date of Birth'),
                          child: Text(_selectedDate != null ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' : 'Select Date'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(labelText: 'Gender'),
                        items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                        onChanged: (v) => setState(() => _selectedGender = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _wardController,
                        decoration: const InputDecoration(labelText: 'Ward Number *'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _roomController,
                        decoration: const InputDecoration(labelText: 'Room Number *'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Additional Notes'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Text('Select Department *', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _departments.map((department) {
                    final isSelected = _selectedDepartment == department;
                    return ChoiceChip(
                      label: Text(department),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedDepartment = department);
                        }
                      },
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                      labelStyle: TextStyle(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleNextStep,
                  icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.arrow_forward),
                  label: _isLoading ? const CircularProgressIndicator() : const Text('Go to Medical History'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
