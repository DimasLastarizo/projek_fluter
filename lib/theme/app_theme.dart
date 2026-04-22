import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette: Deep Navy + Emerald Green + Warm Cream
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color accentEmerald = Color(0xFF00C896);
  static const Color warmCream = Color(0xFFF5F0E8);
  static const Color cardDark = Color(0xFF1A2E42);
  static const Color cardMedium = Color(0xFF243B55);
  static const Color expenseRed = Color(0xFFFF6B6B);
  static const Color incomeGreen = Color(0xFF00C896);
  static const Color textLight = Color(0xFFE8F4F8);
  static const Color textMuted = Color(0xFF8BA5BC);
  static const Color divider = Color(0xFF1F3448);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: primaryNavy,
      colorScheme: const ColorScheme.dark(
        primary: accentEmerald,
        secondary: warmCream,
        surface: cardDark,
        onPrimary: primaryNavy,
        onSurface: textLight,
      ),
      fontFamily: 'SF Pro Display',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: warmCream,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          color: warmCream,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.0,
        ),
        bodyLarge: TextStyle(color: textLight, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(color: textMuted, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(color: accentEmerald, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: warmCream,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: warmCream),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentEmerald,
          foregroundColor: primaryNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentEmerald, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      ),
    );
  }
}