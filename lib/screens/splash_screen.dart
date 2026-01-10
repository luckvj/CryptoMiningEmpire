import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../widgets/crypto_empire_logo.dart';
import 'home_screen.dart';

// Conditional import for web interop
import '../core/utils/web_stub.dart'
    if (dart.library.html) '../core/utils/web_interop_web.dart';

/// Cyberpunk-themed splash screen with stunning animations
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _gridController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _progressController;
  
  final List<Particle> _particles = [];
  final Random _random = Random();
  
  // Reduce animations on mobile for performance
  bool get _isLowPerformanceMode => !kIsWeb;
  
  @override
  void initState() {
    super.initState();
    
    // Grid animation controller - skip on mobile for performance
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    if (!_isLowPerformanceMode) _gridController.repeat();
    
    // Pulse ring animation - use only on web
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (!_isLowPerformanceMode) _pulseController.repeat();
    
    // Particle animation - reduce on mobile
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    if (!_isLowPerformanceMode) _particleController.repeat();
    
    // Progress bar animation - always run
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
    
    // Generate fewer particles on mobile
    _generateParticles();
    
    _navigateToHome();

    // Remove the HTML loading screen now that Flutter is rendering (web only)
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 1), () {
          removeHtmlLoadingScreen();
        });
      });
    }
  }
  
  void _generateParticles() {
    // Much fewer particles on mobile for performance
    final particleCount = _isLowPerformanceMode ? 10 : 50;
    for (int i = 0; i < particleCount; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 1,
        speed: _random.nextDouble() * 0.3 + 0.1,
        opacity: _random.nextDouble() * 0.5 + 0.2,
      ));
    }
  }
  
  @override
  void dispose() {
    _gridController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _progressController.dispose();
    super.dispose();
  }
  
  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Grid Background - skip on mobile for performance
          if (!_isLowPerformanceMode)
            AnimatedBuilder(
              animation: _gridController,
              builder: (context, child) {
                return CustomPaint(
                  painter: GridPainter(
                    animation: _gridController.value,
                    primaryColor: CyberpunkTheme.primaryBlue,
                    secondaryColor: CyberpunkTheme.accentPurple,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          
          // Floating Particles - skip on mobile for performance
          if (!_isLowPerformanceMode)
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    particles: _particles,
                    animation: _particleController.value,
                    color: CyberpunkTheme.accentCyan,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.transparent,
                  CyberpunkTheme.backgroundDark.withOpacity(0.7),
                  CyberpunkTheme.backgroundDark,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
          
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing Rings + Logo
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulse rings
                    ...List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final delay = index * 0.3;
                          final progress = (_pulseController.value + delay) % 1.0;
                          final scale = 1.0 + progress * 0.8;
                          final opacity = (1.0 - progress) * 0.5;
                          
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: CyberpunkTheme.primaryBlue.withOpacity(opacity),
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                    
                    // Inner glow
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: CyberpunkTheme.primaryBlue.withOpacity(0.4),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                          BoxShadow(
                            color: CyberpunkTheme.accentPurple.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    
                    // Logo
                    const CryptoEmpireLogo(size: 150)
                      .animate()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.0, 1.0),
                        duration: 800.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 400.ms),
                  ],
                ),
                
                const SizedBox(height: 50),
                
                // App Title - STUPID
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      CyberpunkTheme.primaryBlue,
                      CyberpunkTheme.accentCyan,
                      CyberpunkTheme.primaryBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'STUPID',
                    style: GoogleFonts.orbitron(
                      fontSize: 38, // Slightly larger
                      fontWeight: FontWeight.w900, // Extra bold
                      color: Colors.white,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(
                          color: CyberpunkTheme.primaryBlue.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ).animate()
                  .fadeIn(duration: 600.ms, delay: 300.ms)
                  .slideY(begin: -0.3, end: 0)
                  .then()
                  .shimmer(duration: 2000.ms, delay: 500.ms),
                
                // App Title - RIGGER
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      CyberpunkTheme.accentOrange,
                      CyberpunkTheme.accentRed,
                      CyberpunkTheme.accentOrange,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'RIGGER',
                    style: GoogleFonts.orbitron(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 12,
                    ),
                  ),
                ).animate()
                  .fadeIn(duration: 600.ms, delay: 500.ms)
                  .slideY(begin: 0.3, end: 0)
                  .then()
                  .shimmer(duration: 2500.ms, delay: 300.ms),
                
                const SizedBox(height: 24),
                
                // Tagline
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTagPart('MINE', CyberpunkTheme.accentGreen, 600),
                    _buildDot(700),
                    _buildTagPart('BUILD', CyberpunkTheme.primaryBlue, 800),
                    _buildDot(900),
                    _buildTagPart('PROFIT', CyberpunkTheme.accentOrange, 1000),
                  ],
                ),
                
                const SizedBox(height: 80),
                
                // Animated Progress Bar
                SizedBox(
                  width: 280,
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Container(
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: CyberpunkTheme.surfaceColor,
                            ),
                            child: Stack(
                              children: [
                                // Progress fill
                                FractionallySizedBox(
                                  widthFactor: _progressController.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      gradient: LinearGradient(
                                        colors: [
                                          CyberpunkTheme.primaryBlue,
                                          CyberpunkTheme.accentCyan,
                                          CyberpunkTheme.accentGreen,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: CyberpunkTheme.primaryBlue.withOpacity(0.8),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Scanning effect
                                Positioned(
                                  left: _progressController.value * 280 - 20,
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.8),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Loading text sequence
                      _LoadingTextSequence(),
                    ],
                  ),
                ).animate()
                  .fadeIn(duration: 600.ms, delay: 800.ms),
              ],
            ),
          ),
          
          // Bottom version text
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Text(
              'v2.0.0',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: CyberpunkTheme.textTertiary.withOpacity(0.5),
              ),
            ).animate()
              .fadeIn(duration: 800.ms, delay: 1200.ms),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTagPart(String text, Color color, int delayMs) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 3,
        shadows: [
          Shadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: Duration(milliseconds: delayMs));
  }
  
  Widget _buildDot(int delayMs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CyberpunkTheme.textTertiary,
          boxShadow: [
            BoxShadow(
              color: CyberpunkTheme.primaryBlue.withOpacity(0.5),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: Duration(milliseconds: delayMs))
      .scale(begin: const Offset(0, 0), end: const Offset(1, 1));
  }
}

/// Loading text that cycles through messages
class _LoadingTextSequence extends StatefulWidget {
  @override
  State<_LoadingTextSequence> createState() => _LoadingTextSequenceState();
}

class _LoadingTextSequenceState extends State<_LoadingTextSequence> {
  final List<String> _messages = [
    'Initializing Neural Network...',
    'Connecting to Blockchain...',
    'Loading Market Data...',
    'Preparing Mining Rigs...',
  ];
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _cycleMessages();
  }
  
  void _cycleMessages() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _messages.length;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _messages[_currentIndex],
        key: ValueKey(_currentIndex),
        style: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          color: CyberpunkTheme.textTertiary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// Particle data class
class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  
  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

/// Custom painter for animated grid background
class GridPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color secondaryColor;
  
  GridPainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    const gridSize = 40.0;
    final offset = animation * gridSize;
    
    // Horizontal lines
    for (double y = -gridSize + offset % gridSize; y < size.height + gridSize; y += gridSize) {
      final opacity = (sin((y / size.height) * pi) * 0.3).abs();
      paint.color = primaryColor.withOpacity(opacity * 0.15);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Vertical lines
    for (double x = -gridSize + offset % gridSize; x < size.width + gridSize; x += gridSize) {
      final opacity = (sin((x / size.width) * pi) * 0.3).abs();
      paint.color = secondaryColor.withOpacity(opacity * 0.15);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Highlight some intersections
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (double x = offset % gridSize; x < size.width; x += gridSize * 2) {
      for (double y = offset % gridSize; y < size.height; y += gridSize * 2) {
        final distance = sqrt(pow(x - size.width / 2, 2) + pow(y - size.height / 2, 2));
        final maxDistance = sqrt(pow(size.width / 2, 2) + pow(size.height / 2, 2));
        final opacity = (1 - distance / maxDistance) * 0.4;
        
        dotPaint.color = primaryColor.withOpacity(opacity);
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}

/// Custom painter for floating particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;
  final Color color;
  
  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      // Update position (move upward)
      final y = (particle.y - animation * particle.speed) % 1.0;
      final x = particle.x + sin(animation * pi * 2 + particle.y * 10) * 0.02;
      
      final position = Offset(x * size.width, y * size.height);
      
      // Draw glow
      paint.color = color.withOpacity(particle.opacity * 0.3);
      canvas.drawCircle(position, particle.size * 3, paint);
      
      // Draw core
      paint.color = color.withOpacity(particle.opacity);
      canvas.drawCircle(position, particle.size, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}
