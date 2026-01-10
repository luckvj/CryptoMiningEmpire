// Game Date Display Widget - Shows current game date and time speed
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/game_state_provider.dart';
import '../core/theme/cyberpunk_theme.dart';

class GameDateDisplay extends StatelessWidget {
  final bool compact;
  
  const GameDateDisplay({super.key, this.compact = false});
  
  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    final date = gameState.gameDate;
    final speed = gameState.timeSpeed;
    final isDynamic = gameState.isDynamicTime;
    
    final dateFormat = DateFormat('MMM d, yyyy');
    final formattedDate = dateFormat.format(date);
    
    // Determine era label
    String eraLabel = '';
    Color eraColor = CyberpunkTheme.primaryBlue;
    if (date.year == 2009) {
      eraLabel = 'Genesis Era';
      eraColor = Colors.amber;
    } else if (date.year <= 2010) {
      eraLabel = 'Bitcoin Era';
      eraColor = Colors.orange;
    } else if (date.year <= 2015) {
      eraLabel = 'GPU Mining Era';
      eraColor = Colors.green;
    } else if (date.year <= 2020) {
      eraLabel = 'ASIC Era';
      eraColor = Colors.purple;
    } else {
      eraLabel = 'Modern Era';
      eraColor = CyberpunkTheme.primaryBlue;
    }
    
    // Speed label
    String speedLabel = speed == 0 ? '⏸ PAUSED' : 
                        speed == 1 ? '▶ 1x' : 
                        speed == 2 ? '▶▶ 2x' : 
                        '▶▶▶ ${speed.toInt()}x';
    
    if (compact) {
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Date display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: eraColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: eraColor.withOpacity(0.3)),
            ),
            child: Text(
              formattedDate,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Speed Controls
          _buildHeaderSpeedButtons(context, gameState),
          // Genesis indicator
          if (gameState.isGenesisMode && (gameState.totalMined['bitcoin'] ?? 0) == 0)
            const Icon(Icons.fingerprint, color: Colors.amber, size: 12),
        ],
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CyberpunkTheme.glassmorphismCard(
        glowColor: eraColor,
        glowIntensity: 0.1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: eraColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'GAME TIME',
                style: GoogleFonts.orbitron(
                  color: eraColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: eraColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  eraLabel,
                  style: GoogleFonts.inter(
                    color: eraColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formattedDate,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Time Speed Controls - Wrap layout for narrow sidebar
          Wrap(
            spacing: 2,
            runSpacing: 4,
            children: [
              _buildCompactSpeedBtn(context, gameState, 0, Icons.pause, 'STOP'),
              _buildCompactSpeedBtn(context, gameState, 0.1, Icons.play_arrow, 'PLAY'),
              _buildCompactSpeedBtn(context, gameState, 1, Icons.fast_forward, '1d/s'),
              _buildCompactSpeedBtn(context, gameState, 3, Icons.speed, '3d/s'),
              _buildCompactSpeedBtn(context, gameState, 5, Icons.bolt, '5d/s'),
              if (!isDynamic)
                InkWell(
                  onTap: () => gameState.enableDynamicTime(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.not_started, size: 14, color: Colors.green),
                  ),
                ),
            ],
          ),
          if (isDynamic) ...[
            const SizedBox(height: 8),
            Text(
              speed == 0 ? 'Time frozen' : 
              speed < 1 ? '${speed.toStringAsFixed(1)} days / second' :
              speed == 1 ? '1 day per second' : 
              '${speed.toInt()} days per second',
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
          // Return to Present button - ONLY visible when game is in the FUTURE
          // (Not shown in past eras like 2010, 2015, 2020)
          if (date.isAfter(DateTime.now())) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  // Reset to Present Day
                  gameState.resetGame(); // No year = goes to present
                },
                icon: const Icon(Icons.today, size: 14),
                label: const Text('Return to Present', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  foregroundColor: CyberpunkTheme.accentOrange,
                  backgroundColor: CyberpunkTheme.accentOrange.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildHeaderSpeedButtons(BuildContext context, GameStateProvider gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactSpeedBtn(context, gameState, 0, Icons.pause, 'STOP'),
          _buildCompactSpeedBtn(context, gameState, 0.1, Icons.play_arrow, 'PLAY'),
          _buildCompactSpeedBtn(context, gameState, 1, Icons.fast_forward, '1d/s'),
          _buildCompactSpeedBtn(context, gameState, 3, Icons.speed, '3d/s'),
          _buildCompactSpeedBtn(context, gameState, 5, Icons.bolt, '5d/s'),
        ],
      ),
    );
  }

  Widget _buildCompactSpeedBtn(BuildContext context, GameStateProvider gameState, double targetSpeed, IconData icon, String label) {
    final isActive = (gameState.timeSpeed - targetSpeed).abs() < 0.01;
    
    // Lock time controls during Genesis mode until Genesis block is mined
    final isGenesisLocked = gameState.isGenesisMode && (gameState.totalMined['bitcoin'] ?? 0) == 0;
    final color = isGenesisLocked ? Colors.white24 : (isActive ? CyberpunkTheme.primaryBlue : Colors.white54);

    return Tooltip(
      message: isGenesisLocked ? 'Mine Genesis Block first!' : label,
      child: InkWell(
        onTap: isGenesisLocked ? null : () {
           if (targetSpeed > 0 && !gameState.isDynamicTime) {
             gameState.enableDynamicTime();
           }
           gameState.setTimeSpeed(targetSpeed);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}
