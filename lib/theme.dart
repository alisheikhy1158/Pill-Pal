import 'package:flutter/material.dart';

class AppColors {
  static const background   = Color(0xFFF7F5F2);
  static const surface      = Color(0xFFEDE9E3);
  static const surfaceAlt   = Color(0xFFE5E0D8);
  static const dark         = Color(0xFF1A1A18);
  static const darkMid      = Color(0xFF3D3A35);
  static const textPrimary  = Color(0xFF1A1A18);
  static const textSecondary= Color(0xFF444440);
  static const textMuted    = Color(0xFF888880);
  static const border       = Color(0xFFD8D2CA);
  static const borderLight  = Color(0xFFE5E0D8);

  // Medication dot colors – distinct, accessible
  static const medGreen  = Color(0xFF4A9B7F);
  static const medBlue   = Color(0xFF4A6FA5);
  static const medBrown  = Color(0xFFA0522D);
  static const medPurple = Color(0xFF7B5EA7);
  static const medAmber  = Color(0xFFC0831A);

  // Status badge backgrounds + text
  static const doneBg    = Color(0xFFC8EDD8);
  static const doneText  = Color(0xFF1A5C35);
  static const dueBg     = Color(0xFFD0DCFF);
  static const dueText   = Color(0xFF1A2A8C);
  static const missBg    = Color(0xFFFFD0D0);
  static const missText  = Color(0xFF8C1A1A);
}

ThemeData buildTheme() => ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Inter',
  colorScheme: const ColorScheme.light(
    primary: AppColors.dark,
    surface: AppColors.background,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.dark,
    foregroundColor: AppColors.background,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: AppColors.background,
      fontSize: 20,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.3,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.background,
    selectedItemColor: AppColors.dark,
    unselectedItemColor: AppColors.textMuted,
    selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
    showSelectedLabels: true,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  dividerColor: AppColors.borderLight,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.dark, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
  ),
);
