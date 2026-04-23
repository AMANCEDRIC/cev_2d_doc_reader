import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Common Colors
  static const Color primary = Color(0xFF38BDF8); 
  static const Color accent = Color(0xFF818CF8);
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  
  // Dark Palette
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Light Palette
  static const Color lightBg = Color(0xFFF1F5F9);
  static const Color lightCard = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? darkBg : lightBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: accent,
        surface: isDark ? darkCard : lightCard,
        onSurface: isDark ? darkTextPrimary : lightTextPrimary,
        surfaceContainerHighest: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      ),
      textTheme: GoogleFonts.interTextTheme(
        (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.copyWith(
          displayLarge: TextStyle(
            color: isDark ? darkTextPrimary : lightTextPrimary, 
            fontWeight: FontWeight.bold
          ),
          bodyLarge: TextStyle(
            color: isDark ? darkTextPrimary : lightTextPrimary
          ),
          bodyMedium: TextStyle(
            color: isDark ? darkTextSecondary : lightTextSecondary
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? darkCard : lightCard,
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? darkTextPrimary : lightTextPrimary,
          side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkCard : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
        ),
      ),
    );
  }
}
