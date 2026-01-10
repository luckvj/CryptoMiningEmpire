import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';

/// Statistics Screen - Game progress and analytics
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    final priceProvider = context.watch<CryptoPriceProvider>();
    
    // Calculate stats
    final netWorth = _calculateNetWorth(gameState, priceProvider);
    
    return Scaffold(
      backgroundColor: CyberpunkTheme.backgroundDark,
      appBar: AppBar(
        title: Text('Statistics', style: GoogleFonts.orbitron()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview card
            _buildOverviewCard(gameState, netWorth),
            const SizedBox(height: 24),
            
            // Mining stats
            _buildSectionTitle('Mining Statistics'),
            _buildMiningStats(gameState),
            const SizedBox(height: 24),
            
            // Trading stats
            _buildSectionTitle('Trading Statistics'),
            _buildTradingStats(gameState),
            const SizedBox(height: 24),
            
            // Hardware stats
            _buildSectionTitle('Hardware'),
            _buildHardwareStats(gameState),
            const SizedBox(height: 24),
            
            // Achievements progress
            _buildSectionTitle('Achievements'),
            _buildAchievementsProgress(gameState),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOverviewCard(GameStateProvider gameState, double netWorth) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: CyberpunkTheme.glassmorphismCard(glowColor: CyberpunkTheme.primaryBlue),
      child: Column(
        children: [
          Text(
            'TOTAL NET WORTH',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(netWorth),
            style: GoogleFonts.orbitron(
              color: CyberpunkTheme.accentGreen,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Cash', formatter.format(gameState.balance)),
              _buildMiniStat('Total Trades', '${gameState.totalTrades}'),
              _buildMiniStat('GPUs', '${gameState.gpuCount}'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.orbitron(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildMiningStats(GameStateProvider gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberpunkTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildStatRow('Total Clicks', '${gameState.totalClicks}'),
          _buildStatRow('Hash Rate', '${gameState.totalHashRate.toStringAsFixed(2)} MH/s'),
          _buildStatRow('GPUs Owned', '${gameState.gpuCount}'),
          _buildStatRow('Power Cost/Day', '\$${gameState.dailyPowerCost.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
  
  Widget _buildTradingStats(GameStateProvider gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberpunkTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildStatRow('Total Trades', '${gameState.totalTrades}'),
          _buildStatRow('Coins Held', '${gameState.holdings.where((e) => e.value > 0).length}'),
          _buildStatRow('Current Pool', gameState.currentPool.name),
        ],
      ),
    );
  }
  
  Widget _buildHardwareStats(GameStateProvider gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberpunkTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildStatRow('GPUs', '${gameState.gpuCount}'),
          _buildStatRow('Buildings', '${gameState.buildingCount}'),
          _buildStatRow('Location', gameState.currentLocation.name),
        ],
      ),
    );
  }
  
  Widget _buildAchievementsProgress(GameStateProvider gameState) {
    final unlocked = gameState.achievements.length;
    const total = 20; // Total achievements
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberpunkTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: GoogleFonts.inter(color: Colors.white70)),
              Text(
                '$unlocked / $total',
                style: GoogleFonts.inter(color: CyberpunkTheme.accentGreen, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: unlocked / total,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(CyberpunkTheme.accentGreen),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white54)),
          Text(value, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  double _calculateNetWorth(GameStateProvider gameState, CryptoPriceProvider priceProvider) {
    double total = gameState.balance;
    
    for (final entry in gameState.holdings.entries) {
      final price = priceProvider.getPrice(entry.key);
      total += entry.value * price;
    }
    
    return total;
  }
  
  String _formatDuration(Duration d) {
    if (d.inDays > 0) {
      return '${d.inDays}d ${d.inHours % 24}h';
    } else if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes % 60}m';
    } else {
      return '${d.inMinutes}m';
    }
  }
}

extension on Map<String, double> {
  Iterable<MapEntry<String, double>> where(bool Function(MapEntry<String, double>) test) {
    return entries.where(test);
  }
}
