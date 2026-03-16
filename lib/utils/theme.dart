import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final Color primaryStart = const Color(0xFF0FAF7C);
  static final Color primaryEnd = const Color(0xFF2AB7A9);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    textTheme: GoogleFonts.poppinsTextTheme(),
    colorScheme: ColorScheme.fromSeed(seedColor: primaryStart),
    scaffoldBackgroundColor: const Color(0xFFF4F7F7),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0FAF7C)),
  );
}
