import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state_provider.dart';
import '../core/theme/cyberpunk_theme.dart';

class MarketLockoutOverlay extends StatelessWidget {
  final Widget child;

  const MarketLockoutOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    
    if (!gameState.isMarketLocked) {
      return child;
    }

    final secondsLeft = gameState.marketLockoutRemainingSeconds;

    return Stack(
      children: [
        // Blurry/Dimmed background
        child,
        Positioned.fill(
          child: Container(
            color: Colors.black87.withOpacity(0.85),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CyberpunkTheme.primaryBlue, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: CyberpunkTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sync_problem_rounded,
                      color: CyberpunkTheme.primaryBlue,
                      size: 64,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'SYNCING MARKET DATA',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Stabilizing global exchange nodes for the current era. Please wait.',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: secondsLeft / 30,
                            strokeWidth: 6,
                            backgroundColor: Colors.white10,
                            valueColor: const AlwaysStoppedAnimation<Color>(CyberpunkTheme.primaryBlue),
                          ),
                        ),
                        Text(
                          '${secondsLeft}s',
                          style: GoogleFonts.jetBrainsMono(
                            color: CyberpunkTheme.primaryBlue,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
