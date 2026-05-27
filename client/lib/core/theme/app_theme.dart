import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const ink = Color(0xFF111827);
    const coral = Color(0xFFE85D4F);
    const teal = Color(0xFF168B82);
    const paper = Color(0xFFF8F7F3);

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: coral,
        primary: coral,
        secondary: teal,
        surface: paper,
        onSurface: ink,
      ),
      scaffoldBackgroundColor: paper,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
