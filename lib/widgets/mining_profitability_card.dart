import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/models/mining_data.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';
import '../core/models/historical_data.dart';
import 'network_crypto_logo.dart';

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
    
    // Check if coin exists at this date
    if (!HistoricalPriceData.coinExistsAt(coinId, gameState.gameDate)) {
      return _buildNonMineableCard({'reason': 'Not yet developed', 'developed': false});
    }
    
    // Check if user has compatible miners for this coin's algorithm
    final miningData = MiningDatabase.getMiningData(coinId);
    if (miningData != null) {
      final compatibleMiners = gameState.gpus.where((m) => m.canMine(coinId)).toList();
      if (compatibleMiners.isEmpty) {
        return _buildNonMineableCard({'reason': 'No compatible hardware', 'algorithm': miningData.algorithm});
      }
      
      // Special case: GPU mining Bitcoin in late eras
      if (miningData.algorithm == 'SHA-256' && gameState.gameDate.year >= 2014) {
        final hasOnlyGpus = compatibleMiners.every((m) => m.minerType == MinerType.gpu);
        if (hasOnlyGpus) {
          return _buildNonMineableCard({'reason': 'Hardware Obsolete', 'obsolete': true});
        }
      }
    }
    
    // Fallback to static mining database (with Historical Scaling)
    final stats = MiningCalculator.calculateMiningStats(
      coinId: coinId,
      hashRateMHs: hashRate,
      powerWatts: powerWatts,
      coinPrice: coinPrice,
      gameDate: gameState.gameDate,
    );
    
    final bool isMineable = stats['isMineable'] as bool? ?? false;
    
    if (!isMineable) {
      return _buildNonMineableCard(stats);
    }

    final double dailyCoins = stats['dailyCoins'] as double? ?? 0.0;
    final double dailyRevenue = stats['dailyRevenue'] as double? ?? 0.0;
    final double dailyProfit = stats['dailyProfit'] as double? ?? 0.0;
    final String algorithm = miningData?.algorithm ?? 'Unknown';
    final bool isProfitable = dailyProfit > 0;
    
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
                  // Logo
                  NetworkCryptoLogo(
                    logoUrl: context.watch<CryptoPriceProvider>().getCrypto(coinId)?.logoUrl,
                    symbol: coinSymbol,
                    size: 50,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                coinSymbol,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: CyberpunkTheme.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
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
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: cardColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
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
                                    fontSize: 8,
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getMinerTypeIcon(coinId),
                              size: 12,
                              color: CyberpunkTheme.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AlgorithmCompatibility.getMinerTypeForCoin(coinId),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: CyberpunkTheme.textTertiary,
                              ),
                            ),
                          ],
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
                border: Border.all(
                  color: stats['developed'] == false ? CyberpunkTheme.accentRed 
                       : (stats['obsolete'] == true ? CyberpunkTheme.accentOrange : Colors.grey),
                ),
              ),
              child: Text(
                stats['reason'] ?? 'Cannot Mine',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: stats['developed'] == false ? CyberpunkTheme.accentRed 
                       : (stats['obsolete'] == true ? CyberpunkTheme.accentOrange : CyberpunkTheme.textPrimary),
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
  
  IconData _getMinerTypeIcon(String coinId) {
    final minerType = AlgorithmCompatibility.getMinerTypeForCoin(coinId);
    if (minerType.contains('CPU')) return Icons.memory;
    if (minerType.contains('ASIC')) return Icons.precision_manufacturing;
    return Icons.developer_board; // GPU default
  }
}
