import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';
import '../core/models/historical_data.dart';

/// Panel showing all miners and which coin each is mining
/// Allows assigning different coins to different miners based on algorithm compatibility
class MinerAssignmentPanel extends StatelessWidget {
  final VoidCallback? onGoToShop;
  
  const MinerAssignmentPanel({super.key, this.onGoToShop});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    final miners = gameState.gpus;

    if (miners.isEmpty) {
      return _EmptyMinersCard(onGoToShop: onGoToShop);
    }

    return Container(
      decoration: CyberpunkTheme.modernCard(withGlow: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CyberpunkTheme.primaryBlue.withOpacity(0.2),
                  CyberpunkTheme.accentPurple.withOpacity(0.1),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CyberpunkTheme.primaryBlue.withOpacity(0.2),
                    border: Border.all(
                      color: CyberpunkTheme.primaryBlue.withOpacity(0.5),
                    ),
                  ),
                  child: Icon(
                    Icons.precision_manufacturing_rounded,
                    color: CyberpunkTheme.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MINING OPERATIONS',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: CyberpunkTheme.textTertiary,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${miners.length} Active Miner${miners.length != 1 ? 's' : ''}',
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CyberpunkTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                _MiningIndicator(),
              ],
            ),
          ),

          // Miners List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: miners.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final miner = miners[index];
              return MinerAssignmentCard(
                miner: miner,
                minerIndex: index,
              );
            },
          ),

          // Summary footer
          _MiningSummaryFooter(),
        ],
      ),
    );
  }
}

/// Card for a single miner showing its assignment
class MinerAssignmentCard extends StatelessWidget {
  final GPU miner;
  final int minerIndex;

  const MinerAssignmentCard({
    super.key,
    required this.miner,
    required this.minerIndex,
  });

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    final priceProvider = context.watch<CryptoPriceProvider>();
    final compatibleCoins = miner.compatibleCoins;
    final currentCoin = priceProvider.getCrypto(miner.miningCoinId);

    // Get color based on miner type
    Color minerColor;
    IconData minerIcon;
    switch (miner.minerType) {
      case MinerType.cpu:
        minerColor = CyberpunkTheme.accentCyan;
        minerIcon = Icons.memory_rounded;
        break;
      case MinerType.gpu:
        minerColor = CyberpunkTheme.accentGreen;
        minerIcon = Icons.developer_board_rounded;
        break;
      case MinerType.asic:
        minerColor = CyberpunkTheme.accentOrange;
        minerIcon = Icons.precision_manufacturing_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CyberpunkTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: minerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Miner header row
          Row(
            children: [
              // Miner type icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: minerColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(minerIcon, color: minerColor, size: 20),
              ),
              const SizedBox(width: 10),

              // Miner name and type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      miner.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: CyberpunkTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: minerColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            miner.minerTypeDisplay,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: minerColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          miner.algorithm,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: CyberpunkTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Hashrate
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    miner.formattedHashRate,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: minerColor,
                    ),
                  ),
                  Text(
                    '${miner.powerWatts.toStringAsFixed(0)}W',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: CyberpunkTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Coin assignment row
          Row(
            children: [
              Text(
                'Mining:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: CyberpunkTheme.textTertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CoinSelector(
                  miner: miner,
                  minerIndex: minerIndex,
                  compatibleCoins: compatibleCoins,
                  currentCoinId: miner.miningCoinId,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dropdown selector for choosing which coin a miner should mine
class _CoinSelector extends StatelessWidget {
  final GPU miner;
  final int minerIndex;
  final List<String> compatibleCoins;
  final String currentCoinId;

  const _CoinSelector({
    required this.miner,
    required this.minerIndex,
    required this.compatibleCoins,
    required this.currentCoinId,
  });

  @override
  Widget build(BuildContext context) {
    final gameState = context.read<GameStateProvider>();
    final priceProvider = context.watch<CryptoPriceProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: CyberpunkTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CyberpunkTheme.borderColor,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentCoinId,
          isExpanded: true,
          dropdownColor: CyberpunkTheme.surfaceColor,
          icon: Icon(
            Icons.arrow_drop_down,
            color: CyberpunkTheme.primaryBlue,
          ),
          style: GoogleFonts.inter(
            fontSize: 13,
            color: CyberpunkTheme.textPrimary,
          ),
          items: _buildDropdownItems(compatibleCoins, priceProvider, gameState),
          onChanged: (newCoinId) {
            if (newCoinId != null && newCoinId != currentCoinId && !newCoinId.startsWith('HEADER_')) {
              gameState.setMinerCoin(minerIndex, newCoinId);
            }
          },
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(
      List<String> coins, CryptoPriceProvider priceProvider, GameStateProvider gameState) {
    // Group by Algorithm
    final Map<String, List<String>> byAlgo = {};
    for (final coin in coins) {
      String algo = 'Unknown';
      // Find algo for coin
      for (final entry in AlgorithmCompatibility.algorithmToCoins.entries) {
        if (entry.value.contains(coin)) {
          algo = entry.key;
          break;
        }
      }
      byAlgo.putIfAbsent(algo, () => []).add(coin);
    }

    final items = <DropdownMenuItem<String>>[];
    final sortedAlgos = byAlgo.keys.toList()..sort();

    for (final algo in sortedAlgos) {
      // Add Header
      items.add(DropdownMenuItem<String>(
        value: 'HEADER_$algo',
        enabled: false,
        child: Container(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: CyberpunkTheme.accentGreen.withOpacity(0.3), width: 1)),
          ),
          child: Text(
            algo.toUpperCase(),
            style: GoogleFonts.orbitron(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: CyberpunkTheme.accentGreen,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ));

      // Sort coins
      final algoCoins = byAlgo[algo]!..sort();
      
      for (final coinId in algoCoins) {
        final crypto = priceProvider.getCrypto(coinId);
        final coinName = crypto?.name ?? _formatCoinName(coinId);
        final coinSymbol = crypto?.symbol ?? coinId.toUpperCase();
        final coinPrice = crypto?.price ?? 0.0;
        
        // Status checks
        final exists = HistoricalPriceData.coinExistsAt(coinId, gameState.gameDate);
        bool isObsolete = false;
        if (algo == 'SHA-256' && gameState.gameDate.year >= 2014) {
          if (miner.minerType == MinerType.gpu) {
            isObsolete = true;
          }
        }
        
        final isEnabled = exists && !isObsolete;
        String statusLabel = '';
        if (!exists) statusLabel = ' [Locked: ${HistoricalPriceData.getLaunchYear(coinId)}]';
        if (isObsolete) statusLabel = ' [Obsolete]';
        
        items.add(DropdownMenuItem<String>(
          value: coinId,
          enabled: isEnabled,
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: Row(
              children: [
                _getCoinIcon(coinId),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            coinSymbol,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isEnabled ? CyberpunkTheme.textPrimary : CyberpunkTheme.textTertiary,
                            ),
                          ),
                          if (!isEnabled)
                            Text(
                              statusLabel,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isObsolete ? CyberpunkTheme.accentOrange : CyberpunkTheme.accentRed,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        coinName,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: CyberpunkTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${coinPrice.toStringAsFixed(coinPrice < 1 ? 4 : 2)}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: isEnabled ? CyberpunkTheme.accentGreen : CyberpunkTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ));
      }
    }
    return items;
  }

  Widget _getCoinIcon(String coinId) {
    // Map coin IDs to colors
    final Map<String, Color> coinColors = {
      'bitcoin': const Color(0xFFF7931A),
      'bitcoin-cash': const Color(0xFF8DC351),
      'ethereum-classic': const Color(0xFF3C3C3D),
      'litecoin': const Color(0xFFBFBBB6),
      'dogecoin': const Color(0xFFC2A633),
      'monero': const Color(0xFFFF6600),
      'zcash': const Color(0xFFECB244),
      'ravencoin': const Color(0xFF384182),
      'ergo': const Color(0xFFFF5722),
      'kaspa': const Color(0xFF70C7BA),
      'flux': const Color(0xFF2B61D1),
      'dash': const Color(0xFF008CE7),
      'conflux-token': const Color(0xFF1E5EF0),
      'bitcoin-gold': const Color(0xFFEBA809),
    };

    final color = coinColors[coinId] ?? CyberpunkTheme.primaryBlue;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Center(
        child: Text(
          coinId.substring(0, 1).toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  String _formatCoinName(String coinId) {
    return coinId
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

/// Empty state when no miners are owned
class _EmptyMinersCard extends StatelessWidget {
  final VoidCallback? onGoToShop;
  
  const _EmptyMinersCard({this.onGoToShop});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: CyberpunkTheme.modernCard(),
      child: Column(
        children: [
          Icon(
            Icons.hardware_rounded,
            size: 64,
            color: CyberpunkTheme.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Mining Hardware',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CyberpunkTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Visit the Shop to purchase CPUs, GPUs, or ASICs to start mining!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: CyberpunkTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onGoToShop,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CyberpunkTheme.primaryBlue,
                    CyberpunkTheme.accentPurple,
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.storefront, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Go to Shop',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated mining indicator
class _MiningIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: CyberpunkTheme.accentGreen.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CyberpunkTheme.accentGreen.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CyberpunkTheme.accentGreen,
              boxShadow: [
                BoxShadow(
                  color: CyberpunkTheme.accentGreen,
                  blurRadius: 6,
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(begin: 0.4, end: 1.0, duration: 800.ms),
          const SizedBox(width: 6),
          Text(
            'ACTIVE',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: CyberpunkTheme.accentGreen,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Footer showing mining summary by coin
class _MiningSummaryFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    final priceProvider = context.watch<CryptoPriceProvider>();
    final miners = gameState.gpus;

    // Group miners by coin
    final Map<String, List<GPU>> minersByCoin = {};
    for (final miner in miners) {
      minersByCoin.putIfAbsent(miner.miningCoinId, () => []);
      minersByCoin[miner.miningCoinId]!.add(miner);
    }

    if (minersByCoin.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberpunkTheme.backgroundDark.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MINING SUMMARY',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: CyberpunkTheme.textTertiary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: minersByCoin.entries.map((entry) {
              final coinId = entry.key;
              final coinMiners = entry.value;
              final crypto = priceProvider.getCrypto(coinId);
              final formattedRate = _formatSmartHashRate(coinMiners);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CyberpunkTheme.borderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      crypto?.symbol ?? coinId.toUpperCase().substring(0, 3),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: CyberpunkTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${coinMiners.length}x',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: CyberpunkTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formattedRate,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: CyberpunkTheme.accentGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  /// Format hash rate with smart unit selection
  String _formatSmartHashRate(List<GPU> miners) {
    if (miners.isEmpty) return '0 H/s';
    
    // Get dominant algorithm
    final algorithm = miners.first.algorithm;
    
    // Calculate based on miner types
    if (algorithm == 'SHA-256') {
      // ASIC miners - TH/s
      double totalTH = 0;
      for (final m in miners) {
        if (m.hashRateUnit == 'TH/s') {
          totalTH += m.hashRate;
        } else {
          totalTH += m.hashRateInMHs / 1000000;
        }
      }
      if (totalTH >= 1000) {
        return '${(totalTH / 1000).toStringAsFixed(1)} PH/s';
      }
      return '${totalTH.toStringAsFixed(0)} TH/s';
    } else if (algorithm == 'RandomX') {
      // CPU miners - KH/s
      double totalKH = 0;
      for (final m in miners) {
        if (m.hashRateUnit == 'KH/s') {
          totalKH += m.hashRate;
        } else {
          totalKH += m.hashRateInMHs * 1000;
        }
      }
      if (totalKH >= 1000) {
        return '${(totalKH / 1000).toStringAsFixed(1)} MH/s';
      }
      return '${totalKH.toStringAsFixed(1)} KH/s';
    } else if (algorithm == 'Scrypt') {
      // Scrypt ASIC - GH/s
      double totalGH = 0;
      for (final m in miners) {
        if (m.hashRateUnit == 'GH/s') {
          totalGH += m.hashRate;
        } else {
          totalGH += m.hashRateInMHs / 1000;
        }
      }
      if (totalGH >= 1000) {
        return '${(totalGH / 1000).toStringAsFixed(1)} TH/s';
      }
      return '${totalGH.toStringAsFixed(1)} GH/s';
    } else if (algorithm == 'Equihash') {
      // Equihash - KSol/s
      double totalKSol = 0;
      for (final m in miners) {
        if (m.hashRateUnit == 'KSol/s') {
          totalKSol += m.hashRate;
        } else {
          totalKSol += m.hashRate;
        }
      }
      return '${totalKSol.toStringAsFixed(0)} KSol/s';
    } else {
      // GPU algorithms - MH/s or GH/s
      double totalMH = miners.fold(0.0, (sum, m) => sum + m.hashRateInMHs);
      if (totalMH >= 10000) {
        return '${(totalMH / 1000).toStringAsFixed(1)} GH/s';
      } else if (totalMH >= 1000) {
        return '${(totalMH / 1000).toStringAsFixed(2)} GH/s';
      }
      return '${totalMH.toStringAsFixed(0)} MH/s';
    }
  }
}
