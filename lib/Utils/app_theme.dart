// lib/utils/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Warm, calming palette
  static const Color primary = Color(0xFF5B7FA6);      // calm steel blue
  static const Color primaryLight = Color(0xFF8AAFD4);
  static const Color secondary = Color(0xFFE8A87C);    // warm peach
  static const Color accent = Color(0xFF7EC8B0);       // soft teal
  static const Color background = Color(0xFFF7F4EF);   // warm off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFDFBF8);
  static const Color textDark = Color(0xFF2D3142);
  static const Color textMid = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color error = Color(0xFFE05C5C);
  static const Color success = Color(0xFF52B788);
  static const Color warning = Color(0xFFF5A623);

  // Category colours
  static const Map<String, Color> categoryColors = {
    'meal': Color(0xFFFF8C69),
    'prayer': Color(0xFF9B8ED6),
    'medication': Color(0xFF5B7FA6),
    'exercise': Color(0xFF7EC8B0),
    'hydration': Color(0xFF64B5F6),
    'sleep': Color(0xFF7986CB),
    'other': Color(0xFF90A4AE),
  };

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          surface: surface,
        ),
        textTheme: GoogleFonts.nunitoTextTheme().copyWith(
          displayLarge: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          headlineMedium: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          titleLarge: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          titleMedium: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          bodyLarge: GoogleFonts.nunito(
            fontSize: 15,
            color: textMid,
          ),
          bodyMedium: GoogleFonts.nunito(
            fontSize: 14,
            color: textMid,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          iconTheme: const IconThemeData(color: textDark),
        ),
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFEAE8E4), width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF0EDE8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: GoogleFonts.nunito(color: textLight, fontSize: 14),
        ),
      );
}

// Routine categories with icons and colours
class RoutineCategory {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const RoutineCategory({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  static const List<RoutineCategory> all = [
    RoutineCategory(
      key: 'meal',
      label: 'Meal',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFF8C69),
    ),
    RoutineCategory(
      key: 'prayer',
      label: 'Prayer',
      icon: Icons.self_improvement_rounded,
      color: Color(0xFF9B8ED6),
    ),
    RoutineCategory(
      key: 'medication',
      label: 'Medication',
      icon: Icons.medication_rounded,
      color: Color(0xFF5B7FA6),
    ),
    RoutineCategory(
      key: 'exercise',
      label: 'Exercise',
      icon: Icons.directions_walk_rounded,
      color: Color(0xFF7EC8B0),
    ),
    RoutineCategory(
      key: 'hydration',
      label: 'Water',
      icon: Icons.local_drink_rounded,
      color: Color(0xFF64B5F6),
    ),
    RoutineCategory(
      key: 'sleep',
      label: 'Sleep',
      icon: Icons.bedtime_rounded,
      color: Color(0xFF7986CB),
    ),
    RoutineCategory(
      key: 'other',
      label: 'Other',
      icon: Icons.star_rounded,
      color: Color(0xFF90A4AE),
    ),
  ];

  static RoutineCategory fromKey(String key) =>
      all.firstWhere((c) => c.key == key, orElse: () => all.last);
}
