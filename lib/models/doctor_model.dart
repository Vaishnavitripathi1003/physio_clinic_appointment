class DoctorModel {
  // CRITICAL FIX: Change type from int? to String? for Firebase compatibility
  late final String? id;
  final String name;
  final String? gender;
  final String? specialization;
  final String? phone;
  final String? email;
  final int? experience;
  final String? availability;
  final double? fee;
  final String? clinicName;
  final String? regNo;
  final String? createdAt;

  DoctorModel({
    this.id, // Now String?
    required this.name,
    this.gender,
    this.specialization,
    this.phone,
    this.email,
    this.experience,
    this.availability,
    this.fee,
    this.clinicName,
    this.regNo,
    this.createdAt,
  });

  // 1. ✅ Convert to Map
  Map<String, dynamic> toMap() {
    // Note: 'id' is included but will be excluded by the Firebase service
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'specialization': specialization,
      'phone': phone,
      'email': email,
      'experience': experience,
      'availability': availability,
      'fee': fee,
      'clinicName': clinicName,
      'regNo': regNo,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  // 2. ✅ Create instance from DB Map (Handles int, String, and provided key)
  factory DoctorModel.fromMap(Map<String, dynamic> map, [String? key]) {
    String? finalId = key;
    final dynamic rawId = map['id'];

    // If key is not provided by Firebase service, derive it from the map
    if (finalId == null) {
      if (rawId is int) {
        // SQLite: Convert int ID to String
        finalId = rawId.toString();
      } else if (rawId is String) {
        // Firebase/Firestore stored data
        finalId = rawId;
      }
    }

    return DoctorModel(
      id: finalId, // Now correctly assigned as String?
      name: map['name'] as String? ?? '',
      gender: map['gender'] as String?,
      specialization: map['specialization'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      // Robustly handle potential type differences for int fields
      experience: map['experience'] is int
          ? map['experience'] as int?
          : int.tryParse(map['experience']?.toString() ?? ''),
      availability: map['availability'] as String?,
      fee: map['fee'] != null ? (map['fee'] as num).toDouble() : null,
      clinicName: map['clinicName'] as String?,
      regNo: map['regNo'] as String?,
      createdAt: map['createdAt'] as String?,
    );
  }

  // 3. ✨ Utility method for creating a modified copy
  DoctorModel copyWith({
    String? id, // Updated to String?
    String? name,
    String? gender,
    String? specialization,
    String? phone,
    String? email,
    int? experience,
    String? availability,
    double? fee,
    String? clinicName,
    String? regNo,
    String? createdAt,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      specialization: specialization ?? this.specialization,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      experience: experience ?? this.experience,
      availability: availability ?? this.availability,
      fee: fee ?? this.fee,
      clinicName: clinicName ?? this.clinicName,
      regNo: regNo ?? this.regNo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 4. ✨ Basic validation check
  bool isValid() {
    return name.isNotEmpty && specialization != null && specialization!.isNotEmpty && regNo != null && regNo!.isNotEmpty;
  }

  // 5. ✅ For easy debugging
  @override
  String toString() {
    return 'DoctorModel(id: $id, name: $name, specialization: $specialization, fee: $fee)';
  }
}