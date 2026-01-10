import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/models/upgrades_tree.dart';
import '../providers/game_state_provider.dart';
import '../widgets/crypto_toast.dart';
/// Upgrades Tree Screen - Click power, efficiency, automation
class UpgradesScreen extends StatelessWidget {
  const UpgradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: CyberpunkTheme.backgroundDark,
        appBar: AppBar(
          title: Text('Upgrades', style: GoogleFonts.orbitron()),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            labelColor: CyberpunkTheme.primaryBlue,
            unselectedLabelColor: Colors.white54,
            indicatorColor: CyberpunkTheme.primaryBlue,
            tabs: const [
              Tab(icon: Icon(Icons.touch_app), text: 'Click'),
              Tab(icon: Icon(Icons.speed), text: 'Efficiency'),
              Tab(icon: Icon(Icons.smart_toy), text: 'Auto'),
              Tab(icon: Icon(Icons.star), text: 'Special'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCategoryList(context, 'click', gameState),
            _buildCategoryList(context, 'efficiency', gameState),
            _buildCategoryList(context, 'automation', gameState),
            _buildCategoryList(context, 'special', gameState),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryList(BuildContext context, String category, GameStateProvider gameState) {
    final upgrades = UpgradesDatabase.getByCategory(category);
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upgrades.length,
      itemBuilder: (context, index) {
        final upgrade = upgrades[index];
        return _buildUpgradeCard(context, upgrade, gameState);
      },
    );
  }
  
  Widget _buildUpgradeCard(BuildContext context, GameUpgrade upgrade, GameStateProvider gameState) {
    final currentLevel = gameState.getUpgradeLevel(upgrade.id);
    final cost = upgrade.getCost(currentLevel);
    final isMaxed = currentLevel >= upgrade.maxLevel;
    final prereqMet = gameState.areUpgradePrerequisitesMet(upgrade.id);
    final canAfford = gameState.balance >= cost && prereqMet;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberpunkTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMaxed ? CyberpunkTheme.accentGreen : Colors.white10,
          width: isMaxed ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getCategoryColor(upgrade.category).withOpacity(0.2),
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
                        Expanded(
                          child: Text(
                            upgrade.name,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Lv.$currentLevel/${upgrade.maxLevel}',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
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
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Level progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: currentLevel / upgrade.maxLevel,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(_getCategoryColor(upgrade.category)),
              minHeight: 6,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Buy button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Requirements (use human-readable names)
              if (upgrade.getRequirementText() != null)
                Flexible(
                  child: Text(
                    upgrade.getRequirementText()!,
                    style: GoogleFonts.inter(color: Colors.orange, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const SizedBox(),
              
              // Cost & Buy
              ElevatedButton(
                onPressed: (!isMaxed && canAfford) ? () {
                  // Actually purchase the upgrade
                  if (gameState.purchaseUpgrade(upgrade.id)) {
                    HapticFeedback.mediumImpact();
                    CryptoToast.success(context, 'Upgraded ${upgrade.name}!', icon: Icons.upgrade);
                  } else {
                    CryptoToast.error(context, 'Cannot purchase upgrade');
                  }
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getCategoryColor(upgrade.category),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  isMaxed ? 'MAXED' : '\$${cost.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'click': return CyberpunkTheme.primaryBlue;
      case 'efficiency': return CyberpunkTheme.accentGreen;
      case 'automation': return CyberpunkTheme.accentOrange;
      case 'special': return Colors.purple;
      default: return CyberpunkTheme.primaryBlue;
    }
  }
}
