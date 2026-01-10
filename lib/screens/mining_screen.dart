import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/models/mining_data.dart';
import '../core/models/historical_data.dart';
import '../core/utils/animations.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';
import '../widgets/click_mining_button.dart';
import '../widgets/mining_profitability_card.dart';
import '../widgets/network_crypto_logo.dart';
import '../widgets/crypto_toast.dart';
import '../widgets/miner_assignment_panel.dart';
import 'shop_screen.dart';


/// Smart hash rate formatter
String _formatHashRate(double hashRate) {
  if (hashRate >= 1000000) {
    return '${(hashRate / 1000000).toStringAsFixed(2)} TH/s';
  } else if (hashRate >= 1000) {
    return '${(hashRate / 1000).toStringAsFixed(2)} GH/s';
  } else {
    return '${hashRate.toStringAsFixed(2)} MH/s';
  }
}
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
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: CyberpunkTheme.serverRoomBackground(),
          ),
          
          // Content
          SingleChildScrollView(
            physics: SmoothAnimations.smoothScroll,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Miner Assignment Panel - at the top of mining screen
                MinerAssignmentPanel(
                  onGoToShop: () {
                    // Navigate to shop screen directly
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ShopScreen()),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Current Mining Crypto Card
                _buildCurrentMiningCard(context, gameState, priceProvider),
                
                // Pool Status Card (If mining in a pool or pools are available)
                // Pools only available after Nov 27, 2010
                if (gameState.gameDate.isAfter(DateTime(2010, 11, 27)))
                   _buildPoolStatusCard(context, gameState),
                
                // If before pool era, maybe show a "Solo Era" badge?
                if (gameState.gameDate.isBefore(DateTime(2010, 11, 27)))
                   Container(
                     width: double.infinity,
                     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                     margin: const EdgeInsets.only(bottom: 16),
                     decoration: BoxDecoration(
                       color: Colors.amber.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(8),
                       border: Border.all(color: Colors.amber.withOpacity(0.3)),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(Icons.history_edu, size: 14, color: Colors.amber),
                         const SizedBox(width: 6),
                         Flexible(
                           child: Text(
                             "GENESIS ERA: SOLO MINING ONLY",
                             style: GoogleFonts.inter(
                               fontSize: 9, 
                               fontWeight: FontWeight.bold,
                               color: Colors.amber, 
                               letterSpacing: 0.5
                             ),
                             textAlign: TextAlign.center,
                             overflow: TextOverflow.ellipsis,
                           ),
                         ),
                       ],
                     ),
                   ),
                
                const SizedBox(height: 24),
                
                // Big Click/Tap Button
                Center(
                  child: const ClickMiningButton(),
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
        ],
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
    
    // Always get static data for Block Reward info
    final miningData = MiningDatabase.getMiningData(gameState.activeCrypto);
    
    // Use static mining data (WhatToMine service removed)
    if (miningData != null && miningData.isMineable && gameState.totalHashRate > 0) {
      final coinPrice = activeCrypto?.price ?? 0.0;
      // Pass gameDate and coinId to enable historical scaling and curve logic
      dailyRevenue = miningData.calculateDailyRevenue(
        gameState.totalHashRate, 
        coinPrice,
        gameDate: gameState.gameDate,
        coinId: gameState.activeCrypto,
      );
      dailyCoins = coinPrice > 0 ? dailyRevenue / coinPrice : 0.0;
      algorithm = miningData.algorithm;
    }
    
    // Get Block Reward for display (passing coinId to get correct curve)
    final blockReward = miningData?.getEffectiveBlockReward(gameState.gameDate, coinId: gameState.activeCrypto) ?? 0.0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: CyberpunkTheme.glassmorphismCard(
        glowColor: CyberpunkTheme.primaryBlue,
        glowIntensity: 0.15,
      ),
      child: Column(
        children: [
          Text(
            'CURRENTLY MINING',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: CyberpunkTheme.textTertiary,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          // Crypto Logo with glow
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CyberpunkTheme.primaryBlue.withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: NetworkCryptoLogo(
              logoUrl: activeCrypto?.logoUrl,
              symbol: activeCrypto?.symbol ?? 'BTC',
              size: 80,
            ),
          ),
          const SizedBox(height: 20),
          // Coin symbol with gradient
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                CyberpunkTheme.primaryBlue,
                CyberpunkTheme.accentCyan,
              ],
            ).createShader(bounds),
            child: Text(
              activeCrypto?.symbol ?? 'BTC',
              style: GoogleFonts.orbitron(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            activeCrypto?.name ?? 'Bitcoin',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: CyberpunkTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Price with glow
          Text(
            '\$${activeCrypto?.price.toStringAsFixed(2) ?? '0.00'}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: CyberpunkTheme.accentGreen,
              shadows: CyberpunkTheme.neonTextShadow(CyberpunkTheme.accentGreen, intensity: 0.4),
            ),
          ),
          
          const SizedBox(height: 8),
          // Block Reward & Max Supply row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Block Reward Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Text(
                  'Reward: ${blockReward.toStringAsFixed(blockReward < 1 ? 4 : 2)} ${activeCrypto?.symbol ?? ''}',
                  style: GoogleFonts.robotoMono(
                    fontSize: 10,
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Max Supply Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CyberpunkTheme.primaryBlue.withOpacity(0.5)),
                ),
                child: Text(
                  'Max Supply: ${_formatSupply(GameStateProvider.maxSupplies[gameState.activeCrypto] ?? 0)}',
                  style: GoogleFonts.robotoMono(
                    fontSize: 10,
                    color: CyberpunkTheme.accentCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Circulating Supply with Progress Bar
          Builder(builder: (context) {
            final circulating = _estimateCirculatingSupply(gameState.activeCrypto, gameState.gameDate);
            // Add player holdings to circulating supply for display
            final playerHoldings = gameState.holdings[gameState.activeCrypto] ?? 0.0;
            final totalCirculating = circulating + playerHoldings;
            final maxSupply = GameStateProvider.maxSupplies[gameState.activeCrypto] ?? 1.0;
            final percentage = ((totalCirculating / maxSupply) * 100).clamp(0, 100);
            final progressValue = (totalCirculating / maxSupply).clamp(0.0, 1.0);
            
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CyberpunkTheme.accentGreen.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SUPPLY',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: CyberpunkTheme.textTertiary,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          color: CyberpunkTheme.accentGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.white10,
                      color: CyberpunkTheme.accentGreen,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Circulating: ${_formatSupply(totalCirculating)}',
                        style: GoogleFonts.robotoMono(fontSize: 9, color: CyberpunkTheme.accentGreen),
                      ),
                      Text(
                        'Max: ${_formatSupply(maxSupply)}',
                        style: GoogleFonts.robotoMono(fontSize: 9, color: CyberpunkTheme.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: 24),
          // Daily Mining Display - Glass card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: CyberpunkTheme.glassStatCard(
              accentColor: CyberpunkTheme.accentGreen,
              glowIntensity: 0.15,
            ),
            child: Column(
              children: [
                // Dynamic Label based on mining mode
                Text(
                  gameState.currentPool.id == 'solo' && dailyCoins < blockReward 
                      ? 'EST. TIME TO BLOCK' 
                      : (gameState.currentPool.id == 'solo' ? 'EST. BLOCKS / DAY' : 'DAILY MINING RATE'),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: CyberpunkTheme.textTertiary,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      CyberpunkTheme.accentGreen,
                      CyberpunkTheme.accentCyan,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    gameState.currentPool.id == 'solo' 
                        ? (dailyCoins >= blockReward 
                            ? '${gameState.estimateBlocksPerDay(gameState.activeCrypto).toStringAsFixed(2)} Blocks'
                            : (blockReward / (dailyCoins > 0 ? dailyCoins : 0.0000001) > 365 
                                ? '> 1 Year' 
                                : '${(blockReward / (dailyCoins > 0 ? dailyCoins : 0.0000001)).toStringAsFixed(1)} Days'))
                        : _formatDailyCoins(dailyCoins),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '${activeCrypto?.symbol ?? 'COINS'} per day',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: CyberpunkTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: CyberpunkTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: CyberpunkTheme.accentGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '\$${(dailyCoins * (activeCrypto?.price ?? 0)).toStringAsFixed(2)}/day',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CyberpunkTheme.accentGreen,
                    ),
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

  String _formatSupply(double supply) {
    if (supply >= 1000000000000) return '${(supply / 1000000000000).toStringAsFixed(1)}T';
    if (supply >= 1000000000) return '${(supply / 1000000000).toStringAsFixed(1)}B';
    if (supply >= 1000000) return '${(supply / 1000000).toStringAsFixed(1)}M';
    if (supply >= 1000) return '${(supply / 1000).toStringAsFixed(1)}K';
    return supply.toStringAsFixed(0);
  }
  
  /// Estimate circulating supply based on historical block rewards
  double _estimateCirculatingSupply(String coinId, DateTime date) {
    // Historical estimates based on block mining schedules
    switch (coinId) {
      case 'bitcoin':
        // Bitcoin: 10 min blocks, halving every 210,000 blocks
        // Genesis: Jan 3, 2009
        final genesisDate = DateTime(2009, 1, 3);
        final daysSinceGenesis = date.difference(genesisDate).inDays.clamp(0, 100000);
        // Approximate: 144 blocks/day * reward
        double supply = 0;
        int days = daysSinceGenesis;
        // Halving 1: Nov 28, 2012 (~1,400 days from genesis)
        if (days > 0) {
          int daysAt50 = (days > 1425) ? 1425 : days;
          supply += daysAt50 * 144 * 50;
          days -= daysAt50;
        }
        // Halving 2: Jul 9, 2016 (~1,316 days after halving 1)
        if (days > 0) {
          int daysAt25 = (days > 1316) ? 1316 : days;
          supply += daysAt25 * 144 * 25;
          days -= daysAt25;
        }
        // Halving 3: May 11, 2020 (~1,402 days after halving 2)
        if (days > 0) {
          int daysAt125 = (days > 1402) ? 1402 : days;
          supply += daysAt125 * 144 * 12.5;
          days -= daysAt125;
        }
        // Halving 4: April 19, 2024 (~1,439 days after halving 3)
        if (days > 0) {
          int daysAt625 = (days > 1439) ? 1439 : days;
          supply += daysAt625 * 144 * 6.25;
          days -= daysAt625;
        }
        // After halving 4
        if (days > 0) {
          supply += days * 144 * 3.125;
        }
        return supply.clamp(0, 21000000);
        
      case 'litecoin':
        final genesisDate = DateTime(2011, 10, 7);
        final daysSinceGenesis = date.difference(genesisDate).inDays.clamp(0, 100000);
        // 2.5 min blocks = 576 blocks/day
        double supply = 0;
        int days = daysSinceGenesis;
        // Halving 1: Aug 25, 2015
        if (days > 0) {
          int daysAt50 = (days > 1418) ? 1418 : days;
          supply += daysAt50 * 576 * 50;
          days -= daysAt50;
        }
        // Halving 2: Aug 5, 2019
        if (days > 0) {
          int daysAt25 = (days > 1441) ? 1441 : days;
          supply += daysAt25 * 576 * 25;
          days -= daysAt25;
        }
        // Halving 3: Aug 2, 2023
        if (days > 0) {
          int daysAt125 = (days > 1458) ? 1458 : days;
          supply += daysAt125 * 576 * 12.5;
          days -= daysAt125;
        }
        if (days > 0) {
          supply += days * 576 * 6.25;
        }
        return supply.clamp(0, 84000000);
        
      case 'dogecoin':
        final genesisDate = DateTime(2013, 12, 6);
        final daysSinceGenesis = date.difference(genesisDate).inDays.clamp(0, 100000);
        // 1 min blocks = 1440 blocks/day, 10000 reward after stabilization
        return (daysSinceGenesis * 1440 * 10000.0).clamp(0, double.infinity);
        
      case 'ethereum':
        final genesisDate = DateTime(2015, 7, 30);
        final daysSinceGenesis = date.difference(genesisDate).inDays.clamp(0, 100000);
        // ~15 sec blocks = ~5760 blocks/day, 2-5 ETH reward depending on era
        return (daysSinceGenesis * 5760 * 2.5).clamp(0, double.infinity);
        
      default:
        return 0;
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
              CryptoToast.info(context, 'Now mining ${crypto.name}', icon: Icons.compare_arrows);
            },
          ),
        );
      }).toList(),
    );
  }
  
  double _calculateTotalPower(GameStateProvider gameState) {
    return gameState.gpus.fold(0.0, (sum, gpu) => sum + gpu.powerWatts);
  }
  
  Widget _buildMiningStats(GameStateProvider gameState) {
    // Get difficulty multiplier for current date
    final difficultyMultiplier = HistoricalPriceData.getDifficultyMultiplier(gameState.gameDate);
    final difficultyPercent = (difficultyMultiplier * 100).clamp(0, 100);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CyberpunkTheme.glassmorphismCard(
        glowColor: CyberpunkTheme.accentOrange,
        glowIntensity: 0.12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MINING STATISTICS',
            style: GoogleFonts.inter(
              fontSize: 14,
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
          const SizedBox(height: 16),
          // Network Difficulty Visualization
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: CyberpunkTheme.accentRed, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Network Difficulty',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: CyberpunkTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${difficultyPercent.toStringAsFixed(1)}%',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getDifficultyColor(difficultyMultiplier),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: difficultyMultiplier,
                  backgroundColor: Colors.white10,
                  color: _getDifficultyColor(difficultyMultiplier),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getDifficultyLabel(gameState.gameDate.year),
                style: GoogleFonts.inter(fontSize: 10, color: CyberpunkTheme.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getDifficultyColor(double multiplier) {
    if (multiplier < 0.1) return CyberpunkTheme.accentGreen;
    if (multiplier < 0.3) return Colors.lightGreenAccent;
    if (multiplier < 0.5) return Colors.amber;
    if (multiplier < 0.7) return Colors.orange;
    return CyberpunkTheme.accentRed;
  }
  
  String _getDifficultyLabel(int year) {
    if (year <= 2010) return 'GENESIS ERA: CPU/GPU mining is easy!';
    if (year <= 2012) return 'EARLY ERA: Difficulty rising, still profitable';
    if (year <= 2014) return 'ASIC ERA: Specialized hardware dominates';
    if (year <= 2018) return 'INDUSTRIAL ERA: Mining farms take over';
    if (year <= 2021) return 'MATURE ERA: Only large operations profit';
    return 'MODERN ERA: Extreme competition';
  }
  
  Widget _buildClickUpgrades(BuildContext context, GameStateProvider gameState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CyberpunkTheme.glassmorphismCard(
        glowColor: CyberpunkTheme.accentPurple,
        glowIntensity: 0.12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CLICK UPGRADES',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: CyberpunkTheme.accentPurple,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          
          // Current click value display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CyberpunkTheme.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CyberpunkTheme.accentGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, color: CyberpunkTheme.accentGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Current: \$${gameState.clickValueInDollars.toStringAsFixed(2)} per tap',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: CyberpunkTheme.accentGreen,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Upgrade Click Power
          _UpgradeButton(
            title: 'Double Click Power',
            description: 'Power: ${gameState.clickPower.toStringAsFixed(1)}x → ${(gameState.clickPower * 2).toStringAsFixed(1)}x',
            cost: 500 * (gameState.clickPower / 1.0),
            icon: Icons.flash_on,
            color: CyberpunkTheme.accentOrange,
            onPurchase: () {
              final cost = 500 * (gameState.clickPower / 1.0);
              if (gameState.upgradeClickPower(cost)) {
                CryptoToast.show(
                  context, 
                  'Click Power Doubled! Now \$${gameState.clickValueInDollars.toStringAsFixed(2)}/tap',
                  icon: Icons.flash_on,
                  color: CyberpunkTheme.accentGreen,
                );
              } else {
                CryptoToast.show(
                  context, 
                  'Insufficient funds!',
                  icon: Icons.error_outline,
                  color: CyberpunkTheme.accentOrange,
                );
              }
            },
          ),
          
          const SizedBox(height: 12),
          
          // Activate Boost Button
          _UpgradeButton(
            title: 'Activate Boost (30s)',
            description: gameState.isBoostActive 
                ? 'Active: ${gameState.clickMultiplier.toStringAsFixed(1)}x for ${gameState.boostRemaining.inSeconds}s'
                : 'Get random 2x-10x multiplier',
            cost: 500,
            icon: Icons.timer,
            color: CyberpunkTheme.accentRed,
            onPurchase: () {
              if (gameState.isBoostActive) {
                CryptoToast.show(
                  context, 
                  'Boost already active! Wait for it to expire.',
                  icon: Icons.timer_off,
                  color: CyberpunkTheme.accentOrange,
                );
                return;
              }
              
              if (gameState.activateClickBoost(500)) { // Flat cost for now
                CryptoToast.show(
                  context, 
                  'BOOST ACTIVATED! ${gameState.clickMultiplier.toStringAsFixed(1)}x Multiplier!',
                  icon: Icons.rocket_launch,
                  color: CyberpunkTheme.accentRed,
                );
              } else {
                CryptoToast.show(
                  context, 
                  'Insufficient funds! Need \$500',
                  icon: Icons.error_outline,
                  color: CyberpunkTheme.accentOrange,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPoolStatusCard(BuildContext context, GameStateProvider gameState) {
    // Only show if using a pool (and not solo)
    // Assuming 'solo' is ID for solo mining
    if (gameState.currentPool.id == 'solo') return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: CyberpunkTheme.glassmorphismCard(
        glowColor: CyberpunkTheme.accentPurple,
        glowIntensity: 0.15,
        borderOpacity: 0.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('POOL STATUS: ${gameState.currentPool.name}', style: GoogleFonts.orbitron(fontSize: 12, color: Colors.white70)),
              Text('Fee: ${gameState.currentPool.feePercent}%', style: GoogleFonts.inter(fontSize: 12, color: CyberpunkTheme.accentRed)),
            ],
          ),
          const SizedBox(height: 12),
          Text('UNPAID BALANCE', style: GoogleFonts.inter(fontSize: 10, color: CyberpunkTheme.textTertiary)),
          const SizedBox(height: 4),
          Row(
            children: [
               Text('${gameState.pendingPoolPayout.toStringAsFixed(8)}', style: GoogleFonts.jetBrainsMono(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
               const SizedBox(width: 8),
               Text(gameState.activeCrypto.toUpperCase(), style: GoogleFonts.orbitron(fontSize: 14, color: CyberpunkTheme.accentPurple)),
            ],
          ),
          const SizedBox(height: 8),
          // Progress Bar to Payout
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (gameState.pendingPoolPayout / (gameState.currentPool.minPayoutCoins > 0 ? gameState.currentPool.minPayoutCoins : 1.0)).clamp(0.0, 1.0),
              backgroundColor: Colors.white10,
              color: CyberpunkTheme.accentPurple,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text('Next Payout: ${gameState.currentPool.minPayoutCoins} ${gameState.activeCrypto.toUpperCase()}', style: GoogleFonts.inter(fontSize: 10, color: CyberpunkTheme.textTertiary)),
        ]
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
