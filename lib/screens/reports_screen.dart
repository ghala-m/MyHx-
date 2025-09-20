import 'package:flutter/material.dart';
import '../models/patient.dart';
import 'patient_record_screen.dart';

// --- *** البيانات التجريبية المصححة بالكامل لتشمل الحقول المطلوبة *** ---
final List<Map<String, dynamic>> _sampleReports = [
  {
    'patient': Patient(
      id: '1',
      name: 'John Smith',
      age: 35,
      gender: 'Male',
      dateOfBirth: DateTime(1988),
      createdAt: DateTime.now(),
      department: 'Cardiology',
      wardNumber: 'A3',
      roomNumber: '101',
    ),
    'report_date': DateTime.now().subtract(const Duration(days: 1)),
  },
  {
    'patient': Patient(
      id: '2',
      name: 'Sarah Johnson',
      age: 28,
      gender: 'Female',
      dateOfBirth: DateTime(1995),
      createdAt: DateTime.now(),
      department: 'Pediatrics',
      wardNumber: 'B1',
      roomNumber: '205',
    ),
    'report_date': DateTime.now().subtract(const Duration(days: 3)),
  },
];

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('All Reports'),
      ),
      body: _sampleReports.isEmpty
          ? const Center(child: Text('No reports found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _sampleReports.length,
              itemBuilder: (context, index) {
                final report = _sampleReports[index];
                final Patient patient = report['patient'];
                final DateTime reportDate = report['report_date'];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(patient.name.substring(0, 1)),
                    ),
                    title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Report generated on: ${reportDate.day}/${reportDate.month}/${reportDate.year}'),
                    trailing: Icon(Icons.arrow_forward_ios, color: colors.onSurface.withOpacity(0.5)),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PatientRecordScreen(
                            patient: patient,
                            medicalHistory: const {}, 
                            aiAnalysis: const {},
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
