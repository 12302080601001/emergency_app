import 'package:flutter/material.dart';

class AppTheme {
  // Deep Crimson/Red (#E63946)
  static const Color emergencyRed = Color(0xFFE63946);
  // Slate Dark (#1D3557)
  static const Color slateDark = Color(0xFF1D3557);
  static const Color softPastelRed = Color(0xFFF1FAEE); // Soft pastel cream/white
  static const Color lightBlue = Color(0xFFA8DADC);
  static const Color midBlue = Color(0xFF457B9D);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: slateDark,
      scaffoldBackgroundColor: slateDark,
      colorScheme: const ColorScheme.dark(
        primary: emergencyRed,
        secondary: lightBlue,
        surface: darkSurface,
        error: emergencyRed,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: softPastelRed),
        titleLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: softPastelRed),
        bodyLarge: TextStyle(fontSize: 16.0, color: softPastelRed),
        bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white70),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emergencyRed,
          foregroundColor: softPastelRed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }
}
