import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';

/// Big clickable button for manual mining with animations
class ClickMiningButton extends StatefulWidget {
  const ClickMiningButton({super.key});

  @override
  State<ClickMiningButton> createState() => _ClickMiningButtonState();
}

class _ClickMiningButtonState extends State<ClickMiningButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<FloatingText> _floatingTexts = [];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleClick(BuildContext context) {
    final gameState = context.read<GameStateProvider>();
    final priceProvider = context.read<CryptoPriceProvider>();
    final price = priceProvider.getPrice(gameState.activeCrypto);
    
    // Perform the click
    gameState.performClick(price);
    
    // Animation
    _controller.forward().then((_) => _controller.reverse());
    
    // Add floating text
    setState(() {
      _floatingTexts.add(FloatingText(
        text: '+${(gameState.clickPower * gameState.clickMultiplier * 0.0001).toStringAsFixed(8)}',
        key: UniqueKey(),
      ));
      
      // Remove old texts
      if (_floatingTexts.length > 10) {
        _floatingTexts.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Floating texts
        ..._floatingTexts.map((text) => Positioned(
          top: 50,
          child: text,
        )),
        
        // Main click button
        GestureDetector(
          onTap: () => _handleClick(context),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 1.0 - (_controller.value * 0.1);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        CyberpunkTheme.primaryBlue,
                        CyberpunkTheme.accentPurple,
                        CyberpunkTheme.accentOrange,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CyberpunkTheme.primaryBlue.withOpacity(0.8),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: CyberpunkTheme.accentOrange.withOpacity(0.6),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 60,
                        color: CyberpunkTheme.textPrimary,
                      ).animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 2000.ms),
                      const SizedBox(height: 8),
                      Text(
                        'TAP',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: CyberpunkTheme.textPrimary,
                          ),
                      ),
                      Text(
                        'TO MINE',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: CyberpunkTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ).animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 3000.ms, delay: 500.ms),
        
        // Click stats below
        Positioned(
          bottom: -80,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: CyberpunkTheme.modernCard(),
            child: Column(
              children: [
                Text(
                  'Click Power: ${gameState.clickPower.toStringAsFixed(1)}x',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: CyberpunkTheme.accentGreen,
                  ),
                ),
                Text(
                  'Multiplier: ${gameState.clickMultiplier.toStringAsFixed(1)}x',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: CyberpunkTheme.textSecondary,
                  ),
                ),
                Text(
                  'Total Clicks: ${gameState.totalClicks}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: CyberpunkTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Floating text animation for click rewards
class FloatingText extends StatelessWidget {
  final String text;
  
  const FloatingText({required Key key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: CyberpunkTheme.accentGreen,
        ),
    ).animate()
      .fadeIn(duration: 200.ms)
      .moveY(begin: 0, end: -100, duration: 1500.ms)
      .fadeOut(duration: 300.ms, delay: 1200.ms);
  }
}
