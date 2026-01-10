import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/models/achievements.dart';
import '../providers/game_state_provider.dart';

/// Achievements UI Screen - Show unlocked and locked achievements
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    final unlockedIds = gameState.achievements.toSet();
    
    // Group achievements by category
    final achievementsByCategory = <String, List<Achievement>>{};
    for (final achievement in AchievementDatabase.all) {
      achievementsByCategory.putIfAbsent(achievement.category, () => []);
      achievementsByCategory[achievement.category]!.add(achievement);
    }
    
    return Scaffold(
      backgroundColor: CyberpunkTheme.backgroundDark,
      appBar: AppBar(
        title: Text('Achievements', style: GoogleFonts.orbitron()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CyberpunkTheme.accentGreen),
                ),
                child: Text(
                  '${unlockedIds.length}/${AchievementDatabase.all.length}',
                  style: GoogleFonts.orbitron(
                    color: CyberpunkTheme.accentGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: achievementsByCategory.entries.map((entry) {
          final category = entry.key;
          final achievements = entry.value;
          final unlockedInCategory = achievements.where((a) => unlockedIds.contains(a.id)).length;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Text(
                      _getCategoryIcon(category),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$unlockedInCategory/${achievements.length}',
                      style: GoogleFonts.inter(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              
              // Achievement cards
              ...achievements.map((achievement) {
                final isUnlocked = unlockedIds.contains(achievement.id);
                return _buildAchievementCard(achievement, isUnlocked);
              }),
              
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    final hint = 'Keep playing to unlock!';
    final rarity = 'common';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked 
          ? CyberpunkTheme.accentGreen.withOpacity(0.1)
          : CyberpunkTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? CyberpunkTheme.accentGreen : Colors.white10,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUnlocked 
                ? CyberpunkTheme.accentGreen.withOpacity(0.2)
                : Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isUnlocked
                ? Icon(achievement.icon, color: achievement.color, size: 28)
                : const Icon(Icons.lock, color: Colors.white24, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUnlocked ? achievement.name : '???',
                  style: GoogleFonts.inter(
                    color: isUnlocked ? Colors.white : Colors.white38,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isUnlocked ? achievement.description : hint,
                  style: GoogleFonts.inter(
                    color: isUnlocked ? Colors.white70 : Colors.white24,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Rarity indicator
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRarityColor(rarity).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                rarity.toUpperCase(),
                style: GoogleFonts.inter(
                  color: _getRarityColor(rarity),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'mining': return '⛏️';
      case 'wealth': return '💰';
      case 'trading': return '📈';
      case 'time': return '⏰';
      case 'special': return '⭐';
      default: return '🏆';
    }
  }
  
  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common': return Colors.grey;
      case 'uncommon': return Colors.green;
      case 'rare': return Colors.blue;
      case 'epic': return Colors.purple;
      case 'legendary': return Colors.orange;
      default: return Colors.white;
    }
  }
}
