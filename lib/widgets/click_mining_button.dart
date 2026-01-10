import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/models/historical_data.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';

/// Premium clickable mining button with stunning animations
class ClickMiningButton extends StatefulWidget {
  const ClickMiningButton({super.key});

  @override
  State<ClickMiningButton> createState() => _ClickMiningButtonState();
}

class _ClickMiningButtonState extends State<ClickMiningButton> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _tapController;
  late AnimationController _orbitController;
  late AnimationController _glowController;
  
  final List<TapParticle> _particles = [];
  final List<FloatingReward> _rewards = [];
  final Random _random = Random();
  
  // Click cooldown to prevent spam exploit
  static const Duration _clickCooldown = Duration(milliseconds: 100);
  DateTime _lastClickTime = DateTime.now().subtract(const Duration(seconds: 1));
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _tapController.dispose();
    _orbitController.dispose();
    _glowController.dispose();
    super.dispose();
  }
  
  void _handleTap(BuildContext context) {
    // Enforce click cooldown to prevent spam exploit
    final now = DateTime.now();
    if (now.difference(_lastClickTime) < _clickCooldown) {
      return; // Too fast, ignore click
    }
    _lastClickTime = now;
    
    final gameState = context.read<GameStateProvider>();
    final priceProvider = context.read<CryptoPriceProvider>();
    final activeCrypto = gameState.activeCrypto;
    
    // Check if this coin is mineable at the current game date
    if (!HistoricalPriceData.isCoinMineableAt(activeCrypto, gameState.gameDate)) {
      // Don't allow mining of non-mineable coins
      return;
    }
    
    final price = priceProvider.getPrice(activeCrypto);
    
    // Perform the click and get the actual amount mined
    final coinsEarned = gameState.performClick(price);
    final dollarValue = coinsEarned * price;
    
    // Only show reward if we actually earned something (block/threshold hit)
    if (coinsEarned > 0) {
      setState(() {
        _rewards.add(FloatingReward(
          key: UniqueKey(),
          amount: coinsEarned,
          symbol: priceProvider.getCrypto(activeCrypto)?.symbol ?? 'BTC',
          dollarValue: dollarValue,
        ));
        
        // Limit rewards shown
        if (_rewards.length > 5) {
          _rewards.removeAt(0);
        }
      });
    }

    // Tap animation
    _tapController.forward().then((_) => _tapController.reverse());
    
    // Spawn particles
    _spawnParticles();
  }
  
  void _spawnParticles() {
    setState(() {
      for (int i = 0; i < 12; i++) {
        final angle = (i / 12) * 2 * pi + _random.nextDouble() * 0.5;
        _particles.add(TapParticle(
          key: UniqueKey(),
          angle: angle,
          distance: 80 + _random.nextDouble() * 60,
          size: 4 + _random.nextDouble() * 4,
          color: _getRandomAccentColor(),
        ));
      }
      
      // Clean up old particles
      if (_particles.length > 50) {
        _particles.removeRange(0, _particles.length - 50);
      }

    });
  }
  
  Color _getRandomAccentColor() {
    final colors = [
      CyberpunkTheme.primaryBlue,
      CyberpunkTheme.accentCyan,
      CyberpunkTheme.accentGreen,
      CyberpunkTheme.accentOrange,
      CyberpunkTheme.accentPurple,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Orbiting crypto icons
            AnimatedBuilder(
              animation: _orbitController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(6, (index) {
                    final angle = (index / 6) * 2 * pi + _orbitController.value * 2 * pi;
                    final radius = 140.0;
                    final x = cos(angle) * radius;
                    final y = sin(angle) * radius * 0.4; // Elliptical orbit
                    
                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Opacity(
                        opacity: 0.3 + (sin(angle) + 1) * 0.2,
                        child: _OrbitingIcon(index: index),
                      ),
                    );
                  }),
                );
              },
            ),
            
            // Expanding pulse rings
            ...List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final delay = index * 0.33;
                  final progress = (_pulseController.value + delay) % 1.0;
                  final scale = 1.0 + progress * 1.2;
                  final opacity = (1.0 - progress) * 0.4;
                  
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CyberpunkTheme.primaryBlue.withOpacity(opacity),
                          width: 3 - progress * 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: CyberpunkTheme.primaryBlue.withOpacity(opacity * 0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
            
            // Tap particles
            ..._particles.map((particle) => particle),
            
            // Inner glow layer
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                // Reduced glow intensity to prevent glare obscuring text
                final glowIntensity = 0.2 + _glowController.value * 0.2;
                return Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: CyberpunkTheme.primaryBlue.withOpacity(glowIntensity),
                        blurRadius: 50,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: CyberpunkTheme.accentPurple.withOpacity(glowIntensity * 0.6),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Progress Bar (Circular)
            SizedBox(
              width: 220,
              height: 220,
              child: CircularProgressIndicator(
                value: gameState.clickProgress / gameState.clickTarget,
                strokeWidth: 4,
                color: CyberpunkTheme.primaryBlue,
                backgroundColor: CyberpunkTheme.primaryBlue.withOpacity(0.1),
              ),
            ),
            
            // Main button
            GestureDetector(
              onTap: () => _handleTap(context),
              child: AnimatedBuilder(
                animation: _tapController,
                builder: (context, child) {
                  final scale = 1.0 - (_tapController.value * 0.08);
                  return Transform.scale(
                    scale: scale,
                    child: AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: CyberpunkTheme.miningButtonGradient(
                              pulseValue: _glowController.value,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: CyberpunkTheme.primaryBlue.withOpacity(0.8),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: CyberpunkTheme.accentOrange.withOpacity(0.5),
                                blurRadius: 50,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Inner ring
                              Container(
                                width: 170,
                                height: 170,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                              ),
                              // Content
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bolt,
                                    size: 60,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.white.withOpacity(0.8),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'TAP',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 4,
                                      shadows: CyberpunkTheme.neonTextShadow(Colors.white, intensity: 0.5),
                                    ),
                                  ),
                                  Text(
                                    'TO MINE',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.8),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ).animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 3000.ms, delay: 1000.ms),
            // Floating rewards (MOVED TO TOP + IGNORE POINTER)
            ..._rewards.map((reward) => Positioned(
              top: 0,
              child: IgnorePointer(child: reward),
            )),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Stats card below - Standard Flow (No Overlap)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: CyberpunkTheme.glassmorphismCard(
            glowColor: CyberpunkTheme.accentGreen,
            glowIntensity: 0.2,
            borderOpacity: 0.2,
          ),
          child: Column(
            children: [
              // Dollar value per click (prominent)
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    CyberpunkTheme.accentGreen,
                    CyberpunkTheme.accentCyan,
                  ],
                ).createShader(bounds),
                child: Text(
                  _formatHashRate(gameState.currentClickHashRate) + ' / tap',
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '~${gameState.clickValueInDollars < 0.01 ? '< 0.01' : gameState.clickValueInDollars.toStringAsFixed(2)} coins/tap',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: CyberpunkTheme.accentGreen.withOpacity(0.8),
                ),
              ),

              const SizedBox(height: 10),
              // Power and multiplier row
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: CyberpunkTheme.accentGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.flash_on,
                          size: 14,
                          color: CyberpunkTheme.accentGreen,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Power ${gameState.clickPower.toStringAsFixed(1)}x',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CyberpunkTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: CyberpunkTheme.accentOrange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: CyberpunkTheme.accentOrange,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Multi ${gameState.clickMultiplier.toStringAsFixed(1)}x',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CyberpunkTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_formatNumber(gameState.totalClicks)} taps',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: CyberpunkTheme.textTertiary,
                ),
              ),
              // Show cooldown indicator when on cooldown
              if (gameState.isClickOnCooldown) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CyberpunkTheme.accentRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberpunkTheme.accentRed.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, size: 14, color: CyberpunkTheme.accentRed),
                      const SizedBox(width: 6),
                      Text(
                        'Block found! Wait ${gameState.clickCooldownRemaining} day(s)',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: CyberpunkTheme.accentRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ).animate()
          .fadeIn(duration: 400.ms, delay: 200.ms)
          .slideY(begin: 0.2, end: 0),
      ],
    );
  }
  
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatHashRate(double mhs) {
    if (mhs >= 1000000) return '${(mhs / 1000000).toStringAsFixed(2)} TH/s';
    if (mhs >= 1000) return '${(mhs / 1000).toStringAsFixed(2)} GH/s';
    return '${mhs.toStringAsFixed(1)} MH/s';
  }
}

/// Orbiting icon widget
class _OrbitingIcon extends StatelessWidget {
  final int index;
  
  const _OrbitingIcon({required this.index});
  
  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.currency_bitcoin,
      Icons.diamond,
      Icons.auto_graph,
      Icons.rocket_launch,
      Icons.trending_up,
      Icons.stars,
    ];
    
    final colors = [
      CyberpunkTheme.accentOrange,
      CyberpunkTheme.accentCyan,
      CyberpunkTheme.accentGreen,
      CyberpunkTheme.accentPurple,
      CyberpunkTheme.primaryBlue,
      CyberpunkTheme.accentOrange,
    ];
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CyberpunkTheme.surfaceColor.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: colors[index].withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(
        icons[index],
        size: 18,
        color: colors[index],
      ),
    );
  }
}

/// Tap particle that explodes outward
class TapParticle extends StatelessWidget {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  
  const TapParticle({
    required Key key,
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8),
            blurRadius: size * 2,
          ),
        ],
      ),
    ).animate()
      .move(
        begin: Offset.zero,
        end: Offset(cos(angle) * distance, sin(angle) * distance),
        duration: 600.ms,
        curve: Curves.easeOut,
      )
      .fadeOut(duration: 600.ms, delay: 200.ms)
      .scale(begin: const Offset(1.5, 1.5), end: const Offset(0.5, 0.5), duration: 600.ms);
  }
}

// Update FloatingReward colors
class FloatingReward extends StatelessWidget {
  final double amount;
  final String symbol;
  final double dollarValue;
  
  const FloatingReward({
    required Key key,
    required this.amount,
    required this.symbol,
    this.dollarValue = 0.0,
  }) : super(key: key);

  String _formatAmount(double amt) {
    if (amt >= 1000) return amt.toStringAsFixed(2);
    if (amt >= 1) return amt.toStringAsFixed(4);
    if (amt >= 0.0001) return amt.toStringAsFixed(6);
    return amt.toStringAsFixed(8);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Transparent / Minimalist container
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // Slightly frosty background for readability
        color: Colors.white.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dollar value (prominent white)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add,
                size: 16,
                color: Colors.white,
              ),
              Text(
                '\$${dollarValue.toStringAsFixed(2)}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 18, 
                  fontWeight: FontWeight.w900, 
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(1, 1)),
                  ],
                ),
              ),
            ],
          ),
          // Coins earned (smaller)
          Text(
            '+${_formatAmount(amount)} $symbol',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 100.ms)
      .moveY(begin: -20, end: -150, duration: 1200.ms, curve: Curves.easeOut) 
      .fadeOut(duration: 300.ms, delay: 900.ms);
  }
}
