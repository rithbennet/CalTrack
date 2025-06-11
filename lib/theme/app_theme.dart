import 'package:flutter/material.dart';

class AppTheme {
  // Primary tints from the image - orange colors for buttons, links, and primary elements
  static const Color primary = Color(0xFFFF6200); // Primary - a0
  static const Color primaryA10 = Color(0xFFFF762B); // Primary - a10
  static const Color primaryA20 = Color(0xFFFF8847); // Primary - a20
  static const Color primaryA30 = Color(0xFFFF9A61); // Primary - a30
  static const Color primaryA40 = Color(0xFFFFA87B); // Primary - a40
  static const Color primaryA50 = Color(0xFFFFBC95); // Primary - a50

  // Surface colors from the image - for cards, backgrounds, and surface elements
  static const Color surface = Color(0xFF121212); // Surface - a0
  static const Color surfaceA10 = Color(0xFF282828); // Surface - a10
  static const Color surfaceA20 = Color(0xFF3F3F3F); // Surface - a20
  static const Color surfaceA30 = Color(0xFF575757); // Surface - a30
  static const Color surfaceA40 = Color(0xFF717171); // Surface - a40
  static const Color surfaceA50 = Color(0xFF8B8B8B); // Surface - a50

  // Create the light theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: primaryA30,
        tertiary: primaryA50,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        floatingLabelStyle: const TextStyle(color: primary),
      ),
    );
  }

  // Create the dark theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.white,
        secondary: primaryA30,
        tertiary: primaryA50,
        surface: surfaceA10,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryA30),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceA10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceA10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        floatingLabelStyle: const TextStyle(color: primary),
        filled: true,
        fillColor: surfaceA20,
      ),
    );
  }
}
