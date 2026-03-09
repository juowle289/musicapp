import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryBlack = Color(0xFF000000);
  static const Color darkBackground = Color(0xFF121212);
  static const Color accent = Color(0xFF03DAC6);
  static const Color darkAccent = Color(
    0xFFFEEC93,
  ); // Yellow accent for dark mode

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlack,
      secondary: accent,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: darkAccent,
      secondary: accent,
      brightness: Brightness.dark,
      surface: darkBackground,
    ),
    scaffoldBackgroundColor: darkBackground,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBackground,
      selectedItemColor: darkAccent,
      unselectedItemColor: Colors.grey,
    ),
  );
}
