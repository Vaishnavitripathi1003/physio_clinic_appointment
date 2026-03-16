// providers/patient_provider.dart

import 'package:flutter/material.dart';
// ⚠️ Requires firebase_database package
import 'package:firebase_database/firebase_database.dart';
import '../models/patient_model.dart';

class PatientProvider with ChangeNotifier {
  // 1. RTDB Reference (root of patients)
  final DatabaseReference _patientRef =
  FirebaseDatabase.instance.ref('patients');

  List<PatientModel> _patients = [];
  List<PatientModel> get patients => _patients;

  // 2. Real-time Listener (Read)
  void loadPatientsForDoctor(String doctorId) {
    // ⚠️ RTDB does not have indexed queries like Firestore.
    // The typical structure is: patients/DOCTOR_ID/PATIENT_ID/data
    // If your RTDB is structured as /patients/{patientId}/ {doctorId: 'uid'}, 
    // we must listen to the whole 'patients' node and filter locally or use rules.

    // Assuming structure is: patients/{patientId}/data
    _patientRef
        .orderByChild('doctorId') // Use this if doctorId is a child field
        .equalTo(doctorId)
        .onValue // Stream of DatabaseEvent
        .listen((event) {

      final snapshot = event.snapshot;
      final List<PatientModel> loadedPatients = [];

      if (snapshot.exists && snapshot.value != null) {
        // Data in RTDB is Map<String, dynamic> where key is the patient ID
        final Map<dynamic, dynamic> patientsMap = snapshot.value as Map<dynamic, dynamic>;

        patientsMap.forEach((key, value) {
          final patientData = value as Map<String, dynamic>;
          // 🚨 CRITICAL: Use the RTDB key as the ID and pass the data map
          loadedPatients.add(PatientModel.fromMap(patientData, key as String));
        });
      }

      // Sort the list before setting it
      _patients = loadedPatients.reversed.toList();

      notifyListeners();
    });
  }

  // 3. Add Patient (Create)
  Future<void> addPatient(PatientModel p) async {
    // Use push() to get a unique key, then set the data.
    await _patientRef.push().set(p.toMap());
    // Stream updates list automatically
  }

  // 4. Update Patient
  Future<void> updatePatient(PatientModel p) async {
    if (p.id == null) {
      throw Exception('Cannot update patient: ID is null.');
    }
    // Update the specific child node using the stored RTDB key (p.id)
    await _patientRef.child(p.id!).update(p.toMap());
    // Stream updates list automatically
  }

  // 5. Delete Patient
  Future<void> deletePatient(String id) async {
    // Remove the specific child node using the stored RTDB key (id)
    await _patientRef.child(id).remove();
    // Stream updates list automatically
  }
}