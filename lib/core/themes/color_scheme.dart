// lib/core/themes/color_scheme.dart
import 'package:flutter/material.dart';

class AppColorScheme {
  // Primary Colors (modern violet accents)
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryVariant = Color(0xFF6D28D9);
  static const Color secondary = Color(0xFF22D3EE);
  static const Color secondaryVariant = Color(0xFF0891B2);
  
  // UI Colors
  static const Color background = Color(0xFF14101F);
  static const Color surface = Color(0xFF1C182B);
  static const Color error = Color(0xFFCF6679);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Colors.white;
  static const Color onSurface = Colors.white;
  static const Color onError = Colors.black;
  
  // Functional Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Gradient Colors
  static const List<Color> accuracyGradient = [
    Color(0xFFF44336), // Red
    Color(0xFFFF9800), // Orange
    Color(0xFF4CAF50), // Green
  ];
  
  static const List<Color> premiumGradient = [
    Color(0xFFFFD700), // Gold
    Color(0xFFFFC107), // Amber
    Color(0xFFFF9800), // Orange
  ];

  // Gold Theme Colors
  static const Color goldStart = Color(0xFFF9E076);
  static const Color goldMid = Color(0xFFD4AF37);
  static const Color goldEnd = Color(0xFF996515);
  static const List<Color> goldGradient = [
    goldStart,
    goldMid,
    goldEnd,
  ];
  static const Color goldBackground = Color(0xFFFFF4D6);
  static const Color goldSurface = Color(0xFFFFE7A6);
  static const Color goldOnPrimary = Color(0xFF2B1D0A);
  static const Color goldTextPrimary = Color(0xFF2B1D0A);
  static const Color goldTextSecondary = Color(0xFF5A3E14);
  static const Color goldTextDisabled = Color(0xFF9C7B39);
  static const Color goldBorder = Color(0xFFE0C16A);

  // Pink Theme Colors
  static const Color pinkStart = Color(0xFFFFB6C1);
  static const Color pinkMid = Color(0xFFFF69B4);
  static const Color pinkEnd = Color(0xFFDB7093);
  static const List<Color> pinkGradient = [
    pinkStart,
    pinkMid,
    pinkEnd,
  ];
  static const Color pinkBackground = Color(0xFFFFF0F3);
  static const Color pinkSurface = Color(0xFFFFE0E6);
  static const Color pinkOnPrimary = Color(0xFF3D0F1E);
  static const Color pinkTextPrimary = Color(0xFF3D0F1E);
  static const Color pinkTextSecondary = Color(0xFF6B2540);
  static const Color pinkTextDisabled = Color(0xFFA8607A);
  static const Color pinkBorder = Color(0xFFEEA0B0);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF5F3FF);
  static const Color textSecondary = Color(0xFFD6CCFF);
  static const Color textDisabled = Color(0xFF8E83B5);
  
  // Border Colors
  static const Color borderLight = Color(0xFF332E48);
  static const Color borderDark = Color(0xFF241F36);
  
  // Shadow Colors
  static const Color shadow = Color(0x40000000);
  
  // Transparent Colors
  static const Color transparent = Color(0x00000000);
  static const Color semiTransparent = Color(0x80000000);
  static const Color lightTransparent = Color(0x20000000);
}
