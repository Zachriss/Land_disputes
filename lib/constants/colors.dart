import 'package:flutter/material.dart';

/// App theme colors
class AppColors {
  static const Color primaryColor = Color(0xFF1B5E20);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color borderColor = Color(0xFFBDBDBD);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);
  static const Color dividerColor = Color(0xFFBDBDBD);
  static const Color statusBarColor = Color(0xFF1B5E20);

  static const ColorScheme colorScheme = ColorScheme(
    primary: primaryColor,
    onPrimary: Colors.white,
    secondary: secondaryColor,
    onSecondary: Colors.white,
    surface: cardColor,
    onSurface: textColor,
    error: errorColor,
    onError: Colors.white,
    brightness: Brightness.light,
  );
}