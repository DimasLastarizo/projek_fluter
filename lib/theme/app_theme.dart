import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette: Arknights terminal black, white, grey, and signal yellow.
  static const Color voidBlack = Color(0xFF0F1010);
  static const Color paperWhite = Color(0xFFF7F7F2);
  static const Color ashGrey = Color(0xFF838782);
  static const Color coolGrey = Color(0xFFB9C1C0);
  static const Color charcoal = Color(0xFF2A2D2E);
  static const Color gunmetal = Color(0xFF1C1F20);
  static const Color panelGrey = Color(0xFF3A3F40);
  static const Color tacticalOlive = Color(0xFF657136);
  static const Color signalYellow = Color(0xFFF8E946);
  static const Color terminalCyan = Color(0xFF35BEE8);

  static const Color primaryNavy = charcoal;
  static const Color accentEmerald = signalYellow;
  static const Color warmCream = paperWhite;
  static const Color cardDark = voidBlack;
  static const Color cardMedium = gunmetal;
  static const Color expenseRed = signalYellow;
  static const Color incomeGreen = terminalCyan;
  static const Color textLight = paperWhite;
  static const Color textMuted = coolGrey;
  static const Color divider = Color(0x77838782);
  static const Color backgroundGradientEnd = panelGrey;
  static const Color cardGradientStart = gunmetal;
  static const Color inputHintGhost = Color(0x55B9C1C0);
  static const Color shadow = Color(0x99000000);

  static const double panelRadius = 4;
  static const double controlRadius = 2;

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: primaryNavy,
      colorScheme: const ColorScheme.dark(
        primary: accentEmerald,
        secondary: terminalCyan,
        surface: cardDark,
        onPrimary: primaryNavy,
        onSurface: textLight,
        error: expenseRed,
      ),
      fontFamily: 'SF Pro Display',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: warmCream,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        displayMedium: TextStyle(
          color: warmCream,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        bodyLarge: TextStyle(color: textLight, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(color: textMuted, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(
          color: accentEmerald,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardMedium,
        elevation: 10,
        shadowColor: shadow,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: warmCream,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        iconTheme: IconThemeData(color: warmCream),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentEmerald,
          foregroundColor: primaryNavy,
          elevation: 12,
          shadowColor: shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(controlRadius)),
          ),
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
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: const BorderSide(color: divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: const BorderSide(color: accentEmerald, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      ),
    );
  }
}
