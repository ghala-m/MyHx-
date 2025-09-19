import 'package:flutter/material.dart';
import '../models/patient.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class PatientRecordScreen extends StatefulWidget {
  final Patient patient;
  final Map<String, dynamic>? medicalHistory;
  final Map<String, dynamic>? aiAnalysis;

  const PatientRecordScreen({
    super.key,
    required this.patient,
    this.medicalHistory,
    this.aiAnalysis,
  });

  @override
  State<PatientRecordScreen> createState() => _PatientRecordScreenState();
}

class _PatientRecordScreenState extends State<PatientRecordScreen> {
  bool _isGeneratingPdf = false;
  

  @override
  void initState() {
    super.initState();

  }

  Future<void> _generateAndSharePdf() async {
    setState(() { _isGeneratingPdf = true; });
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              // محتوى الـ PDF يجب أن يعكس كل البيانات المعروضة
              pw.Header(level: 0, child: pw.Text('Medical Report: ${widget.patient.name}', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 20),
              pw.Text('Patient Information', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('Name: ${widget.patient.name}'),
              pw.Text('Age: ${widget.patient.age} years'),
              pw.Text('Gender: ${widget.patient.gender}'),

              pw.SizedBox(height: 20),
              if (widget.medicalHistory != null) ...[
                pw.Text('Medical History', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ...widget.medicalHistory!.entries.map((e) => pw.Text('${e.key.replaceAll('_', ' ').toUpperCase()}: ${e.value}')),
                pw.SizedBox(height: 20),
              ],
              if (widget.aiAnalysis != null) ...[
                pw.Text('AI Analysis', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text('Diagnoses: ${(widget.aiAnalysis!['differential_diagnosis'] as List).join(", ")}'),
                pw.Text('Recommendations: ${(widget.aiAnalysis!['recommendations'] as List).join(", ")}'),
              ],
            ];
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/report_${widget.patient.id}.pdf");
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles([XFile(file.path)], text: 'Medical report for ${widget.patient.name}');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() { _isGeneratingPdf = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(widget.patient.name),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        actions: [
          if (_isGeneratingPdf)
            const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()))
          else
            IconButton(icon: const Icon(Icons.share_outlined), onPressed: _generateAndSharePdf, tooltip: 'Share Report'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientSummaryCard(theme, colors),
            const SizedBox(height: 24),
      
            const SizedBox(height: 24),
            if (widget.medicalHistory != null) ...[
              _buildSectionHeader('Medical History', Icons.history_edu_outlined, colors),
              _buildHistoryDetailsCard(theme, colors, widget.medicalHistory!),
              const SizedBox(height: 24),
            ],
            if (widget.aiAnalysis != null) ...[
              _buildSectionHeader('AI Analysis', Icons.psychology_outlined, colors),
              _buildAiAnalysisCard(theme, colors, widget.aiAnalysis!),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSummaryCard(ThemeData theme, ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.person_outline, color: colors.primary, size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.patient.name, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('${widget.patient.age} years • ${widget.patient.gender}', style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }

  

 
  Widget _buildHistoryDetailsCard(ThemeData theme, ColorScheme colors, Map<String, dynamic> history) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: history.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: Text('${entry.key.replaceAll('_', ' ').toUpperCase()}:', style: const TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text(entry.value.toString())),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAiAnalysisCard(ThemeData theme, ColorScheme colors, Map<String, dynamic> analysis) {
    final List<String> diagnoses = List<String>.from(analysis['differential_diagnosis'] ?? []);
    final List<String> recommendations = List<String>.from(analysis['recommendations'] ?? []);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Differential Diagnosis', style: theme.textTheme.titleMedium),
            const Divider(),
            ...diagnoses.map((d) => ListTile(leading: const Icon(Icons.arrow_right), title: Text(d))),
            const SizedBox(height: 16),
            Text('Recommendations', style: theme.textTheme.titleMedium),
            const Divider(),
            ...recommendations.map((r) => ListTile(leading: const Icon(Icons.check), title: Text(r))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
