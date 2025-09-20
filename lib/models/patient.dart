class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final DateTime dateOfBirth;
  final DateTime createdAt;
  final String? notes;
  final List<String> symptoms;
  final List<String> diagnoses;

  // --- الحقول التي تريدينها بشدة ---
  final String department;
  final String wardNumber;
  final String roomNumber;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.dateOfBirth,
    required this.createdAt,
    this.notes,
    this.symptoms = const [],
    this.diagnoses = const [],
    // --- التأكد من أنها إجبارية ---
    required this.department,
    required this.wardNumber,
    required this.roomNumber,
  });

  // --- دالة التحويل من JSON (مهمة لقاعدة البيانات) ---
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      createdAt: DateTime.parse(json['createdAt']),
      notes: json['notes'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      diagnoses: List<String>.from(json['diagnoses'] ?? []),
      // --- قراءة الحقول الجديدة من قاعدة البيانات ---
      department: json['department'] ?? 'General', // قيمة افتراضية للبيانات القديمة
      wardNumber: json['wardNumber'] ?? 'N/A',
      roomNumber: json['roomNumber'] ?? 'N/A',
    );
  }

  // --- دالة التحويل إلى JSON (مهمة لقاعدة البيانات) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'symptoms': symptoms,
      'diagnoses': diagnoses,
      // --- حفظ الحقول الجديدة في قاعدة البيانات ---
      'department': department,
      'wardNumber': wardNumber,
      'roomNumber': roomNumber,
    };
  }
}
