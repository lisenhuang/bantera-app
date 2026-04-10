import 'package:flutter/material.dart';

class BanteraTheme {
  static const Color primaryColor = Color(0xFF6B4EE6); // Audio-focused deep purple
  static const Color secondaryColor = Color(0xFF00C896); // Contrast accent (Mint)
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color surfaceColorLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF1E1E24);
  static const Color textSecondaryLight = Color(0xFF71717A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundLight,
        surface: surfaceColorLight,
        onSurface: textPrimaryLight,
        onBackground: textPrimaryLight,
        outline: Color(0xFFCACACE),
        outlineVariant: Color(0xFFDCDCE0),
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColorLight,
        foregroundColor: textPrimaryLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColorLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xFFD4D4D8),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryLight),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimaryLight),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimaryLight),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimaryLight, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondaryLight, height: 1.4),
      ),
      cardTheme: CardThemeData(
        color: surfaceColorLight,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceColorDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFFA1A1AA);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF8A72F6), // slightly lighter purple for dark mode contrast
        secondary: Color(0xFF00FFC2), // slightly brighter mint 
        background: backgroundDark,
        surface: surfaceColorDark,
        onSurface: textPrimaryDark,
        onBackground: textPrimaryDark,
        outline: Color(0xFF52525B),
        outlineVariant: Color(0xFF3F3F46),
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColorDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF8A72F6)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColorDark,
        selectedItemColor: Color(0xFF8A72F6),
        unselectedItemColor: Color(0xFF52525B),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryDark),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimaryDark),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimaryDark),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimaryDark, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondaryDark, height: 1.4),
      ),
      cardTheme: CardThemeData(
        color: surfaceColorDark,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8A72F6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
