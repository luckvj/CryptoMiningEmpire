import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern 2026 Glassmorphism Design System
/// Features: Frosted glass cards, aurora gradients, soft glow effects
class CyberpunkTheme {
  // Primary Colors - Vibrant Neon on Deep Black
  static const Color primaryBlue = Color(0xFF00D9FF); // Electric cyan
  static const Color primaryDark = Color(0xFF0099CC);
  static const Color primaryLight = Color(0xFF33E0FF);
  
  // Background Colors - Deep Space with Aurora Hints
  static const Color backgroundDark = Color(0xFF000000); // Pure black
  static const Color backgroundLight = Color(0xFF050510); // Near black with blue tint
  static const Color surfaceColor = Color(0xFF0A0A18); // Dark panel with subtle depth
  static const Color backgroundWhite = Color(0xFF050508);
  
  // Accent Colors - Aurora/Neon Palette
  static const Color accentGreen = Color(0xFF00FF88); // Neon green
  static const Color accentRed = Color(0xFFFF0055); // Hot pink/red
  static const Color accentOrange = Color(0xFFFFAA00); // Amber glow
  static const Color accentPurple = Color(0xFFAA00FF); // Electric purple
  static const Color accentCyan = Color(0xFF00FFFF); // Pure cyan
  static const Color accentPink = Color(0xFFFF00AA); // Hot pink
  
  // Text Colors - High Contrast for Glass Readability
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondary = Color(0xFFE0E0E0); // Brighter secondary
  static const Color textTertiary = Color(0xFFA0A0A0); // Medium grey
  
  // Glass Effect Colors
  static const Color glassWhite = Color(0x0DFFFFFF); // 5% white for glass
  static const Color glassBorder = Color(0x1AFFFFFF); // 10% white border
  static const Color borderColor = Color(0xFF1A1A2E);
  static const Color dividerColor = Color(0xFF252540);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF94A3B8);
  
  // Gradient Definitions - Server Light Glows
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D9FF), Color(0xFF0099CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00FF88), Color(0xFF00CC66)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0A0A0A), Color(0xFF111111)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x20111111), Color(0x10222222)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Server Light Glow Effects
  static const LinearGradient serverGlowCyan = LinearGradient(
    colors: [Color(0x4000D9FF), Color(0x0000D9FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient serverGlowGreen = LinearGradient(
    colors: [Color(0x4000FF88), Color(0x0000FF88)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient serverGlowOrange = LinearGradient(
    colors: [Color(0x40FFAA00), Color(0x00FFAA00)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
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
  
  // Theme Data - Modern Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentGreen,
        tertiary: accentPurple,
        surface: lightSurface,
        background: lightBackground,
        error: accentRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onBackground: lightTextPrimary,
      ),
      
      // Text Theme - Clean & Readable
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: lightTextPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: lightTextPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: lightTextPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: lightTextSecondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: lightTextTertiary,
        ),
      ),
      
      // Card Theme - Light with Shadows
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: lightBorder,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // AppBar Theme - Light
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: lightTextPrimary),
      ),
      
      // Button Themes
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
          side: const BorderSide(color: lightBorder, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration - Light
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: lightTextSecondary),
        hintStyle: GoogleFonts.inter(color: lightTextTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  // Custom Box Decoration for Data Center Server Panels
  static BoxDecoration modernCard({
    Color? backgroundColor,
    bool withShadow = true,
    bool withGlow = false,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? backgroundLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: withGlow ? (glowColor ?? primaryBlue).withOpacity(0.5) : borderColor,
        width: withGlow ? 1.5 : 1,
      ),
      boxShadow: withShadow ? [
        BoxShadow(
          color: Colors.black.withOpacity(0.8),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        if (withGlow)
          BoxShadow(
            color: (glowColor ?? primaryBlue).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
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
  
  // Premium Glassmorphism Card with blur effect
  static BoxDecoration premiumGlassCard({
    Color? glowColor,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: surfaceColor.withOpacity(0.8),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: (glowColor ?? primaryBlue).withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: (glowColor ?? primaryBlue).withOpacity(0.1),
          blurRadius: 30,
          spreadRadius: 2,
        ),
      ],
    );
  }
  
  // Holographic gradient for special elements
  static LinearGradient holographicGradient({
    double shift = 0.0,
  }) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryBlue,
        accentCyan,
        accentPurple,
        accentOrange,
        primaryBlue,
      ],
      stops: [
        0.0 + shift,
        0.25 + shift,
        0.5 + shift,
        0.75 + shift,
        1.0,
      ].map((s) => s.clamp(0.0, 1.0)).toList().cast<double>(),
    );
  }
  
  // Animated glow border decoration
  static BoxDecoration animatedBorderCard({
    Color? borderColor,
    double glowIntensity = 0.5,
  }) {
    final color = borderColor ?? primaryBlue;
    return BoxDecoration(
      color: backgroundLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: color.withOpacity(0.6),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.6),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: color.withOpacity(glowIntensity * 0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: color.withOpacity(glowIntensity * 0.2),
          blurRadius: 40,
          spreadRadius: 4,
        ),
      ],
    );
  }
  
  // Stats card with accent color
  static BoxDecoration statsCard({
    required Color accentColor,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          surfaceColor,
          accentColor.withOpacity(0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: accentColor.withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: accentColor.withOpacity(0.15),
          blurRadius: 20,
        ),
      ],
    );
  }
  
  // Neon text shadow
  static List<Shadow> neonTextShadow(Color color, {double intensity = 1.0}) {
    return [
      Shadow(
        color: color.withOpacity(0.8 * intensity),
        blurRadius: 10,
      ),
      Shadow(
        color: color.withOpacity(0.5 * intensity),
        blurRadius: 20,
      ),
      Shadow(
        color: color.withOpacity(0.3 * intensity),
        blurRadius: 40,
      ),
    ];
  }
  
  // Mining button gradient
  static RadialGradient miningButtonGradient({
    double pulseValue = 0.0,
  }) {
    return RadialGradient(
      colors: [
        Color.lerp(primaryBlue, accentCyan, pulseValue) ?? primaryBlue,
        accentPurple,
        Color.lerp(accentOrange, accentRed, pulseValue) ?? accentOrange,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
  
  // Floating action button style
  static BoxDecoration fabDecoration({
    bool isPressed = false,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isPressed
          ? [accentGreen, primaryBlue]
          : [primaryBlue, accentPurple],
      ),
      boxShadow: [
        BoxShadow(
          color: primaryBlue.withOpacity(isPressed ? 0.8 : 0.5),
          blurRadius: isPressed ? 30 : 20,
          spreadRadius: isPressed ? 5 : 2,
        ),
      ],
    );
  }
  
  // ==========================================
  // GLASSMORPHISM DECORATIONS (2026 Style)
  // ==========================================
  


  /// Matrix Code Background (Dark & Green)
  static BoxDecoration serverRoomBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          backgroundDark,
          Color(0xFF050510), // Even darker at bottom
        ],
      ),
    );
  }

  /// Premium frosted glass card with blur effect
  static BoxDecoration glassmorphismCard({
    Color? glowColor,
    double borderOpacity = 0.2, // Increased from 0.15
    double glowIntensity = 0.3, // Increased from 0.2
  }) {
    final glow = glowColor ?? primaryBlue;
    return BoxDecoration(
      color: Colors.black.withOpacity(0.6), // Darker, more "solid" glass
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: glow.withOpacity(borderOpacity),
        width: 1.5,
      ),
      boxShadow: [
        // Outer glow
        BoxShadow(
          color: glow.withOpacity(glowIntensity),
          blurRadius: 30,
          spreadRadius: 2,
        ),
        // Depth shadow
        BoxShadow(
          color: Colors.black.withOpacity(0.8),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
  
  /// Aurora gradient background for screens
  static BoxDecoration auroraBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF000000),
          Color(0xFF050515),
          Color(0xFF0A0520),
          Color(0xFF050510),
          Color(0xFF000000),
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
    );
  }
  
  /// Animated aurora overlay for backgrounds
  static BoxDecoration auroraOverlay({double opacity = 0.3}) {
    return BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(-0.5, -0.5),
        radius: 1.5,
        colors: [
          accentPurple.withOpacity(opacity * 0.3),
          accentCyan.withOpacity(opacity * 0.2),
          Colors.transparent,
        ],
      ),
    );
  }
  
  /// Glass navigation bar decoration
  static BoxDecoration glassNavBar() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryBlue.withOpacity(0.15),
          blurRadius: 30,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 20,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
  
  /// Glass stat card with colored accent
  static BoxDecoration glassStatCard({
    required Color accentColor,
    double glowIntensity = 0.3,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.08),
          accentColor.withOpacity(0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: accentColor.withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: accentColor.withOpacity(glowIntensity),
          blurRadius: 25,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
  
  /// Glowing border effect for interactive elements
  static BoxDecoration glowingBorder({
    required Color color,
    double intensity = 0.5,
    double borderWidth = 2,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: color.withOpacity(0.8),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(intensity * 0.5),
          blurRadius: 15,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: color.withOpacity(intensity * 0.3),
          blurRadius: 30,
          spreadRadius: 4,
        ),
      ],
    );
  }
  
  /// Frosted glass header card
  static BoxDecoration glassHeader() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentPurple.withOpacity(0.15),
          primaryBlue.withOpacity(0.1),
          accentCyan.withOpacity(0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Colors.white.withOpacity(0.15),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: accentPurple.withOpacity(0.2),
          blurRadius: 40,
          offset: const Offset(-10, -10),
        ),
        BoxShadow(
          color: primaryBlue.withOpacity(0.15),
          blurRadius: 40,
          offset: const Offset(10, 10),
        ),
      ],
    );
  }
  
  /// Particle/sparkle decoration overlay
  static BoxDecoration particleOverlay() {
    return BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(0.7, -0.6),
        radius: 0.8,
        colors: [
          Colors.white.withOpacity(0.03),
          Colors.transparent,
        ],
      ),
    );
  }
}
