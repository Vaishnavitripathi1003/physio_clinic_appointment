// providers/auth_provider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // ⬅️ Switched to RTDB
import '../models/doctor_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Use DatabaseReference for Realtime Database
  final DatabaseReference _doctorRef = FirebaseDatabase.instance.ref('doctors');

  // --- Auth State & Persistence ---
  DoctorModel? _currentDoctor;
  bool _isCheckingAuthStatus = true; // State to show loading on startup

  // --- Phone Auth State ---
  String? _verificationId;
  int? _resendToken;
  bool _isVerificationInProgress = false;

  // --- Getters ---
  DoctorModel? get currentDoctor => _currentDoctor;
  bool get isLoggedIn => _currentDoctor != null;
  bool get isCheckingAuthStatus => _isCheckingAuthStatus; // ⬅️ Required for persistence check
  bool get isVerificationInProgress => _isVerificationInProgress;
  String? get verificationId => _verificationId;


  // 1. 🌐 Initialization: Listener for Firebase Auth state changes
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is signed in to Firebase. Fetch their specific Doctor data.
        _fetchDoctorData(user.uid);
      } else {
        // User logged out
        _currentDoctor = null;
        _isCheckingAuthStatus = false;
        notifyListeners();
      }
    });
  }

  // 2. 📝 Private method to fetch Doctor data from RTDB
  Future<void> _fetchDoctorData(String uid) async {
    try {
      // Assuming 'doctors' node uses the user's UID as the document key
      final snapshot = await _doctorRef.child(uid).once();

      final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final doctorData = data.cast<String, dynamic>();
        // 🚨 IMPORTANT: Use the UID as the ID/Key for the DoctorModel
        _currentDoctor = DoctorModel.fromMap(doctorData, uid);
      } else {
        // If Firebase Auth session is valid but RTDB record is missing, force logout.
        await _auth.signOut();
      }
    } catch (e) {
      print('Error fetching doctor data: $e');
    } finally {
      _isCheckingAuthStatus = false;
      notifyListeners();
    }
  }

  // 3. 📞 Phone Auth - Step 1: Send OTP
  Future<void> sendCode({
    required String phoneNumber,
    required Function(String verificationId) codeSentCallback,
    required Function(String error) verificationFailedCallback,
  }) async {
    _isVerificationInProgress = true;
    notifyListeners();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-sign in the user (happens in the background on Android)
        await _signInWithCredential(credential);
        _isVerificationInProgress = false;
        notifyListeners();
      },
      verificationFailed: (FirebaseAuthException e) {
        _isVerificationInProgress = false;
        verificationFailedCallback(e.message ?? 'Phone verification failed.');
        notifyListeners();
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        _isVerificationInProgress = false;
        codeSentCallback(verificationId);
        notifyListeners();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        _isVerificationInProgress = false;
        notifyListeners();
      },
      forceResendingToken: _resendToken,
      timeout: const Duration(seconds: 60),
    );
  }

  // 4. 🔒 Phone Auth - Step 2 & Final Sign In
  Future<void> verifyCodeAndSignIn(String smsCode) async {
    if (_verificationId == null) {
      throw Exception('Verification ID is missing. Please resend the code.');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    // Calls Firebase sign-in, which triggers the authStateChanges listener
    await _signInWithCredential(credential);
  }

  // Helper method for credential sign-in
  Future<void> _signInWithCredential(AuthCredential credential) async {
    // Firebase handles sign-in and session persistence automatically
    await _auth.signInWithCredential(credential);
    // The authStateChanges listener takes over from here to fetch the DoctorModel
  }

  // 5. 🚪 Firebase Logout
  Future<void> logout() async {
    // Firebase handles clearing the persistent session
    await _auth.signOut();
    // authStateChanges listener handles setting _currentDoctor to null
  }
}