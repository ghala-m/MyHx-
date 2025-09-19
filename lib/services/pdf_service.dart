import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/patient.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  Future<File> generatePatientReport({
    required Patient patient,
    required List<Map<String, dynamic>> medicalHistory,
    Map<String, dynamic>? aiAnalysis,
  }) async {
    final pdf = pw.Document();

    // Add pages to PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader(patient),
            pw.SizedBox(height: 20),
            
            // Patient Information
            _buildPatientInfo(patient),
            pw.SizedBox(height: 20),
            
            // Medical History
            _buildMedicalHistory(medicalHistory),
            pw.SizedBox(height: 20),
            
            // AI Analysis (if available)
            if (aiAnalysis != null) ...[
              _buildAIAnalysis(aiAnalysis),
              pw.SizedBox(height: 20),
            ],
            
            // Footer
            _buildFooter(),
          ];
        },
      ),
    );

    // Save PDF to device
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/patient_report_${patient.id}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  pw.Widget _buildHeader(Patient patient) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#00CFE4'),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColor.fromHex('#00CFE4'), width: 1),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'myhx- Medical Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#000E52'),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Smart Medical History Application',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColor.fromHex('#0092A4'),
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Generated: ${_formatDateTime(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromHex('#0092A4'),
                ),
              ),
              pw.Text(
                'Patient ID: ${patient.id}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromHex('#0092A4'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPatientInfo(Patient patient) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E0E0E0')),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Patient Information',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#000E52'),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Full Name:', patient.name),
                    _buildInfoRow('Age:', '${patient.age} years'),
                    _buildInfoRow('Gender:', patient.gender),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Date of Birth:', _formatDate(patient.dateOfBirth)),
                 
                  ],
                ),
              ),
            ],
          ),
          if (patient.notes != null) ...[
            pw.SizedBox(height: 8),
            _buildInfoRow('Notes:', patient.notes!),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0092A4'),
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColor.fromHex('#333333'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMedicalHistory(List<Map<String, dynamic>> medicalHistory) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Medical History',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#000E52'),
          ),
        ),
        pw.SizedBox(height: 12),
        ...medicalHistory.map((record) => _buildMedicalRecord(record)).toList(),
      ],
    );
  }

  pw.Widget _buildMedicalRecord(Map<String, dynamic> record) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E0E0E0')),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                record['type'] ?? 'Medical Record',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#000E52'),
                ),
              ),
              pw.Text(
                record['date'] ?? '',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromHex('#0092A4'),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          
          // Symptoms
          if (record['symptoms'] != null && (record['symptoms'] as List).isNotEmpty) ...[
            pw.Text(
              'Symptoms:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0092A4'),
              ),
            ),
            pw.Text(
              (record['symptoms'] as List<String>).join(', '),
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColor.fromHex('#333333'),
              ),
            ),
            pw.SizedBox(height: 6),
          ],
          
          // Diagnosis
          if (record['diagnosis'] != null) ...[
            pw.Text(
              'Diagnosis:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0092A4'),
              ),
            ),
            pw.Text(
              record['diagnosis'],
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColor.fromHex('#333333'),
              ),
            ),
            pw.SizedBox(height: 6),
          ],
          
          // Vital Signs
          if (record['vitals'] != null) ...[
            pw.Text(
              'Vital Signs:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0092A4'),
              ),
            ),
            pw.Row(
              children: [
                pw.Expanded(child: pw.Text('BP: ${record['vitals']['blood_pressure'] ?? 'N/A'}', style: pw.TextStyle(fontSize: 10))),
                pw.Expanded(child: pw.Text('HR: ${record['vitals']['heart_rate'] ?? 'N/A'}', style: pw.TextStyle(fontSize: 10))),
                pw.Expanded(child: pw.Text('Temp: ${record['vitals']['temperature'] ?? 'N/A'}', style: pw.TextStyle(fontSize: 10))),
                pw.Expanded(child: pw.Text('O2: ${record['vitals']['oxygen_saturation'] ?? 'N/A'}', style: pw.TextStyle(fontSize: 10))),
              ],
            ),
            pw.SizedBox(height: 6),
          ],
          
          // Notes
          if (record['notes'] != null) ...[
            pw.Text(
              'Notes:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0092A4'),
              ),
            ),
            pw.Text(
              record['notes'],
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColor.fromHex('#333333'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildAIAnalysis(Map<String, dynamic> aiAnalysis) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#E6F7FF'),
        border: pw.Border.all(color: PdfColor.fromHex('#00CFE4'), width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                'AI Analysis',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#000E52'),
                ),
              ),
              pw.Spacer(),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: _getRiskColor(aiAnalysis['risk_level'] ?? 'Low'),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Text(
                  '${aiAnalysis['risk_level'] ?? 'Low'} Risk (${aiAnalysis['confidence'] ?? '0%'})',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          
          // Differential Diagnosis
          if (aiAnalysis['differential_diagnosis'] != null) ...[
            pw.Text(
              'Differential Diagnosis:',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0092A4'),
              ),
            ),
            pw.SizedBox(height: 4),
            ...((aiAnalysis['differential_diagnosis'] as List<String>).map((diagnosis) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(left: 12, bottom: 2),
                child: pw.Text(
                  '• $diagnosis',
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColor.fromHex('#333333'),
                  ),
                ),
              );
            }).toList()),
            pw.SizedBox(height: 8),
          ],
          
          // Recommendations
          if (aiAnalysis['recommendations'] != null) ...[
            pw.Text(
              'Recommendations:',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0092A4'),
              ),
            ),
            pw.SizedBox(height: 4),
            ...((aiAnalysis['recommendations'] as List<String>).map((recommendation) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(left: 12, bottom: 2),
                child: pw.Text(
                  '• $recommendation',
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColor.fromHex('#333333'),
                  ),
                ),
              );
            }).toList()),
          ],
          
          // Analysis timestamp
          if (aiAnalysis['analysis_timestamp'] != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Analysis performed: ${_formatDateTime(DateTime.parse(aiAnalysis['analysis_timestamp']))}',
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColor.fromHex('#666666'),
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColor.fromHex('#E0E0E0')),
        ),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'This report was generated by myhx- Smart Medical History Application',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor.fromHex('#666666'),
              fontStyle: pw.FontStyle.italic,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'AI-powered medical history taking for healthcare professionals',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColor.fromHex('#999999'),
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'DISCLAIMER: This AI analysis is for educational and reference purposes only. Always consult with qualified healthcare professionals for medical decisions.',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColor.fromHex('#CC0000'),
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  PdfColor _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return PdfColor.fromHex('#DC2626'); // Red
      case 'medium':
        return PdfColor.fromHex('#D97706'); // Orange
      case 'low':
        return PdfColor.fromHex('#059669'); // Green
      default:
        return PdfColor.fromHex('#6B7280'); // Gray
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

