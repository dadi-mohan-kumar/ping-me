import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Color
  static const Color primary = Color(0xFF5B6EF5);

  // Light Background
  static const Color secondary = Color(0xFFF8FAFC);

  // Dark Text / Dark Mode Surface
  static const Color dark = Color(0xFF1E293B);

  // Accent Color
  static const Color accent = Color(0xFF7DD3B0);

  // Supporting Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color red = Color(0xFFEF4444);

  static const Color grey = Color(0xFFE2E8F0);

  // Chat Bubble Colors
  static const Color sentMessage = Color(0xFF5B6EF5);
  static const Color receivedMessage = Color(0xFFF1F5F9);

  // Dark Mode Bubble Colors
  static const Color darkSentMessage = Color(0xFF6D7CF7);
  static const Color darkReceivedMessage = Color(0xFF334155);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.secondary,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.secondary,
      onPrimary: AppColors.white,
      onSurface: AppColors.dark,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFE8ECFF),
      foregroundColor: Color(0xFF334155),
      centerTitle: true,
      elevation: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(AppColors.primary),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.dark,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.dark,
      onPrimary: AppColors.white,
      onSurface: AppColors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.dark,
      foregroundColor: AppColors.white,
      centerTitle: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.dark,
    ),
  );
}
