// lib/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Palette from your brief
  static const Color bgPrimary = Color(0xFFFAFAFA);
  static const Color bgSecondary = Color(0xFFF2F2F7);
  static const Color bgElevated = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF3A3A3C);
  static const Color textTertiary = Color(0xFF6E6E73);
  static const Color textDisabled = Color(0xFFAEAEB2);
  static const Color lightBorder = Color(0xFFEAEAEB);
  
  // Functional Colors from your brief
  static const Color accentGreen = Color(0xFF36C25B);
  static const Color accentOrange = Color(0xFFFF9F0A);
  static const Color accentPurple = Color(0xFFAF52DE);
  static const Color accentRed = Color(0xFFFF3B30);

  // The single, definitive theme getter
  static ThemeData get theme {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.light().textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgPrimary,
      colorScheme: const ColorScheme.light(
        primary: accentGreen,
        background: bgPrimary,
        surface: bgElevated,
        onBackground: textPrimary,
        onSurface: textPrimary,
        outline: lightBorder,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(fontSize: 48, fontWeight: FontWeight.w700, height: 52 / 48),
        displayMedium: baseTextTheme.displayMedium?.copyWith(fontSize: 36, fontWeight: FontWeight.w600, height: 40 / 36),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.w600, height: 28 / 24),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: 17, height: 22 / 17),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: 15, height: 20 / 15),
        bodySmall: baseTextTheme.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12),
      ),
    );
  }
}