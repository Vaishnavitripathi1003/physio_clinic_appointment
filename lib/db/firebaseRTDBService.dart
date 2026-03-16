// lib/db/firebase_rtdb_service.dart

import 'package:firebase_database/firebase_database.dart';
import '../models/doctor_model.dart';

class FirebaseRTDBService {
  final DatabaseReference _doctorsRef =
  FirebaseDatabase.instance.ref('doctors'); // Path to your data

  // Stream for real-time updates
  Stream<List<DoctorModel>> getDoctorsStream() {
    return _doctorsRef.onValue.map((event) {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.value == null) {
        return [];
      }

      final Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      List<DoctorModel> doctors = [];

      values.forEach((key, value) {
        // 'key' is the RTDB unique ID, 'value' is the doctor data map
        final doctorMap = Map<String, dynamic>.from(value);
        doctors.add(DoctorModel.fromMap(doctorMap));
      });

      return doctors;
    });
  }

  // CREATE
  Future<void> addDoctor(DoctorModel doctor) async {
    // Pushes a new unique key and sets the data
    await _doctorsRef.push().set(doctor.toMap());
  }

  // UPDATE
  Future<void> editDoctor(DoctorModel doctor) async {
    if (doctor.id != null) {
      // Updates the data at the specific unique key (doctor.id)
      await _doctorsRef.child(doctor.id!.toString()).update(doctor.toMap());
    }
  }

  // DELETE
  Future<void> deleteDoctor(String id) async {
    await _doctorsRef.child(id).remove();
  }
}