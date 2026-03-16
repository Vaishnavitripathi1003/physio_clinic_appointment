// lib/providers/doctor_provider.dart

import 'package:flutter/material.dart';
import 'package:physio_clinic_appointment/db/firebaseRTDBService.dart';
import 'dart:async';

import 'package:physio_clinic_appointment/models/doctor_model.dart'; // Using package import for consistency

class DoctorProvider with ChangeNotifier {
  final FirebaseRTDBService _rtdbService = FirebaseRTDBService();

  // Make the subscription private
  StreamSubscription<List<DoctorModel>>? _doctorsSubscription;

  // Set the backing lists
  List<DoctorModel> _doctors = [];
  List<DoctorModel> get doctors => _doctors;

  List<DoctorModel> _filteredDoctors = [];
  List<DoctorModel> get filteredDoctors => _filteredDoctors;

  // --- Initialization ---

  // Constructor: Start listening to the stream immediately
  DoctorProvider() {
    // Calling the initialization method
    _initializeRTDBStream();
    // Initialize the filtered list in the constructor in case the stream is slow
    _filteredDoctors = _doctors;
  }

  // Method to start/restart the stream listener
  void _initializeRTDBStream() {
    _doctorsSubscription?.cancel();

    _doctorsSubscription = _rtdbService.getDoctorsStream().listen((doctorList) {
      // 1. Update the master list
      _doctors = doctorList;
      // 2. Trigger filtering/update UI
      filterDoctors('');
    }, onError: (error) {
      debugPrint('RTDB Doctor Stream Error: $error');
      // On error, clear lists and notify
      _doctors = [];
      filterDoctors('');
    });
  }

  // --- Getters and Disposal ---

  DoctorModel? getDoctorById(String id) {
    try {
      return _doctors.firstWhere((doctor) => doctor.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    // Ensure the stream is cancelled to prevent memory leaks
    _doctorsSubscription?.cancel();
    super.dispose();
  }

  // --- CRUD Operations ---

  // loadDoctors is now just a placeholder/debug helper, as the stream manages data
  Future<void> loadDoctors() async {
    debugPrint("Data is managed by Firebase RTDB stream. Manual load not required.");
  }

  Future<void> addDoctor(DoctorModel d) async {
    // Service handles generating the unique RTDB key
    await _rtdbService.addDoctor(d);
    // UI update handled by the stream
  }

  Future<void> editDoctor(DoctorModel d) async {
    // d.id must be the RTDB String key
    if (d.id != null) {
      await _rtdbService.editDoctor(d);
    }
  }

  Future<void> deleteDoctor(String id) async {
    // id must be the RTDB String key
    await _rtdbService.deleteDoctor(id);
  }

  // --- Filtering Logic ---
  void filterDoctors(String query) {
    if (query.isEmpty) {
      // If query is empty, show the entire master list
      _filteredDoctors = _doctors;
    } else {
      final lowerQuery = query.toLowerCase();
      // Apply search logic to the master list
      _filteredDoctors = _doctors.where((doctor) {
        return doctor.name.toLowerCase().contains(lowerQuery) ||
            (doctor.specialization?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }
    // Notify widgets that the filtered list has changed
    notifyListeners();
  }
}