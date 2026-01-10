import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';

/// Smart dashboard display showing mining activity per coin with appropriate units
class ActiveMiningDisplay extends StatelessWidget {
  const ActiveMiningDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    final priceProvider = context.watch<CryptoPriceProvider>();
    final miners = gameState.gpus;

    if (miners.isEmpty) {
      return _NoMiningCard();
    }

    // Group miners by coin they're mining
    final Map<String, List<GPU>> minersByCoin = {};
    for (final miner in miners) {
      minersByCoin.putIfAbsent(miner.miningCoinId, () => []);
      minersByCoin[miner.miningCoinId]!.add(miner);
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
                  CyberpunkTheme.accentGreen.withOpacity(0.2),
                  CyberpunkTheme.primaryBlue.withOpacity(0.1),
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
                    color: CyberpunkTheme.accentGreen.withOpacity(0.2),
                    border: Border.all(
                      color: CyberpunkTheme.accentGreen.withOpacity(0.5),
                    ),
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    color: CyberpunkTheme.accentGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACTIVE MINING',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: CyberpunkTheme.textTertiary,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${minersByCoin.length} Coin${minersByCoin.length != 1 ? 's' : ''} Active',
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CyberpunkTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                _PulsingDot(),
              ],
            ),
          ),

          // Per-coin mining breakdown
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: minersByCoin.entries.map((entry) {
                final coinId = entry.key;
                final coinMiners = entry.value;
                return _CoinMiningRow(
                  coinId: coinId,
                  miners: coinMiners,
                  priceProvider: priceProvider,
                );
              }).toList(),
            ),
          ),

          // Total summary
          _TotalSummary(miners: miners),
        ],
      ),
    );
  }
}

/// Row showing mining stats for a single coin
class _CoinMiningRow extends StatelessWidget {
  final String coinId;
  final List<GPU> miners;
  final CryptoPriceProvider priceProvider;

  const _CoinMiningRow({
    required this.coinId,
    required this.miners,
    required this.priceProvider,
  });

  @override
  Widget build(BuildContext context) {
    final crypto = priceProvider.getCrypto(coinId);
    final coinSymbol = crypto?.symbol ?? coinId.toUpperCase().substring(0, 3);
    final coinName = crypto?.name ?? _formatCoinName(coinId);
    
    // Calculate hashrate with smart unit display
    final hashRateInfo = _calculateSmartHashRate(miners);
    
    // Get dominant miner type for this coin
    final minerTypes = miners.map((m) => m.minerType).toSet();
    final primaryType = minerTypes.first;
    
    Color typeColor;
    IconData typeIcon;
    switch (primaryType) {
      case MinerType.cpu:
        typeColor = CyberpunkTheme.accentCyan;
        typeIcon = Icons.memory;
        break;
      case MinerType.gpu:
        typeColor = CyberpunkTheme.accentGreen;
        typeIcon = Icons.developer_board;
        break;
      case MinerType.asic:
        typeColor = CyberpunkTheme.accentOrange;
        typeIcon = Icons.precision_manufacturing;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CyberpunkTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: typeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Coin icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                coinSymbol.substring(0, coinSymbol.length > 3 ? 3 : coinSymbol.length),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Coin info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      coinSymbol,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CyberpunkTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 10, color: typeColor),
                          const SizedBox(width: 4),
                          Text(
                            '${miners.length}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
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
          
          // Hashrate with smart units
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hashRateInfo['display'] as String,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CyberpunkTheme.accentGreen,
                ),
              ),
              Text(
                '${(miners.fold<double>(0, (sum, m) => sum + m.powerWatts)).toStringAsFixed(0)}W',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: CyberpunkTheme.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Calculate hash rate with smart unit selection based on algorithm
  Map<String, dynamic> _calculateSmartHashRate(List<GPU> miners) {
    if (miners.isEmpty) {
      return {'display': '0 H/s', 'value': 0.0, 'unit': 'H/s'};
    }
    
    // Get the algorithm from the first miner
    final algorithm = miners.first.algorithm;
    
    // Sum up hash rates in their native units
    double totalHashRate = 0;
    String nativeUnit = miners.first.hashRateUnit;
    
    for (final miner in miners) {
      // If all miners have same unit, just sum
      if (miner.hashRateUnit == nativeUnit) {
        totalHashRate += miner.hashRate;
      } else {
        // Convert to MH/s then sum
        totalHashRate += miner.hashRateInMHs;
        nativeUnit = 'MH/s';
      }
    }
    
    // Smart unit display based on algorithm type
    String displayUnit;
    double displayValue;
    
    switch (algorithm) {
      case 'SHA-256':
        // ASIC miners for Bitcoin - display in TH/s
        if (totalHashRate >= 1000 && nativeUnit == 'TH/s') {
          displayValue = totalHashRate / 1000;
          displayUnit = 'PH/s';
        } else {
          displayValue = totalHashRate;
          displayUnit = nativeUnit;
        }
        break;
        
      case 'RandomX':
        // CPU miners for Monero - display in KH/s or H/s
        displayValue = totalHashRate;
        displayUnit = nativeUnit; // Usually KH/s
        break;
        
      case 'Ethash':
      case 'KawPow':
      case 'Autolykos':
        // GPU miners - display in MH/s or GH/s if large
        if (totalHashRate >= 1000) {
          displayValue = totalHashRate / 1000;
          displayUnit = 'GH/s';
        } else {
          displayValue = totalHashRate;
          displayUnit = 'MH/s';
        }
        break;
        
      case 'Scrypt':
        // Scrypt miners (LTC, DOGE) - typically MH/s for GPUs
        displayValue = totalHashRate;
        displayUnit = nativeUnit;
        break;
        
      default:
        displayValue = totalHashRate;
        displayUnit = nativeUnit;
    }
    
    // Format the display value
    String formatted;
    if (displayValue >= 100) {
      formatted = displayValue.toStringAsFixed(0);
    } else if (displayValue >= 10) {
      formatted = displayValue.toStringAsFixed(1);
    } else {
      formatted = displayValue.toStringAsFixed(2);
    }
    
    return {
      'display': '$formatted $displayUnit',
      'value': displayValue,
      'unit': displayUnit,
    };
  }

  String _formatCoinName(String coinId) {
    return coinId
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

/// Summary row showing total stats
class _TotalSummary extends StatelessWidget {
  final List<GPU> miners;

  const _TotalSummary({required this.miners});

  @override
  Widget build(BuildContext context) {
    final totalPower = miners.fold<double>(0, (sum, m) => sum + m.powerWatts);
    
    // Count by type
    int cpuCount = 0, gpuCount = 0, asicCount = 0;
    for (final m in miners) {
      switch (m.minerType) {
        case MinerType.cpu: cpuCount++; break;
        case MinerType.gpu: gpuCount++; break;
        case MinerType.asic: asicCount++; break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberpunkTheme.backgroundDark.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (cpuCount > 0)
            _MiniStat(
              icon: Icons.memory,
              label: 'CPUs',
              value: '$cpuCount',
              color: CyberpunkTheme.accentCyan,
            ),
          if (gpuCount > 0)
            _MiniStat(
              icon: Icons.developer_board,
              label: 'GPUs',
              value: '$gpuCount',
              color: CyberpunkTheme.accentGreen,
            ),
          if (asicCount > 0)
            _MiniStat(
              icon: Icons.precision_manufacturing,
              label: 'ASICs',
              value: '$asicCount',
              color: CyberpunkTheme.accentOrange,
            ),
          _MiniStat(
            icon: Icons.bolt,
            label: 'Power',
            value: '${(totalPower / 1000).toStringAsFixed(1)} kW',
            color: CyberpunkTheme.accentPurple,
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: CyberpunkTheme.textTertiary,
          ),
        ),
      ],
    );
  }
}

/// Simple card when no mining is happening
class _NoMiningCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: CyberpunkTheme.modernCard(),
      child: Row(
        children: [
          Icon(
            Icons.power_off_rounded,
            size: 40,
            color: CyberpunkTheme.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Active Mining',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CyberpunkTheme.textPrimary,
                  ),
                ),
                Text(
                  'Purchase mining hardware from the Shop',
                  style: GoogleFonts.inter(
                    fontSize: 12,
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
}

/// Pulsing indicator dot
class _PulsingDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CyberpunkTheme.accentGreen,
        boxShadow: [
          BoxShadow(
            color: CyberpunkTheme.accentGreen.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1000.ms)
      .fade(begin: 0.6, end: 1.0, duration: 1000.ms);
  }
}
