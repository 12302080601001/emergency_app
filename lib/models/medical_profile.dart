class MedicalProfile {
  int? id;
  String name;
  String bloodType;
  String allergies;
  String medicalConditions;

  MedicalProfile({
    this.id,
    required this.name,
    required this.bloodType,
    required this.allergies,
    required this.medicalConditions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bloodType': bloodType,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
    };
  }

  factory MedicalProfile.fromMap(Map<String, dynamic> map) {
    return MedicalProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      bloodType: map['bloodType'] as String,
      allergies: map['allergies'] as String,
      medicalConditions: map['medicalConditions'] as String,
    );
  }
}
