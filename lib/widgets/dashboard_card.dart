import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';

/// Premium glassmorphism dashboard card with animated elements
class DashboardCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  
  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  
  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowIntensity = 0.2 + _glowController.value * 0.15;
        
        return Container(
          decoration: CyberpunkTheme.glassStatCard(
            accentColor: widget.color,
            glowIntensity: glowIntensity,
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Animated icon with glow
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(glowIntensity * 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 22,
                      shadows: [
                        Shadow(
                          color: widget.color.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Trend indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CyberpunkTheme.accentGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CyberpunkTheme.accentGreen.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          color: CyberpunkTheme.accentGreen,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'LIVE',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: CyberpunkTheme.accentGreen,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(begin: 0.7, end: 1.0, duration: 1500.ms),
                ],
              ),
              const SizedBox(height: 14),
              // Title with subtle animation
              Text(
                widget.title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: CyberpunkTheme.textTertiary,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              // Value display - using solid red for negative or Gradient for positive
              widget.color == CyberpunkTheme.accentRed 
              ? Text(
                  widget.value,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CyberpunkTheme.accentRed,
                    shadows: CyberpunkTheme.neonTextShadow(CyberpunkTheme.accentRed, intensity: 0.5),
                  ),
                )
              : ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      widget.color,
                      widget.color.withOpacity(0.8),
                      widget.color,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: Text(
                    widget.value,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: CyberpunkTheme.neonTextShadow(widget.color, intensity: 0.3),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }
}

/// Compact stat card for smaller displays
class CompactStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  
  const CompactStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: CyberpunkTheme.premiumGlassCard(glowColor: color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: CyberpunkTheme.textTertiary,
                  letterSpacing: 1,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dedicated Hash Rate Dashboard Card with Tap-to-Cycle functionality
class HashRateDashboardCard extends StatefulWidget {
  final double totalHashRate;
  
  const HashRateDashboardCard({
    super.key,
    required this.totalHashRate,
  });

  @override
  State<HashRateDashboardCard> createState() => _HashRateDashboardCardState();
}

class _HashRateDashboardCardState extends State<HashRateDashboardCard> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  int _unitIndex = 0; // 0=auto, 1=MH/s, 2=GH/s, 3=TH/s
  
  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _cycleUnit() {
    setState(() {
      _unitIndex = (_unitIndex + 1) % 4;
    });
  }

  String _getFormattedHashRate() {
    final rate = widget.totalHashRate;
    switch (_unitIndex) {
      case 1: return '${rate.toStringAsFixed(2)} MH/s';
      case 2: return '${(rate / 1000).toStringAsFixed(4)} GH/s';
      case 3: return '${(rate / 1000000).toStringAsFixed(6)} TH/s';
      default:
        // Auto
        if (rate >= 1000000) return '${(rate / 1000000).toStringAsFixed(2)} TH/s';
        if (rate >= 1000) return '${(rate / 1000).toStringAsFixed(2)} GH/s';
        return '${rate.toStringAsFixed(2)} MH/s';
    }
  }

  String _getCurrentUnitLabel() {
    return ['AUTO', 'MH/s', 'GH/s', 'TH/s'][_unitIndex];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowIntensity = 0.3 + _glowController.value * 0.2;
        final color = CyberpunkTheme.accentOrange;
        
        return GestureDetector(
          onTap: _cycleUnit,
          child: Container(
            decoration: CyberpunkTheme.glassStatCard(
              accentColor: color,
              glowIntensity: glowIntensity,
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Animated icon with glow
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(glowIntensity * 0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.speed,
                        color: color,
                        size: 22,
                        shadows: [
                          Shadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Unit indicator badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getCurrentUnitLabel(),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Title
                Text(
                  'HASH RATE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: CyberpunkTheme.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                // Value
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _getFormattedHashRate(),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CyberpunkTheme.textPrimary,
                      shadows: [
                        Shadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Tap hint
                Text(
                  'tap to cycle',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    color: CyberpunkTheme.textTertiary.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
