import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import 'home_screen.dart';

/// Cyberpunk-themed splash screen with animations
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }
  
  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CyberpunkTheme.backgroundLight,
              CyberpunkTheme.surfaceColor,
              CyberpunkTheme.accentPurple.withOpacity(0.2),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glowing Logo Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: CyberpunkTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: CyberpunkTheme.primaryBlue.withOpacity(0.6),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.currency_bitcoin,
                  size: 60,
                  color: CyberpunkTheme.textPrimary,
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms)
                .then()
                .shake(duration: 500.ms),
              
              const SizedBox(height: 40),
              
              // App Title
              Text(
                'CRYPTO MINING',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: CyberpunkTheme.primaryBlue,
                  letterSpacing: 4,
                  ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.3, end: 0),
              
              Text(
                'EMPIRE',
                style: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: CyberpunkTheme.accentOrange,
                  letterSpacing: 8,
                  ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 20),
              
              // Tagline
              Text(
                'MINE • TRADE • DOMINATE',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: CyberpunkTheme.accentGreen,
                  letterSpacing: 3,
                  ),
              ).animate()
                .fadeIn(duration: 800.ms, delay: 400.ms),
              
              const SizedBox(height: 60),
              
              // Loading Indicator
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: CyberpunkTheme.surfaceColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    CyberpunkTheme.primaryBlue,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1500.ms),
              
              const SizedBox(height: 20),
              
              Text(
                'Initializing Neural Network...',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: CyberpunkTheme.textTertiary,
                  letterSpacing: 1,
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 800.ms)
                .then()
                .fadeOut(duration: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
