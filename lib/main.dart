import 'package:flutter/material.dart';
import 'package:physio_clinic_appointment/providers/post_provider.dart';
import 'package:physio_clinic_appointment/widgets/main_navigator.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/doctor_provider.dart';
import 'providers/patient_provider.dart';
import 'screens/login_screen.dart';
import 'utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ... (Other setup code, like Firebase initialization in main() async)


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
  );
  runApp(const ClinicApp());
}

class ClinicApp extends StatelessWidget {
  const ClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()..loadDoctors()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => RTDBPostsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Clinic Manager',
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // 1. Show splash screen while checking persistent session
    if (authProvider.isCheckingAuthStatus) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 2. Redirect based on login status
    if (authProvider.isLoggedIn) {
      return const MainNavigator();
    } else {
      return const LoginScreen();
    }
  }
}

// In your main.dart file's runApp() call:
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(
//     MultiProvider(
//       providers: [
//         // 🚨 Ensure AuthProvider is initialized here
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         // ... other providers (DoctorProvider, PatientProvider)
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: AuthWrapper(), // ⬅️ Start the app with the AuthWrapper
//     );
//   }
// }
