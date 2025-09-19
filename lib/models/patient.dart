class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final DateTime createdAt;
  final DateTime? lastVisit;
 
  final List<String> symptoms;
  final List<String> diagnoses;
  final String? notes;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.createdAt,
    this.lastVisit,
 
    this.symptoms = const [],
    this.diagnoses = const [],
    this.notes,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      createdAt: DateTime.parse(json['createdAt']),
      lastVisit: json['lastVisit'] != null ? DateTime.parse(json['lastVisit']) : null,
    
      symptoms: List<String>.from(json['symptoms'] ?? []),
      diagnoses: List<String>.from(json['diagnoses'] ?? []),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastVisit': lastVisit?.toIso8601String(),
   
      'symptoms': symptoms,
      'diagnoses': diagnoses,
      'notes': notes,
    };
  }

  Patient copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? phoneNumber,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? lastVisit,

    List<String>? symptoms,
    List<String>? diagnoses,
    String? notes,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      lastVisit: lastVisit ?? this.lastVisit,
      symptoms: symptoms ?? this.symptoms,
      diagnoses: diagnoses ?? this.diagnoses,
      notes: notes ?? this.notes,
    );
  }
}