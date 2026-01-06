import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/models/mining_data.dart';
import '../providers/game_state_provider.dart';

/// Card showing mining profitability for a specific coin
class MiningProfitabilityCard extends StatelessWidget {
  final String coinId;
  final String coinSymbol;
  final String coinName;
  final double coinPrice;
  final double hashRate;
  final double powerWatts;
  final bool isActive;
  final VoidCallback onTap;
  
  const MiningProfitabilityCard({
    super.key,
    required this.coinId,
    required this.coinSymbol,
    required this.coinName,
    required this.coinPrice,
    required this.hashRate,
    required this.powerWatts,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // First check if we have WhatToMine data (more accurate)
    final gameState = context.watch<GameStateProvider>();
    final wtmData = gameState.getWhatToMineData(coinId);
    
    double dailyCoins = 0.0;
    double dailyRevenue = 0.0;
    double dailyProfit = 0.0;
    String algorithm = '';
    bool isMineable = false;
    bool isProfitable = false;
    
    if (wtmData != null && wtmData.isMineable) {
      // Use WhatToMine data
      isMineable = true;
      algorithm = wtmData.algorithm;
      dailyCoins = wtmData.calculateDailyEarnings(hashRate);
      dailyRevenue = wtmData.calculateDailyRevenue(hashRate);
      final powerCost = (powerWatts / 1000) * 24 * 0.12; // $0.12 per kWh
      dailyProfit = dailyRevenue - powerCost;
      isProfitable = dailyProfit > 0;
    } else {
      // Fallback to static mining database
      final stats = MiningCalculator.calculateMiningStats(
        coinId: coinId,
        hashRateMHs: hashRate,
        powerWatts: powerWatts,
        coinPrice: coinPrice,
      );
      
      isMineable = stats['isMineable'] as bool;
      
      if (!isMineable) {
        return _buildNonMineableCard(stats);
      }
      
      dailyProfit = stats['dailyProfit'] as double;
      dailyRevenue = stats['dailyRevenue'] as double;
      isProfitable = stats['isProfitable'] as bool;
      algorithm = stats['algorithm'] as String;
      dailyCoins = coinPrice > 0 ? dailyRevenue / coinPrice : 0.0;
    }
    
    final cardColor = isActive
        ? CyberpunkTheme.primaryBlue
        : (isProfitable ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentOrange);
    
    return GestureDetector(
      onTap: isMineable ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: CyberpunkTheme.modernCard(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              coinSymbol,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CyberpunkTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cardColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: cardColor),
                              ),
                              child: Text(
                                algorithm,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: cardColor,
                                ),
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: CyberpunkTheme.accentGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: CyberpunkTheme.accentGreen),
                                ),
                                child: Text(
                                  'ACTIVE',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: CyberpunkTheme.accentGreen,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          coinName,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: CyberpunkTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'DAILY COINS',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: CyberpunkTheme.textTertiary,
                        ),
                      ),
                      Text(
                        _formatCoins(dailyCoins),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CyberpunkTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Stats - show coins per day and revenue
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    'Coins/Day',
                    _formatCoins(dailyCoins),
                    CyberpunkTheme.primaryBlue,
                  ),
                  _buildStat(
                    'Revenue/Day',
                    '\$${dailyRevenue.toStringAsFixed(2)}',
                    CyberpunkTheme.accentGreen,
                  ),
                  _buildStat(
                    'Monthly Profit',
                    '\$${(dailyProfit * 30).toStringAsFixed(0)}',
                    CyberpunkTheme.accentPurple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNonMineableCard(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: CyberpunkTheme.modernCard(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coinSymbol,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CyberpunkTheme.textPrimary,
                    ),
                  ),
                  Text(
                    coinName,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: CyberpunkTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                stats['reason'] ?? 'Cannot Mine',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: CyberpunkTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            color: CyberpunkTheme.textTertiary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  String _formatCoins(double amount) {
    if (amount == 0) return '0';
    // Always show full decimal format, no scientific notation
    if (amount < 0.0001) {
      return amount.toStringAsFixed(8);
    } else if (amount < 1) {
      return amount.toStringAsFixed(6);
    } else if (amount < 1000) {
      return amount.toStringAsFixed(4);
    } else {
      return amount.toStringAsFixed(2);
    }
  }
}
