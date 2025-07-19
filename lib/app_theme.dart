// lib/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8A8A8E);
  static const Color lightBorder = Color(0xFFEAEAEB);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentRed = Color(0xFFF44336);
  static const Color accentOrange = Color(0xFFFF9500);

  static ThemeData get theme {
    final baseTextTheme = GoogleFonts.robotoTextTheme(
      ThemeData.light().textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgPrimary,
      appBarTheme: const AppBarTheme(
        backgroundColor: bgPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: accentGreen,
        background: bgPrimary,
        surface: bgPrimary,
        onBackground: textPrimary,
        onSurface: textPrimary,
        outline: lightBorder,
      ),
      textTheme: baseTextTheme.copyWith(
        displaySmall: baseTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 32),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textSecondary, fontSize: 14),
        labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}