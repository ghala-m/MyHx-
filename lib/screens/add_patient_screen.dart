import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/database_service.dart'; // <-- استيراد جديد
import 'medical_history_screen.dart'; // <-- استيراد جديد

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _selectedDate;
  String _selectedGender = 'Male';
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final DatabaseService _dbService = DatabaseService(); // <-- إنشاء نسخة من الخدمة

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final theme = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // --- *** الدالة المعدلة بالكامل *** ---
  Future<void> _handleNextStep() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() { _isLoading = true; });

      final age = DateTime.now().year - _selectedDate!.year;
      
      final newPatient = Patient(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // استخدام الوقت الحالي كـ ID فريد
        name: _nameController.text.trim(),
        age: age,
        gender: _selectedGender,
        phoneNumber: _phoneController.text.trim(),
        dateOfBirth: _selectedDate!,
        createdAt: DateTime.now(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      try {
        // --- *** الحفظ في Firestore *** ---
        await _dbService.addPatient(newPatient);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Patient ${newPatient.name} saved. Proceeding to medical history.'),
              backgroundColor: Colors.green,
            ),
          );
          // الانتقال إلى شاشة التاريخ الطبي مع تمرير المريض الجديد
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MedicalHistoryScreen(patient: newPatient)),
          );
        }
      } catch (e) {
        // في حال حدوث خطأ أثناء الحفظ
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving patient: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select date of birth to continue.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- التصحيح: استخدام ألوان من الثيم الحالي ---
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // تصميم حقول الإدخال ليكون متناسقاً
    final inputDecorationTheme = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      filled: true,
      fillColor: colors.surface,
      prefixIconColor: colors.primary,
    );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Add New Patient', style: TextStyle(color: colors.onBackground)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ... (بقية الواجهة تستخدم الألوان الجديدة)
                TextFormField(
                  controller: _nameController,
                  decoration: inputDecorationTheme.copyWith(
                    labelText: 'Full Name *',
                    prefixIcon: const Icon(Icons.person_outlined),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter patient\'s full name' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(12),
                      color: colors.surface,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: colors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedDate == null ? 'Select Date of Birth *' : 'Date of Birth: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: TextStyle(fontSize: 16, color: _selectedDate == null ? colors.onSurface.withOpacity(0.6) : colors.onSurface),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: colors.onSurface.withOpacity(0.6)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: inputDecorationTheme.copyWith(
                    labelText: 'Gender *',
                    prefixIcon: const Icon(Icons.wc),
                  ),
                  items: _genders.map((g) => DropdownMenuItem<String>(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setState(() { _selectedGender = v!; }),
                ),
                
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: inputDecorationTheme.copyWith(
                    labelText: 'Additional Notes (Optional)',
                    prefixIcon: const Icon(Icons.note_outlined),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Go to Medical History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: TextStyle(color: colors.onSurface.withOpacity(0.6), fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
