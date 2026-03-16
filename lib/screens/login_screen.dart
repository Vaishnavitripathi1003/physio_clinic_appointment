import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:physio_clinic_appointment/widgets/main_navigator.dart';
import '../providers/doctor_provider.dart';
import '../providers/auth_provider.dart';
import '../models/doctor_model.dart';
import 'admin_doctors_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  DoctorModel? selectedDoctor;
  // 1. Switched from _password to _otpController
  final _otpController = TextEditingController();

  // New state to manage the UI stage: false = select doctor/send code; true = enter OTP
  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<DoctorProvider>(context, listen: false).loadDoctors();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // Helper method for immediate feedback
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // --- 📞 Step 1: Send OTP Logic ---
  Future<void> _sendOtp() async {
    if (selectedDoctor == null) {
      _showSnackbar('Please select a doctor.');
      return;
    }
    // Assuming DoctorModel now has a 'phone' field (String)
    final phoneNumber = selectedDoctor!.phone;

    // NOTE: Firebase expects phone numbers in E.164 format (+CCNNNNNNNNN)
    if (phoneNumber == null || phoneNumber.isEmpty || !phoneNumber.startsWith('+')) {
      _showSnackbar('Phone number is invalid. Ensure it includes the country code (e.g., +91).');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    _showSnackbar('Sending OTP...');

    await authProvider.sendCode(
      phoneNumber: phoneNumber,
      codeSentCallback: (verificationId) {
        setState(() {
          _otpSent = true; // Switch UI to OTP input mode
        });
        _showSnackbar('OTP successfully sent to ${selectedDoctor!.phone!}');
      },
      verificationFailedCallback: (error) {
        _showSnackbar('Error sending OTP: $error');
      },
    );
  }

  // --- 🔐 Step 2: Verify OTP Logic ---
  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      _showSnackbar('Please enter the full 6-digit OTP.');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.verifyCodeAndSignIn(otp);

      // Check if sign-in was successful (AuthStateChanges listener takes over)
      // The listener will handle navigation in main.dart once DoctorModel is loaded.
      _showSnackbar('Verification successful. Logging in...');

    } catch (e) {
      _showSnackbar('Verification Failed: Incorrect or expired code.');
      print(e); // Log the detailed error
    }
  }
  // --- END Logic ---


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // Listen to the AuthProvider for loading state during OTP process
    final bool isLoading = authProvider.isVerificationInProgress;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0FAF7C), Color(0xFF2AB7A9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: Lottie.asset('assets/lottie/success.json'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Clinic Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // 1. Doctor Dropdown (Only visible before OTP is sent)
                if (!_otpSent)
                  Consumer<DoctorProvider>(
                    builder: (context, docProv, _) {
                      final docs = docProv.doctors;

                      if (selectedDoctor != null && !docs.any((d) => d.id == selectedDoctor!.id)) {
                        selectedDoctor = null;
                      }

                      if (docs.isEmpty) {
                        return const Text(
                          'No doctors available. Please add a doctor first.',
                          style: TextStyle(color: Colors.white),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        value: selectedDoctor?.id,
                        hint: const Text('Select Doctor'),
                        items: docs
                            .map((d) => DropdownMenuItem<String>(
                          value: d.id,
                          child: Text(d.name),
                        ))
                            .toList(),
                        onChanged: (id) {
                          setState(() {
                            if (id != null) {
                              selectedDoctor = docs.firstWhere((d) => d.id == id) as DoctorModel?;   }
                            else {
                              selectedDoctor = null;
                            }
                          });
                        },
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      );
                    },
                  ),

                if (_otpSent) const SizedBox(height: 12),

                // 2. OTP Input Field (Replaces the old password field)
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: _otpSent
                        ? 'Enter the 6-digit OTP'
                        : selectedDoctor?.phone ?? 'Select a doctor to get phone number',
                    filled: true,
                    fillColor: Colors.white,
                    counterText: '', // Hide length counter
                    // Only enable input if OTP has been requested
                    enabled: _otpSent,
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Action Button (Handles Send OTP or Verify OTP)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        // ❌ OLD: onPressed: () { ... .login() ... }
                        // ✅ NEW: Call the appropriate function based on state
                        onPressed: isLoading ? null : (_otpSent ? _verifyOtp : _sendOtp),
                        child: isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : Text(_otpSent ? 'Verify & Login' : 'Send OTP to Phone'),
                      ),
                    ),
                  ],
                ),

                // 4. Resend OTP and Edit Doctor Selection (Back Button)
                if (_otpSent) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: isLoading ? null : () {
                          setState(() {
                            _otpSent = false;
                            _otpController.clear();
                            // Note: The main AuthProvider state handles the rest (e.g. clearing verificationId)
                          });
                        },
                        child: const Text('← Edit Doctor/Phone', style: TextStyle(color: Colors.white70)),
                      ),
                      TextButton(
                        onPressed: isLoading ? null : () {
                          _otpController.clear();
                          _sendOtp(); // Resend OTP
                        },
                        child: const Text('Resend OTP', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Admin Manage Doctors Button
                TextButton(
                  onPressed: isLoading ? null : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminDoctorsScreen()),
                    );
                    if(mounted) {
                      Provider.of<DoctorProvider>(context, listen: false).loadDoctors();
                    }
                  },
                  child: const Text(
                    'Manage Doctors (Admin)',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 8),
                const Text(
                  'Tip: Ensure the selected doctor has a phone number starting with the country code (e.g., +91...).',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}