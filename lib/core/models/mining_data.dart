/// Real-world mining data for cryptocurrencies
/// Based on actual mining algorithms, network difficulties, and rewards

class MiningData {
  final String algorithm;
  final bool isMineable;
  final double networkHashRate; // In TH/s
  final double blockReward;
  final double blockTime; // In seconds
  final double difficulty;
  final String hashRateUnit; // H/s, KH/s, MH/s, GH/s, TH/s
  
  const MiningData({
    required this.algorithm,
    required this.isMineable,
    required this.networkHashRate,
    required this.blockReward,
    required this.blockTime,
    required this.difficulty,
    required this.hashRateUnit,
  });
  
  /// Calculate expected mining revenue per day for given hash rate
  double calculateDailyRevenue(double yourHashRateMHs, double coinPrice) {
    if (!isMineable) return 0.0;
    
    // Convert your hash rate to same unit as network
    double yourHashRate = _convertToNetworkUnit(yourHashRateMHs);
    
    // Your percentage of network hash rate
    double yourPercentage = yourHashRate / networkHashRate;
    
    // Blocks per day
    double blocksPerDay = (86400 / blockTime);
    
    // Your expected coins per day
    double coinsPerDay = blocksPerDay * blockReward * yourPercentage;
    
    // Revenue in USD
    return coinsPerDay * coinPrice;
  }
  
  /// Calculate mining profitability (revenue - electricity cost)
  double calculateProfitability(
    double yourHashRateMHs,
    double powerWatts,
    double coinPrice,
    double electricityRate, // USD per kWh
  ) {
    double revenue = calculateDailyRevenue(yourHashRateMHs, coinPrice);
    double powerCostPerDay = (powerWatts / 1000) * 24 * electricityRate;
    return revenue - powerCostPerDay;
  }
  
  double _convertToNetworkUnit(double mhs) {
    switch (hashRateUnit) {
      case 'H/s':
        return mhs * 1000000; // MH to H
      case 'KH/s':
        return mhs * 1000; // MH to KH
      case 'MH/s':
        return mhs; // Already MH
      case 'GH/s':
        return mhs / 1000; // MH to GH
      case 'TH/s':
        return mhs / 1000000; // MH to TH
      case 'PH/s':
        return mhs / 1000000000; // MH to PH
      case 'Sol/s': // Solutions per second (treat as H/s scale)
        return mhs * 1000000; // MH to Sol/s (H/s scale) (Sol/s equivalent)
      default:
        return mhs;
    }
  }
}

/// Real-world mining data for major cryptocurrencies
class MiningDatabase {
  static const Map<String, MiningData> data = {
    'bitcoin': MiningData(
      algorithm: 'SHA-256',
      isMineable: true,
      networkHashRate: 500000000.0, // Network is ~500 EH/s = 500,000,000 TH/s
      blockReward: 6.25,
      blockTime: 600,
      difficulty: 62000000000000.0,
      hashRateUnit: 'TH/s', // WhatToMine uses TH/s for Bitcoin
    ),
    
    'ethereum': MiningData(
      algorithm: 'Proof-of-Stake',
      isMineable: false, // Can't mine ETH anymore (PoS)
      networkHashRate: 0,
      blockReward: 0,
      blockTime: 12,
      difficulty: 0,
      hashRateUnit: 'MH/s',
    ),
    
    'litecoin': MiningData(
      algorithm: 'Scrypt',
      isMineable: true,
      networkHashRate: 800000.0, // Network is ~800 TH/s = 800,000 GH/s = 800,000,000 MH/s
      blockReward: 12.5,
      blockTime: 150,
      difficulty: 25000000.0,
      hashRateUnit: 'MH/s', // WhatToMine uses MH/s for Scrypt
    ),
    
    'dogecoin': MiningData(
      algorithm: 'Scrypt',
      isMineable: true,
      networkHashRate: 900000.0, // Network is ~900 TH/s = 900,000 GH/s = 900,000,000 MH/s
      blockReward: 10000.0,
      blockTime: 60,
      difficulty: 9000000.0,
      hashRateUnit: 'MH/s', // WhatToMine uses MH/s for Scrypt
    ),
    
    'monero': MiningData(
      algorithm: 'RandomX',
      isMineable: true,
      networkHashRate: 2500000.0, // Network is ~2.5 GH/s = 2,500,000 KH/s
      blockReward: 0.6,
      blockTime: 120,
      difficulty: 300000000.0,
      hashRateUnit: 'KH/s', // WhatToMine uses KH/s for Monero
    ),
    
    'ethereum-classic': MiningData(
      algorithm: 'Ethash',
      isMineable: true,
      networkHashRate: 180000.0, // Network is ~180 TH/s = 180,000 GH/s = 180,000,000 MH/s
      blockReward: 2.56,
      blockTime: 13,
      difficulty: 2400000000000000.0,
      hashRateUnit: 'GH/s', // WhatToMine uses GH/s for Ethash
    ),
    
    'bitcoin-cash': MiningData(
      algorithm: 'SHA-256',
      isMineable: true,
      networkHashRate: 3500000.0, // 3.5 EH/s in TH/s
      blockReward: 6.25,
      blockTime: 600,
      difficulty: 430000000000.0,
      hashRateUnit: 'TH/s',
    ),
    
    'zcash': MiningData(
      algorithm: 'Equihash',
      isMineable: true,
      networkHashRate: 8500000000.0, // Network is ~8.5 GSol/s = 8,500,000,000 Sol/s
      blockReward: 3.125,
      blockTime: 75,
      difficulty: 53000000.0,
      hashRateUnit: 'Sol/s', // WhatToMine uses Sol/s (Solutions/s) - treat as H/s scale
    ),
    
    'ravencoin': MiningData(
      algorithm: 'KAWPOW',
      isMineable: true,
      networkHashRate: 6500.0, // Network is ~6.5 TH/s = 6,500 GH/s = 6,500,000 MH/s
      blockReward: 2500.0,
      blockTime: 60,
      difficulty: 68000.0,
      hashRateUnit: 'MH/s', // WhatToMine uses MH/s for KAWPOW
    ),
    
    'ergo': MiningData(
      algorithm: 'Autolykos',
      isMineable: true,
      networkHashRate: 45000.0, // Network is ~45 TH/s = 45,000 GH/s
      blockReward: 51.0,
      blockTime: 120,
      difficulty: 1800000000000000.0,
      hashRateUnit: 'GH/s', // WhatToMine uses GH/s for Autolykos
    ),
    
    'flux': MiningData(
      algorithm: 'ZelHash',
      isMineable: true,
      networkHashRate: 25000000000.0, // Network is ~25 MSol/s = 25,000,000,000 Sol/s
      blockReward: 37.5,
      blockTime: 120,
      difficulty: 120000.0,
      hashRateUnit: 'Sol/s', // WhatToMine uses Sol/s - treat as H/s scale
    ),
    
    'conflux': MiningData(
      algorithm: 'Octopus',
      isMineable: true,
      networkHashRate: 8500.0, // 8.5 TH/s
      blockReward: 2.0,
      blockTime: 0.5,
      difficulty: 850000.0,
      hashRateUnit: 'MH/s',
    ),
    
    'kaspa': MiningData(
      algorithm: 'kHeavyHash',
      isMineable: true,
      networkHashRate: 450000.0, // 450 PH/s
      blockReward: 269.0,
      blockTime: 1.0,
      difficulty: 22000000000000.0,
      hashRateUnit: 'GH/s',
    ),
    
    'alephium': MiningData(
      algorithm: 'Blake3',
      isMineable: true,
      networkHashRate: 1200.0, // 1.2 TH/s
      blockReward: 3.0,
      blockTime: 64,
      difficulty: 15000000000.0,
      hashRateUnit: 'GH/s',
    ),
    
    'nexa': MiningData(
      algorithm: 'NexaPow',
      isMineable: true,
      networkHashRate: 85000.0, // 85 TH/s
      blockReward: 10000000.0,
      blockTime: 120,
      difficulty: 42000000.0,
      hashRateUnit: 'GH/s',
    ),
    
    'dash': MiningData(
      algorithm: 'X11',
      isMineable: true,
      networkHashRate: 4500000.0, // Network is ~4.5 PH/s = 4,500,000 GH/s
      blockReward: 2.67,
      blockTime: 150,
      difficulty: 75000000.0,
      hashRateUnit: 'GH/s', // WhatToMine uses GH/s for Dash
    ),
    
    'bitcoin-gold': MiningData(
      algorithm: 'Equihash-BTG',
      isMineable: true,
      networkHashRate: 2800000000.0, // Network is ~2.8 MSol/s = 2,800,000,000 Sol/s
      blockReward: 6.25,
      blockTime: 600,
      difficulty: 145000.0,
      hashRateUnit: 'Sol/s', // WhatToMine uses Sol/s - treat as H/s scale
    ),
    
    'vertcoin': MiningData(
      algorithm: 'Verthash',
      isMineable: true,
      networkHashRate: 1800.0, // 1.8 GH/s
      blockReward: 12.5,
      blockTime: 150,
      difficulty: 92000.0,
      hashRateUnit: 'MH/s',
    ),
    
    'firo': MiningData(
      algorithm: 'FiroPow',
      isMineable: true,
      networkHashRate: 2300.0, // 2.3 TH/s
      blockReward: 6.25,
      blockTime: 150,
      difficulty: 8500.0,
      hashRateUnit: 'MH/s',
    ),
    
    'beam': MiningData(
      algorithm: 'BeamHash III',
      isMineable: true,
      networkHashRate: 12500000000.0, // Network is ~12.5 MSol/s = 12,500,000,000 Sol/s
      blockReward: 40.0,
      blockTime: 60,
      difficulty: 42000000.0,
      hashRateUnit: 'Sol/s', // WhatToMine uses Sol/s - treat as H/s scale
    ),
    
    'kadena': MiningData(
      algorithm: 'Blake2S',
      isMineable: true,
      networkHashRate: 285000.0, // 285 TH/s
      blockReward: 0.83,
      blockTime: 30,
      difficulty: 950000000000000.0,
      hashRateUnit: 'TH/s',
    ),
    
    'raptoreum': MiningData(
      algorithm: 'GhostRider',
      isMineable: true,
      networkHashRate: 3500.0, // 3.5 GH/s
      blockReward: 2500.0,
      blockTime: 120,
      difficulty: 18500000.0,
      hashRateUnit: 'MH/s',
    ),
    
    'neurai': MiningData(
      algorithm: 'KAWPOW',
      isMineable: true,
      networkHashRate: 950.0, // 950 GH/s
      blockReward: 10000.0,
      blockTime: 60,
      difficulty: 12500.0,
      hashRateUnit: 'MH/s',
    ),
    
    'clore-ai': MiningData(
      algorithm: 'KAWPOW',
      isMineable: true,
      networkHashRate: 1200.0, // 1.2 TH/s
      blockReward: 125.0,
      blockTime: 60,
      difficulty: 15200.0,
      hashRateUnit: 'MH/s',
    ),
    
    'neoxa': MiningData(
      algorithm: 'KAWPOW',
      isMineable: true,
      networkHashRate: 750.0, // 750 GH/s
      blockReward: 7500.0,
      blockTime: 120,
      difficulty: 9500.0,
      hashRateUnit: 'MH/s',
    ),
  };
  
  /// Get mining data for a cryptocurrency
  static MiningData? getMiningData(String coinId) {
    return data[coinId.toLowerCase()];
  }
  
  /// Check if a coin is mineable
  static bool isMineable(String coinId) {
    return data[coinId.toLowerCase()]?.isMineable ?? false;
  }
  
  /// Get all mineable coins
  static List<String> getMineableCoins() {
    return data.entries
        .where((entry) => entry.value.isMineable)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// Calculate best coin to mine based on profitability
  static String? getBestCoinToMine(
    double hashRateMHs,
    double powerWatts,
    Map<String, double> prices,
    double electricityRate,
  ) {
    String? bestCoin;
    double bestProfit = double.negativeInfinity;
    
    for (var entry in data.entries) {
      if (!entry.value.isMineable) continue;
      
      final price = prices[entry.key] ?? 0.0;
      if (price == 0) continue;
      
      final profit = entry.value.calculateProfitability(
        hashRateMHs,
        powerWatts,
        price,
        electricityRate,
      );
      
      if (profit > bestProfit) {
        bestProfit = profit;
        bestCoin = entry.key;
      }
    }
    
    return bestCoin;
  }
}

/// Mining profitability calculator
class MiningCalculator {
  /// Calculate comprehensive mining stats
  static Map<String, dynamic> calculateMiningStats({
    required String coinId,
    required double hashRateMHs,
    required double powerWatts,
    required double coinPrice,
    double electricityRate = 0.12, // Default $0.12 per kWh
  }) {
    final miningData = MiningDatabase.getMiningData(coinId);
    
    if (miningData == null || !miningData.isMineable) {
      return {
        'isMineable': false,
        'reason': miningData == null ? 'Unknown coin' : 'Proof-of-Stake (cannot mine)',
      };
    }
    
    final dailyRevenue = miningData.calculateDailyRevenue(hashRateMHs, coinPrice);
    final dailyPowerCost = (powerWatts / 1000) * 24 * electricityRate;
    final dailyProfit = dailyRevenue - dailyPowerCost;
    
    final monthlyProfit = dailyProfit * 30;
    final yearlyProfit = dailyProfit * 365;
    
    return {
      'isMineable': true,
      'algorithm': miningData.algorithm,
      'dailyRevenue': dailyRevenue,
      'dailyPowerCost': dailyPowerCost,
      'dailyProfit': dailyProfit,
      'monthlyProfit': monthlyProfit,
      'yearlyProfit': yearlyProfit,
      'isProfitable': dailyProfit > 0,
      'roi': dailyRevenue > 0 ? (dailyPowerCost / dailyRevenue) * 100 : 0,
    };
  }
}
