import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/models/mining_data.dart';
import '../core/utils/animations.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';
import '../widgets/click_mining_button.dart';
import '../widgets/mining_profitability_card.dart';

/// Mining screen - switch between cryptocurrencies and view mining stats
class MiningScreen extends StatelessWidget {
  const MiningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    final priceProvider = context.watch<CryptoPriceProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('MINING CONTROL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => gameState.saveGame(),
            tooltip: 'Save Game',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: SmoothAnimations.smoothScroll,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Mining Crypto Card
            _buildCurrentMiningCard(context, gameState, priceProvider),
            
            const SizedBox(height: 24),
            
            // Big Click/Tap Button
            Center(
              child: SizedBox(
                height: 320,
                child: const ClickMiningButton(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Click Upgrades
            _buildClickUpgrades(context, gameState),
            
            const SizedBox(height: 24),
            
            // Mining Profitability Comparison
            Text(
              'MINING PROFITABILITY',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CyberpunkTheme.accentGreen,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Sorted by daily profit with your current setup',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: CyberpunkTheme.textTertiary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Profitability List
            _buildProfitabilityList(context, gameState, priceProvider),
            
            const SizedBox(height: 24),
            
            // Mining Statistics
            _buildMiningStats(gameState),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCurrentMiningCard(
    BuildContext context,
    GameStateProvider gameState,
    CryptoPriceProvider priceProvider,
  ) {
    final activeCrypto = priceProvider.getCrypto(gameState.activeCrypto);
    
    // Calculate daily coin mining using WhatToMine data if available
    double dailyCoins = 0.0;
    double dailyRevenue = 0.0;
    String algorithm = '';
    
    // Try to get WhatToMine data first (most accurate)
    final wtmData = gameState.getWhatToMineData(gameState.activeCrypto);
    if (wtmData != null && wtmData.isMineable && gameState.totalHashRate > 0) {
      dailyCoins = wtmData.calculateDailyEarnings(gameState.totalHashRate);
      dailyRevenue = wtmData.calculateDailyRevenue(gameState.totalHashRate);
      algorithm = wtmData.algorithm;
    } else {
      // Fallback to static mining data
      final miningData = MiningDatabase.getMiningData(gameState.activeCrypto);
      if (miningData != null && miningData.isMineable && gameState.totalHashRate > 0) {
        final coinPrice = activeCrypto?.price ?? 0.0;
        dailyRevenue = miningData.calculateDailyRevenue(gameState.totalHashRate, coinPrice);
        dailyCoins = coinPrice > 0 ? dailyRevenue / coinPrice : 0.0;
        algorithm = miningData.algorithm;
      }
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: CyberpunkTheme.modernCard(),
      child: Column(
        children: [
          Text(
            'CURRENTLY MINING',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: CyberpunkTheme.textTertiary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            activeCrypto?.symbol ?? 'BTC',
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: CyberpunkTheme.primaryBlue,
              ),
          ),
          Text(
            activeCrypto?.name ?? 'Bitcoin',
            style: GoogleFonts.inter(
              fontSize: 20,
              color: CyberpunkTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '\$${activeCrypto?.price.toStringAsFixed(2) ?? '0.00'}',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CyberpunkTheme.accentGreen,
            ),
          ),
          const SizedBox(height: 20),
          // Daily Mining Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CyberpunkTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CyberpunkTheme.primaryBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'DAILY MINING RATE',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: CyberpunkTheme.textTertiary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDailyCoins(dailyCoins),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CyberpunkTheme.accentGreen,
                  ),
                ),
                Text(
                  '${activeCrypto?.symbol ?? 'COINS'} per day',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: CyberpunkTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${(dailyCoins * (activeCrypto?.price ?? 0)).toStringAsFixed(2)}/day',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: CyberpunkTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDailyCoins(double amount) {
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
  
  Widget _buildProfitabilityList(
    BuildContext context,
    GameStateProvider gameState,
    CryptoPriceProvider priceProvider,
  ) {
    // Get all cryptos and calculate profitability
    final allCryptos = priceProvider.cryptoData.values.toList();
    
    // Filter to only show MINEABLE coins
    final mineableCryptos = allCryptos.where((crypto) {
      final stats = MiningCalculator.calculateMiningStats(
        coinId: crypto.id,
        hashRateMHs: gameState.totalHashRate,
        powerWatts: _calculateTotalPower(gameState),
        coinPrice: crypto.price,
      );
      return stats['isMineable'] as bool? ?? false;
    }).toList();
    
    // Sort by profitability
    mineableCryptos.sort((a, b) {
      final statsA = MiningCalculator.calculateMiningStats(
        coinId: a.id,
        hashRateMHs: gameState.totalHashRate,
        powerWatts: _calculateTotalPower(gameState),
        coinPrice: a.price,
      );
      final statsB = MiningCalculator.calculateMiningStats(
        coinId: b.id,
        hashRateMHs: gameState.totalHashRate,
        powerWatts: _calculateTotalPower(gameState),
        coinPrice: b.price,
      );
      
      final profitA = (statsA['dailyProfit'] as double?) ?? double.negativeInfinity;
      final profitB = (statsB['dailyProfit'] as double?) ?? double.negativeInfinity;
      
      return profitB.compareTo(profitA); // Descending
    });
    
    // Show message if no mineable coins
    if (mineableCryptos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: CyberpunkTheme.modernCard(),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: CyberpunkTheme.accentOrange),
            const SizedBox(height: 16),
            Text(
              'No mineable coins available yet',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CyberpunkTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for WhatToMine data...',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: CyberpunkTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    // Show all mineable coins (sorted by profitability) with animations
    return Column(
      children: mineableCryptos.asMap().entries.map((entry) {
        final index = entry.key;
        final crypto = entry.value;
        
        return SmoothAnimations.listItem(
          index: index,
          child: MiningProfitabilityCard(
            coinId: crypto.id,
            coinSymbol: crypto.symbol,
            coinName: crypto.name,
            coinPrice: crypto.price,
            hashRate: gameState.totalHashRate,
            powerWatts: _calculateTotalPower(gameState),
            isActive: crypto.id == gameState.activeCrypto,
            onTap: () {
              gameState.switchMiningCrypto(crypto.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Now mining ${crypto.name}'),
                  backgroundColor: CyberpunkTheme.primaryBlue,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
  
  double _calculateTotalPower(GameStateProvider gameState) {
    return gameState.gpus.fold(0.0, (sum, gpu) => sum + gpu.powerWatts);
  }
  
  Widget _buildCryptoGrid(
    BuildContext context,
    GameStateProvider gameState,
    CryptoPriceProvider priceProvider,
  ) {
    final topCryptos = priceProvider.cryptoData.values.take(20).toList();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: topCryptos.length,
      itemBuilder: (context, index) {
        final crypto = topCryptos[index];
        final isActive = crypto.id == gameState.activeCrypto;
        
        return GestureDetector(
          onTap: () {
            gameState.switchMiningCrypto(crypto.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Now mining ${crypto.name}'),
                backgroundColor: CyberpunkTheme.primaryBlue,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            decoration: CyberpunkTheme.modernCard(),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  crypto.symbol,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isActive ? CyberpunkTheme.primaryBlue : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${crypto.price.toStringAsFixed(crypto.price < 1 ? 4 : 2)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: CyberpunkTheme.textSecondary,
                  ),
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CyberpunkTheme.accentGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
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
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMiningStats(GameStateProvider gameState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CyberpunkTheme.modernCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MINING STATISTICS',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CyberpunkTheme.accentOrange,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          _StatRow(
            label: 'Total GPUs',
            value: '${gameState.gpuCount}',
            icon: Icons.memory,
          ),
          _StatRow(
            label: 'Total Hash Rate',
            value: '${gameState.totalHashRate.toStringAsFixed(2)} MH/s',
            icon: Icons.speed,
          ),
          _StatRow(
            label: 'Power Cost (Daily)',
            value: '\$${gameState.dailyPowerCost.toStringAsFixed(2)}',
            icon: Icons.power,
          ),
          _StatRow(
            label: 'Buildings',
            value: '${gameState.buildingCount}',
            icon: Icons.business,
          ),
        ],
      ),
    );
  }
  
  Widget _buildClickUpgrades(BuildContext context, GameStateProvider gameState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CyberpunkTheme.modernCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CLICK UPGRADES',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CyberpunkTheme.accentOrange,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          
          // Upgrade Click Power
          _UpgradeButton(
            title: 'Double Click Power',
            description: 'Current: ${gameState.clickPower.toStringAsFixed(1)}x',
            cost: 500 * (gameState.clickPower / 1.0),
            icon: Icons.flash_on,
            color: CyberpunkTheme.accentOrange,
            onPurchase: () {
              final cost = 500 * (gameState.clickPower / 1.0);
              if (gameState.upgradeClickPower(cost)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Click Power Doubled!'),
                    backgroundColor: CyberpunkTheme.accentGreen,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Insufficient funds!'),
                    backgroundColor: CyberpunkTheme.accentOrange,
                  ),
                );
              }
            },
          ),
          
          const SizedBox(height: 12),
          
          // Upgrade Click Multiplier
          _UpgradeButton(
            title: 'Increase Multiplier',
            description: 'Current: ${gameState.clickMultiplier.toStringAsFixed(1)}x',
            cost: 1000 * gameState.clickMultiplier,
            icon: Icons.trending_up,
            color: CyberpunkTheme.accentPurple,
            onPurchase: () {
              final cost = 1000 * gameState.clickMultiplier;
              if (gameState.upgradeClickMultiplier(cost)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Multiplier Increased!'),
                    backgroundColor: CyberpunkTheme.accentGreen,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Insufficient funds!'),
                    backgroundColor: CyberpunkTheme.accentOrange,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _UpgradeButton extends StatelessWidget {
  final String title;
  final String description;
  final double cost;
  final IconData icon;
  final Color color;
  final VoidCallback onPurchase;
  
  const _UpgradeButton({
    required this.title,
    required this.description,
    required this.cost,
    required this.icon,
    required this.color,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CyberpunkTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: CyberpunkTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: CyberpunkTheme.textTertiary,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: onPurchase,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            '\$${cost.toStringAsFixed(0)}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  
  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: CyberpunkTheme.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: CyberpunkTheme.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CyberpunkTheme.accentGreen,
            ),
          ),
        ],
      ),
    );
  }
}
