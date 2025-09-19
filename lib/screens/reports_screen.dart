import 'package:flutter/material.dart';
import '../models/patient.dart'; // سنحتاج هذا النموذج
import 'patient_record_screen.dart'; // الشاشة التي سننتقل إليها

// بيانات تجريبية للتقارير، لاحقاً ستأتي من Google Sheets
final List<Map<String, dynamic>> _sampleReports = [
  {
    'patient': Patient(id: '1',
     name: 'John Smith',
      age: 35,
       gender: 'Male', 
       phoneNumber: '', 
       dateOfBirth: DateTime(1988), 
       createdAt: DateTime.now(), 
  ),
    'report_date': DateTime.now().subtract(const Duration(days: 1)),
  },
  {
    'patient': Patient(id: '2', name: 'Sarah Johnson', age: 28, gender: 'Female', phoneNumber: '', dateOfBirth: DateTime(1995), createdAt: DateTime.now(),),
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
                            // في التطبيق الحقيقي، سنمرر التاريخ الطبي والتحليل من Google Sheets
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
