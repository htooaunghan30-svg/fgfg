// lib/core/themes/app_theme.dart
import 'package:flutter/material.dart';
import 'color_scheme.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2E7D32),
      secondary: Color(0xFF0288D1),
      background: Color(0xFFF1F3F6),
      surface: Color(0xFFF5F6F8),
      error: Color(0xFFD32F2F),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Color(0xFF1B1B1B),
      onSurface: Color(0xFF1B1B1B),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF1F3F6),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F6F8),
      foregroundColor: Color(0xFF1B1B1B),
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFF7F8FA),
    ),
    buttonTheme: const ButtonThemeData(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B1B1B),
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B1B1B),
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B1B1B),
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1B1B1B),
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1B1B1B),
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1B1B1B),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF2E2E2E),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF2E2E2E),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Color(0xFF6B7280),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD5DCE3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD5DCE3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2E7D32)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
      filled: true,
      fillColor: const Color(0xFFE9EDF2),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColorScheme.primary,
      secondary: AppColorScheme.secondary,
      background: AppColorScheme.background,
      surface: AppColorScheme.surface,
      error: AppColorScheme.error,
      onPrimary: AppColorScheme.onPrimary,
      onSecondary: AppColorScheme.onSecondary,
      onBackground: AppColorScheme.onBackground,
      onSurface: AppColorScheme.onSurface,
      onError: AppColorScheme.onError,
    ),
    scaffoldBackgroundColor: AppColorScheme.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorScheme.surface,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColorScheme.surface,
    ),
    buttonTheme: const ButtonThemeData(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColorScheme.primary,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColorScheme.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColorScheme.textPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColorScheme.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColorScheme.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColorScheme.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColorScheme.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColorScheme.textSecondary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColorScheme.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColorScheme.textDisabled,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColorScheme.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColorScheme.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColorScheme.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColorScheme.error),
      ),
      filled: true,
      fillColor: AppColorScheme.surface,
    ),
  );

  static ThemeData goldTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColorScheme.goldMid,
      secondary: AppColorScheme.goldEnd,
      background: AppColorScheme.goldBackground,
      surface: AppColorScheme.goldSurface,
      error: Color(0xFFD32F2F),
      onPrimary: AppColorScheme.goldOnPrimary,
      onSecondary: AppColorScheme.goldTextPrimary,
      onBackground: AppColorScheme.goldTextPrimary,
      onSurface: AppColorScheme.goldTextPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColorScheme.goldBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorScheme.goldSurface,
      foregroundColor: AppColorScheme.goldTextPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColorScheme.goldSurface,
    ),
    buttonTheme: const ButtonThemeData(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColorScheme.goldMid,
        foregroundColor: AppColorScheme.goldOnPrimary,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColorScheme.goldTextPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColorScheme.goldTextPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColorScheme.goldTextPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColorScheme.goldTextPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColorScheme.goldTextPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColorScheme.goldTextPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColorScheme.goldTextSecondary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColorScheme.goldTextSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColorScheme.goldTextDisabled,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColorScheme.goldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColorScheme.goldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColorScheme.goldMid),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
      filled: true,
      fillColor: AppColorScheme.goldSurface,
    ),
  );

  static ThemeData pinkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColorScheme.pinkMid,
      secondary: AppColorScheme.pinkEnd,
      background: AppColorScheme.pinkBackground,
      surface: AppColorScheme.pinkSurface,
      error: Color(0xFFD32F2F),
      onPrimary: AppColorScheme.pinkOnPrimary,
      onSecondary: AppColorScheme.pinkTextPrimary,
      onBackground: AppColorScheme.pinkTextPrimary,
      onSurface: AppColorScheme.pinkTextPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColorScheme.pinkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorScheme.pinkSurface,
      foregroundColor: AppColorScheme.pinkTextPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColorScheme.pinkSurface,
    ),
    buttonTheme: const ButtonThemeData(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColorScheme.pinkMid,
        foregroundColor: AppColorScheme.pinkOnPrimary,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColorScheme.pinkTextPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColorScheme.pinkTextPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColorScheme.pinkTextPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColorScheme.pinkTextPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColorScheme.pinkTextPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColorScheme.pinkTextPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColorScheme.pinkTextSecondary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColorScheme.pinkTextSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColorScheme.pinkTextDisabled,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColorScheme.pinkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColorScheme.pinkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColorScheme.pinkMid),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
      filled: true,
      fillColor: AppColorScheme.pinkSurface,
    ),
  );
}
