import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/cyberpunk_theme.dart';

/// Custom painted Crypto Mining Empire logo with neon cyberpunk aesthetics
class CryptoEmpireLogo extends StatelessWidget {
  final double size;
  
  const CryptoEmpireLogo({
    super.key,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        // Optional: Add a subtle glow behind the image if needed
        boxShadow: [
          BoxShadow(
            color: CyberpunkTheme.primaryBlue,
            blurRadius: 20,
            spreadRadius: -5,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
          width: size,
          height: size,
        ),
      ),
    );
  }
}
