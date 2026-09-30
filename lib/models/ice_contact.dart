class IceContact {
  int? id;
  String name;
  String relation;
  String phoneNumber;

  IceContact({
    this.id,
    required this.name,
    required this.relation,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'phoneNumber': phoneNumber,
    };
  }

  factory IceContact.fromMap(Map<String, dynamic> map) {
    return IceContact(
      id: map['id'] as int?,
      name: map['name'] as String,
      relation: map['relation'] as String,
      phoneNumber: map['phoneNumber'] as String,
    );
  }
}
