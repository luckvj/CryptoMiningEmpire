import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';

/// Mining status display with active cryptocurrency
class MiningStatusCard extends StatelessWidget {
  const MiningStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    final priceProvider = context.watch<CryptoPriceProvider>();
    final activeCrypto = priceProvider.getCrypto(gameState.activeCrypto);
    
    return Container(
      decoration: CyberpunkTheme.modernCard(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CyberpunkTheme.primaryBlue.withOpacity(0.2),
                  border: Border.all(
                    color: CyberpunkTheme.primaryBlue,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.settings_input_antenna,
                  color: CyberpunkTheme.primaryBlue,
                  size: 24,
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENTLY MINING',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: CyberpunkTheme.textTertiary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      activeCrypto?.name ?? 'Bitcoin',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CyberpunkTheme.primaryBlue,
                        ),
                    ),
                  ],
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CyberpunkTheme.accentGreen),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CyberpunkTheme.accentGreen,
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                      .fadeOut(duration: 800.ms)
                      .then()
                      .fadeIn(duration: 800.ms),
                    const SizedBox(width: 8),
                    Text(
                      'ACTIVE',
                      style: GoogleFonts.inter(
                        color: CyberpunkTheme.accentGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Hash Rate',
                value: '${gameState.totalHashRate.toStringAsFixed(2)} MH/s',
                color: CyberpunkTheme.accentOrange,
              ),
              Container(
                width: 1,
                height: 40,
                color: CyberpunkTheme.textPrimary,
              ),
              _StatItem(
                label: 'Power Cost',
                value: '\$${gameState.dailyPowerCost.toStringAsFixed(2)}/day',
                color: CyberpunkTheme.accentOrange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            color: CyberpunkTheme.textTertiary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
            ),
        ),
      ],
    );
  }
}
