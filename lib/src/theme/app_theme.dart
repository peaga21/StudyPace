import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF14B8A6);
  static const Color secondaryColor = Color(0xFFF59E0B);
  static const Color surfaceColorLight = Color(0xFFFFFFFF);
  static const Color surfaceColorDark = Color(0xFF1F2937);
  static const Color textColorLight = Color(0xFF1F2937);
  static const Color textColorDark = Color(0xFFE5E7EB);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: surfaceColorLight,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColorLight,
        foregroundColor: textColorLight,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: surfaceColorDark,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColorDark,
        foregroundColor: textColorDark,
        elevation: 0,
      ),
    );
  }
}