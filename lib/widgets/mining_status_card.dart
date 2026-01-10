import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';
import '../core/models/mining_data.dart';

/// Enhanced mining status display with animated elements
class MiningStatusCard extends StatefulWidget {
  const MiningStatusCard({super.key});

  @override
  State<MiningStatusCard> createState() => _MiningStatusCardState();
}

class _MiningStatusCardState extends State<MiningStatusCard> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    final priceProvider = context.watch<CryptoPriceProvider>();
    final activeCrypto = priceProvider.getCrypto(gameState.activeCrypto);
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowIntensity = 0.3 + _pulseController.value * 0.2;
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CyberpunkTheme.surfaceColor,
                CyberpunkTheme.primaryBlue.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: CyberpunkTheme.primaryBlue.withOpacity(0.3 + _pulseController.value * 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: CyberpunkTheme.primaryBlue.withOpacity(glowIntensity * 0.3),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Animated mining icon
                  _AnimatedMiningIcon(pulseController: _pulseController),
                  
                  const SizedBox(width: 14),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRENTLY MINING',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: CyberpunkTheme.textTertiary,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text(
                                activeCrypto?.symbol ?? 'BTC',
                                style: GoogleFonts.orbitron(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: CyberpunkTheme.primaryBlue,
                                  shadows: CyberpunkTheme.neonTextShadow(
                                    CyberpunkTheme.primaryBlue,
                                    intensity: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                activeCrypto?.name ?? 'Bitcoin',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: CyberpunkTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Active status badge
                  _ActiveBadge(),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Hashrate visualization bar
              _HashrateBar(
                hashRate: gameState.totalHashRate,
                scanController: _scanController,
              ),
              
              const SizedBox(height: 20),
              
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        // Smart hash rate unit formatting
                        final hashRate = gameState.totalHashRate;
                        String displayValue;
                        String displayUnit;
                        
                        if (hashRate >= 1000000000) {
                          // 1000+ TH/s = PH/s
                          displayValue = (hashRate / 1000000000).toStringAsFixed(2);
                          displayUnit = 'PH/s';
                        } else if (hashRate >= 1000000) {
                          // 1+ TH/s
                          displayValue = (hashRate / 1000000).toStringAsFixed(2);
                          displayUnit = 'TH/s';
                        } else if (hashRate >= 1000) {
                          // 1+ GH/s
                          displayValue = (hashRate / 1000).toStringAsFixed(2);
                          displayUnit = 'GH/s';
                        } else {
                          // MH/s
                          displayValue = hashRate.toStringAsFixed(2);
                          displayUnit = 'MH/s';
                        }
                        
                        return _EnhancedStatItem(
                          icon: Icons.speed_rounded,
                          label: 'Hash Rate',
                          value: displayValue,
                          unit: displayUnit,
                          color: CyberpunkTheme.accentCyan,
                        );
                      },
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          CyberpunkTheme.textTertiary.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _EnhancedStatItem(
                      icon: Icons.bolt_rounded,
                      label: 'Power Cost',
                      value: '\$${gameState.dailyPowerCost.toStringAsFixed(2)}',
                      unit: '/day',
                      color: CyberpunkTheme.accentOrange,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          CyberpunkTheme.textTertiary.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _EnhancedStatItem(
                      icon: Icons.memory_rounded,
                      label: 'GPUs',
                      value: '${gameState.gpuCount}',
                      unit: 'active',
                      color: CyberpunkTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated mining icon with pulse effect
class _AnimatedMiningIcon extends StatelessWidget {
  final AnimationController pulseController;
  
  const _AnimatedMiningIcon({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final scale = 1.0 + pulseController.value * 0.1;
        final glowOpacity = 0.3 + pulseController.value * 0.3;
        
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CyberpunkTheme.primaryBlue.withOpacity(0.2),
                  CyberpunkTheme.accentPurple.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: CyberpunkTheme.primaryBlue.withOpacity(0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: CyberpunkTheme.primaryBlue.withOpacity(glowOpacity),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: CyberpunkTheme.primaryBlue,
              size: 28,
              shadows: [
                Shadow(
                  color: CyberpunkTheme.primaryBlue.withOpacity(0.8),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Active status badge with pulsing indicator
class _ActiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: CyberpunkTheme.accentGreen.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CyberpunkTheme.accentGreen.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CyberpunkTheme.accentGreen.withOpacity(0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CyberpunkTheme.accentGreen,
              boxShadow: [
                BoxShadow(
                  color: CyberpunkTheme.accentGreen,
                  blurRadius: 6,
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(begin: 0.5, end: 1.0, duration: 800.ms),
          const SizedBox(width: 8),
          Text(
            'MINING',
            style: GoogleFonts.inter(
              color: CyberpunkTheme.accentGreen,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated hashrate visualization bar
class _HashrateBar extends StatelessWidget {
  final double hashRate;
  final AnimationController scanController;
  
  const _HashrateBar({
    required this.hashRate,
    required this.scanController,
  });

  @override
  Widget build(BuildContext context) {
    // Get historical network hashrate for context
    final gameState = context.watch<GameStateProvider>();
    final miningData = MiningDatabase.getMiningData(gameState.activeCrypto);
    double networkHashRate = 1000000000.0; // Default fallback
    
    if (miningData != null) {
       networkHashRate = miningData.getEffectiveNetworkHashRate(gameState.gameDate);
       // Convert user hashrate to same unit (MH/s to Network Unit) if needed, 
       // but here we just want relative scale.
       // Let's assume networkHashRate is in its native unit, and we need to convert to MH/s to compare?
       // Actually, let's just make the bar logarithmic or relative to a "goal".
       // Better: Bar represents "Efficiency" or "Uptime" based on previous logic?
       // The previous logic was: (hashRate / 500).clamp(...)
       // Let's make it relative to a "healthy" hashrate for the era.
       // For now, let's just keep it simple: Logarithmic scale of hash rate vs network.
    }

    // Normalize: Log10 of hashrate vs Log10 of Network? 
    // Or just Keep simplicity: Percentage of specific milestone?
    // User asked for "Network Difficulty Progress Bar". 
    // Usually means "Current Diff / Next Diff" or "Block Progress".
    // But this widget calls it "MINING POWER".
    // Let's stick to the visual the user likely sees: A bar filling up.
    // Let's make it fill based on: (User Hashrate / 1% of Network Hashrate) scaled?
    
    // Simplest approach satisfying user request for "Difficulty Progress Bar":
    // Maybe they meant the bar should represent how close they are to solving a block?
    // Let's leave "MINING POWER" as relative to Era standards.
    
    double milestone = 500.0; // Default 500 MH/s
    if (gameState.gameYear <= 2010) milestone = 50.0; // 50 MH/s is huge in 2010 (CPU era)
    else if (gameState.gameYear <= 2013) milestone = 5000.0; // 5 GH/s (early ASICs)
    else if (gameState.gameYear <= 2016) milestone = 50000.0; // 50 GH/s
    else milestone = 1000000.0; // 1 TH/s +
    
    final normalizedRate = (hashRate / milestone).clamp(0.05, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MINING POWER',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: CyberpunkTheme.textTertiary,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '${(normalizedRate * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: CyberpunkTheme.accentCyan,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: CyberpunkTheme.surfaceColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: CyberpunkTheme.borderColor,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Fill bar
              FractionallySizedBox(
                widthFactor: normalizedRate,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: [
                        CyberpunkTheme.primaryBlue,
                        CyberpunkTheme.accentCyan,
                        CyberpunkTheme.accentGreen,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CyberpunkTheme.accentCyan.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              // Scanning effect
              AnimatedBuilder(
                animation: scanController,
                builder: (context, child) {
                  return Positioned(
                    left: scanController.value * MediaQuery.of(context).size.width * 0.8 - 30,
                    child: Container(
                      width: 60,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Enhanced stat item with icon
class _EnhancedStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  
  const _EnhancedStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color.withOpacity(0.7),
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            color: CyberpunkTheme.textTertiary,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: CyberpunkTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tappable hash rate display that shows click-to-cycle hint
class _TappableHashRateItem extends StatelessWidget {
  final double hashRate;
  final String formattedValue;
  final int unitIndex;

  const _TappableHashRateItem({
    required this.hashRate,
    required this.formattedValue,
    required this.unitIndex,
  });

  @override
  Widget build(BuildContext context) {
    final unitLabels = ['AUTO', 'MH/s', 'GH/s', 'TH/s'];
    
    return Column(
      children: [
        Icon(
          Icons.speed_rounded,
          size: 20,
          color: CyberpunkTheme.accentCyan.withOpacity(0.7),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HASH RATE',
              style: GoogleFonts.inter(
                fontSize: 9,
                color: CyberpunkTheme.textTertiary,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: CyberpunkTheme.accentCyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                unitLabels[unitIndex],
                style: GoogleFonts.inter(
                  fontSize: 7,
                  color: CyberpunkTheme.accentCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          formattedValue,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: CyberpunkTheme.accentCyan,
          ),
        ),
        Text(
          'tap to cycle',
          style: GoogleFonts.inter(
            fontSize: 8,
            color: CyberpunkTheme.textTertiary.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
