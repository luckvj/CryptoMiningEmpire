import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern, clean design system with professional aesthetics
class CyberpunkTheme {
  // Modern Dark Theme - Sleek & Professional
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  
  // Background Colors - Modern Dark
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color backgroundLight = Color(0xFF1E293B);
  static const Color surfaceColor = Color(0xFF334155);
  static const Color backgroundWhite = Color(0xFF1E293B);
  
  // Accent Colors - Vibrant on Dark
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);
  
  // Text Colors - For Dark Theme
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  
  // Border & Divider - Subtle on Dark
  static const Color borderColor = Color(0xFF334155);
  static const Color dividerColor = Color(0xFF475569);
  
  // Gradient Definitions - Modern Dark Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x40334155), Color(0x20475569)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme Data - Modern Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentGreen,
        tertiary: accentPurple,
        surface: backgroundLight,
        background: backgroundDark,
        error: accentRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      
      // Text Theme - Clean & Readable
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: textTertiary,
        ),
      ),
      
      // Card Theme - Modern Dark with Glass Effect
      cardTheme: CardThemeData(
        color: backgroundLight,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // AppBar Theme - Modern Dark
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      
      // Button Themes - Modern & Subtle
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: primaryBlue.withOpacity(0.3),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: borderColor, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration - Modern Dark
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: textSecondary),
        hintStyle: GoogleFonts.inter(color: textTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  // Custom Box Decoration for Modern Dark Cards
  static BoxDecoration modernCard({
    Color? backgroundColor,
    bool withShadow = true,
    bool withGlow = false,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? backgroundLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: borderColor,
        width: 1,
      ),
      boxShadow: withShadow ? [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        if (withGlow)
          BoxShadow(
            color: primaryBlue.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
      ] : null,
    );
  }
  
  // Glass morphism card
  static BoxDecoration glassCard({
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      gradient: glassGradient,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: borderColor.withOpacity(0.3),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
  
  // Elevated Card with Gradient
  static BoxDecoration elevatedCard({
    Gradient? gradient,
  }) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: primaryBlue.withOpacity(0.2),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  // Status Color Helper
  static Color getStatusColor(bool isPositive) {
    return isPositive ? accentGreen : accentRed;
  }
  
  // Chip Decoration
  static BoxDecoration chipDecoration({
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? surfaceColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: borderColor ?? CyberpunkTheme.borderColor,
        width: 1,
      ),
    );
  }
}
