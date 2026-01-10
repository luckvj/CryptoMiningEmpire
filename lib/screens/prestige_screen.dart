import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/models/prestige_system.dart';
import '../providers/game_state_provider.dart';
import '../widgets/crypto_toast.dart';
/// Prestige Screen - Reset for permanent multipliers
class PrestigeScreen extends StatelessWidget {
  const PrestigeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    final netWorth = gameState.balance; // Simplified for now
    final prestigePointsToGain = calculatePrestigePoints(netWorth);
    
    return Scaffold(
      backgroundColor: CyberpunkTheme.backgroundDark,
      appBar: AppBar(
        title: Text('Prestige', style: GoogleFonts.orbitron()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Prestige info card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: CyberpunkTheme.glassmorphismCard(glowColor: Colors.purple),
              child: Column(
                children: [
                  Text('⭐', style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'PRESTIGE',
                    style: GoogleFonts.orbitron(
                      color: Colors.purple,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reset your progress for permanent bonuses',
                    style: GoogleFonts.inter(color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Points to gain
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Points to gain',
                          style: GoogleFonts.inter(color: Colors.white54),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '+${prestigePointsToGain.toStringAsFixed(1)} ⭐',
                          style: GoogleFonts.orbitron(
                            color: prestigePointsToGain > 0 ? Colors.purple : Colors.grey,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (prestigePointsToGain == 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Need \$100,000 net worth',
                              style: GoogleFonts.inter(color: Colors.orange, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Prestige button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: prestigePointsToGain > 0 ? () {
                        _showPrestigeConfirmation(context, prestigePointsToGain);
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'PRESTIGE NOW',
                        style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Upgrades list
            Text(
              'Prestige Upgrades',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ...PrestigeUpgrades.all.map((upgrade) => 
              _buildUpgradeCard(context, upgrade)
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUpgradeCard(BuildContext context, PrestigeUpgrade upgrade) {
    const currentLevel = 0; // Would come from game state
    final cost = upgrade.getCost(currentLevel);
    final effect = upgrade.getEffect(currentLevel + 1);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberpunkTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(upgrade.icon, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      upgrade.name,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lv.$currentLevel/${upgrade.maxLevel}',
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  upgrade.description,
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          
          // Cost & Buy
          Column(
            children: [
              Text(
                '${cost.toStringAsFixed(0)} ⭐',
                style: GoogleFonts.inter(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'BUY',
                  style: GoogleFonts.inter(
                    color: Colors.purple,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showPrestigeConfirmation(BuildContext context, double points) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CyberpunkTheme.surfaceColor,
        title: Text(
          'Confirm Prestige',
          style: GoogleFonts.orbitron(color: Colors.white),
        ),
        content: Text(
          'You will reset ALL progress and gain ${points.toStringAsFixed(1)} ⭐ prestige points.\n\nThis cannot be undone!',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              
              // Trigger prestige in game state
              context.read<GameStateProvider>().prestige(points);
              
              HapticFeedback.heavyImpact();
              CryptoToast.success(context, 'Prestiged! +${points.toStringAsFixed(1)} ⭐', icon: Icons.star);
              
              // Optional: Pop back to home screen as game resets
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('PRESTIGE'),
          ),
        ],
      ),
    );
  }
}
