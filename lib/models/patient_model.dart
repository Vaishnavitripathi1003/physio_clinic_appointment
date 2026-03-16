// models/patient_model.dart

class PatientModel {
  String? id; // ⬅️ Firebase RTDB uses String keys
  String? doctorId;
  String name;
  String? gender;
  int? age;
  String? phone;
  String? email;
  String? bloodGroup;
  String? maritalStatus;
  String? address;
  String? conditionType;
  String? disease;
  String? notes;
  String? createdAt;

  PatientModel({
    this.id,
    required this.doctorId,
    required this.name,
    this.gender,
    this.age,
    this.phone,
    this.email,
    this.bloodGroup,
    this.maritalStatus,
    this.address,
    this.conditionType,
    this.disease,
    this.notes,
    this.createdAt,
  });

  // Used for WRITING data to RTDB (excludes 'id')
  Map<String, dynamic> toMap() => {
    'doctorId': doctorId,
    'name': name,
    'gender': gender,
    'age': age,
    'phone': phone,
    'email': email,
    'bloodGroup': bloodGroup,
    'maritalStatus': maritalStatus,
    'address': address,
    'conditionType': conditionType,
    'disease': disease,
    'notes': notes,
    'createdAt': createdAt,
  };

  // Used for READING data from an RTDB DataSnapshot
  factory PatientModel.fromMap(Map<String, dynamic> m, String key) {
    final rawAge = m['age'];

    return PatientModel(
      id: key, // ⬅️ Set the RTDB key here
      doctorId: m['doctorId'] as String,
      name: m['name'] as String,
      gender: m['gender'] as String?,
      // Safe casting for int fields
      age: rawAge is int ? rawAge : (rawAge != null ? int.tryParse(rawAge.toString()) : null),
      phone: m['phone'] as String?,
      email: m['email'] as String?,
      bloodGroup: m['bloodGroup'] as String?,
      maritalStatus: m['maritalStatus'] as String?,
      address: m['address'] as String?,
      conditionType: m['conditionType'] as String?,
      disease: m['disease'] as String?,
      notes: m['notes'] as String?,
      createdAt: m['createdAt'] as String?,
    );
  }
}