import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/ai_service.dart';
import 'patient_record_screen.dart'; // سننتقل إلى هذه الشاشة بعد التحليل

class MedicalHistoryScreen extends StatefulWidget {
  final Patient patient;
  const MedicalHistoryScreen({super.key, required this.patient});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentQuestionIndex = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _questions = [
    {'id': 'main_symptom', 'question': 'What is the patient\'s primary complaint?', 'type': 'text', 'required': true},
    {'id': 'symptom_details', 'question': 'Can you describe the primary complaint in more detail? (e.g., location, quality, radiation)', 'type': 'text'},
    {'id': 'symptom_duration', 'question': 'For how long has this complaint been present?', 'type': 'choice', 'options': ['Less than 24 hours', '1-3 days', '3-7 days', 'More than a week']},
    {'id': 'symptom_severity', 'question': 'On a scale of 1 to 10, how severe is the primary complaint?', 'type': 'scale', 'min': 1, 'max': 10},
    {'id': 'associated_symptoms', 'question': 'Are there any other associated symptoms? (e.g., fever, nausea, headache)', 'type': 'text'},
    {'id': 'past_medical_history', 'question': 'Does the patient have any significant past medical history? (e.g., Diabetes, Hypertension, Asthma)', 'type': 'text'},
    {'id': 'current_medications', 'question': 'Is the patient currently taking any medications, including over-the-counter drugs or supplements?', 'type': 'text'},
    {'id': 'allergies', 'question': 'Does the patient have any known allergies to medications or other substances?', 'type': 'text', 'required': true},
  ];

  final Map<String, dynamic> _answers = {};
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void dispose() {
    // التخلص من كل الـ controllers عند إغلاق الشاشة
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateAnswer(dynamic answer) {
    setState(() {
      _answers[_questions[_currentQuestionIndex]['id']] = answer;
    });
  }

  void _handleNext() {
    final currentQuestionId = _questions[_currentQuestionIndex]['id'];
    if (_answers[currentQuestionId] == null || (_answers[currentQuestionId] is String && _answers[currentQuestionId].trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer the current question to proceed.')),
      );
      return;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  Future<void> _finishAndAnalyze() async {
    final lastQuestionId = _questions.last['id'];
    if (_answers[lastQuestionId] == null || (_answers[lastQuestionId] is String && _answers[lastQuestionId].trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer the final question before finishing.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final aiService = AIService();
    
    // --- *** التصحيح النهائي هنا *** ---
    // تحويل العمر إلى نص باستخدام .toString()
    final analysisResult = await aiService.analyzeSymptoms(
      [
        _answers['main_symptom'],
        ...(_answers['associated_symptoms']?.toString().split(',') ?? [])
      ].where((s) => s != null && s.isNotEmpty).toList().cast<String>(),
      {
        'age': widget.patient.age.toString(), // <-- تم التصحيح
        'gender': widget.patient.gender,
      },
    );

    if (!mounted) return;

    setState(() { _isLoading = false; });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PatientRecordScreen(
          patient: widget.patient,
          medicalHistory: _answers,
          aiAnalysis: analysisResult,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bool isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Medical History: ${widget.patient.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize_outlined),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            tooltip: 'View Summary',
          ),
        ],
      ),
      endDrawer: _buildSummaryDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  LinearProgressIndicator(value: (_currentQuestionIndex + 1) / _questions.length),
                  const SizedBox(height: 8),
                  Text('Question ${_currentQuestionIndex + 1} of ${_questions.length}'),
                  const SizedBox(height: 32),
                  Text(_questions[_currentQuestionIndex]['question'], style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  Expanded(child: _buildAnswerWidget(_questions[_currentQuestionIndex])),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLastQuestion ? _finishAndAnalyze : _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLastQuestion ? Colors.green.shade600 : colors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(isLastQuestion ? 'Finish & Analyze' : 'Next', style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAnswerWidget(Map<String, dynamic> question) {
    final String questionId = question['id'];

    switch (question['type']) {
      case 'text':
        _textControllers.putIfAbsent(questionId, () => TextEditingController(text: _answers[questionId]));
        return TextFormField(
          controller: _textControllers[questionId],
          decoration: const InputDecoration(hintText: 'Type your answer here...', border: OutlineInputBorder()),
          maxLines: 5,
          onChanged: (value) => _updateAnswer(value),
        );
      case 'choice':
        return ListView(
          children: (question['options'] as List<String>).map((option) {
            return Card(
              color: _answers[questionId] == option ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : null,
              child: ListTile(
                title: Text(option),
                onTap: () => _updateAnswer(option),
              ),
            );
          }).toList(),
        );
      case 'scale':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text((_answers[questionId] ?? 5.0).toInt().toString(), style: Theme.of(context).textTheme.displaySmall),
            Slider(
              value: (_answers[questionId] ?? 5.0).toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: (_answers[questionId] ?? 5.0).toInt().toString(),
              onChanged: (value) => _updateAnswer(value),
            ),
          ],
        );
      default:
        return const Text('Unsupported question type');
    }
  }

  Widget _buildSummaryDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Summary', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            ..._answers.entries.map((entry) {
              final question = _questions.firstWhere((q) => q['id'] == entry.key)['question'];
              return ListTile(
                title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(entry.value.toString()),
                onTap: () {
                  setState(() {
                    _currentQuestionIndex = _questions.indexWhere((q) => q['id'] == entry.key);
                    Navigator.of(context).pop();
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
