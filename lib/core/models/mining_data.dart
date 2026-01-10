import 'historical_data.dart';
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
  double calculateDailyRevenue(double yourHashRateMHs, double coinPrice, {DateTime? gameDate, String? coinId}) {
    double coinsPerDay = calculateCoinsPerDay(yourHashRateMHs, gameDate: gameDate, coinId: coinId);
    return coinsPerDay * coinPrice;
  }

  /// Calculate expected coins per day for given hash rate
  double calculateCoinsPerDay(double yourHashRateMHs, {DateTime? gameDate, String? coinId}) {
    if (!isMineable) return 0.0;
    
    // Determine effective coin ID
    final String effectiveCoinId = coinId ?? _getCoinIdFromAlgo(algorithm);
    
    // Convert your hash rate to same unit as network
    double yourHashRate = _convertToNetworkUnit(yourHashRateMHs);
    
    // Apply difficulty scaling if date is provided
    double effectiveNetworkHashRate = networkHashRate;
    double effectiveBlockReward = blockReward;
    
    if (gameDate != null) {
      // If coin is not launched yet, 0 revenue
      if (!HistoricalPriceData.coinExistsAt(effectiveCoinId, gameDate)) {
        return 0.0;
      }
      
      // Get effective network hashrate (Historical Scaling)
      effectiveNetworkHashRate = getEffectiveNetworkHashRate(gameDate, coinId: effectiveCoinId);
      
      // ETH Merge Cutoff (PoS)
      if (effectiveCoinId == 'ethereum' && gameDate.isAfter(DateTime(2022, 9, 15))) {
        return 0.0; // Mining ended
      }

      effectiveBlockReward = getEffectiveBlockReward(gameDate, coinId: effectiveCoinId);
    }
    
    // Your percentage of network hash rate
    double yourPercentage = yourHashRate / (effectiveNetworkHashRate > 0 ? effectiveNetworkHashRate : 1.0);
    
    // Blocks per day
    double blocksPerDay = (86400 / (blockTime > 0 ? blockTime : 600));
    
    // Your expected coins per day
    return blocksPerDay * effectiveBlockReward * yourPercentage;
  }
  
  /// Get effective block reward based on date (Halvings)
  double getEffectiveBlockReward(DateTime date, {String? coinId}) {
    final String id = coinId ?? _getCoinIdFromAlgo(algorithm);
    
    switch (id) {
      case 'bitcoin':
      case 'bitcoin-cash': // Copied BTC logic for BCH history
         if (date.isBefore(DateTime(2012, 11, 28))) return 50.0;
         if (date.isBefore(DateTime(2016, 7, 9))) return 25.0;
         if (date.isBefore(DateTime(2020, 5, 11))) return 12.5;
         if (date.isBefore(DateTime(2024, 4, 19))) return 6.25;
         return 3.125;
         
      case 'litecoin':
         if (date.isBefore(DateTime(2015, 8, 25))) return 50.0;
         if (date.isBefore(DateTime(2019, 8, 5))) return 25.0;
         if (date.isBefore(DateTime(2023, 8, 2))) return 12.5;
         return 6.25;
         
      case 'ethereum':
         if (date.isAfter(DateTime(2022, 9, 15))) return 0.0; // The Merge
         if (date.isBefore(DateTime(2017, 10, 16))) return 5.0; // Genesis -> Byzantium
         if (date.isBefore(DateTime(2019, 2, 28))) return 3.0; // Byzantium -> Constantinople
         return 2.0; // Stable
         
      case 'ethereum-classic':
         // ECIP-1017: 20% reduction every 5M blocks (~2.5 yrs)
         if (date.isBefore(DateTime(2017, 12, 11))) return 5.0;
         if (date.isBefore(DateTime(2020, 3, 17))) return 4.0;
         if (date.isBefore(DateTime(2022, 4, 25))) return 3.2;
         if (date.isBefore(DateTime(2024, 5, 31))) return 2.56;
         return 2.048;

      case 'dogecoin':
         if (date.isBefore(DateTime(2014, 2, 14))) return 500000.0; // Early chaotic era
         if (date.isBefore(DateTime(2014, 4, 28))) return 250000.0;
         if (date.isBefore(DateTime(2014, 7, 2))) return 125000.0;
         if (date.isBefore(DateTime(2014, 9, 12))) return 62500.0;
         if (date.isBefore(DateTime(2014, 12, 25))) return 31250.0; // Merry Christmas
         return 10000.0; // Perpetual
         
      case 'ravencoin':
         if (date.isBefore(DateTime(2022, 1, 11))) return 5000.0;
         return 2500.0;
         
      case 'monero':
         // Emission curve approximation
         int year = date.year;
         if (year <= 2014) return 17.0;
         if (year <= 2015) return 12.0;
         if (year <= 2016) return 8.0;
         if (year <= 2017) return 6.0;
         if (year <= 2019) return 3.0;
         if (year <= 2021) return 1.2;
         return 0.6; // Tail emission
      
      case 'zcash':
         if (date.isBefore(DateTime(2020, 11, 18))) return 12.5;
         if (date.isBefore(DateTime(2024, 11, 20))) return 6.25;
         return 3.125;
         
     case 'dash':
         // 7.14% reduction per year
         int yearsSince2014 = date.year - 2014;
         if (yearsSince2014 < 0) return 500.0; // Pre-launch?
         double reward = 500.0;
         for (int i = 0; i < yearsSince2014; i++) {
            reward *= 0.9286;
         }
         return reward;
         
      case 'ergo':
         // 75 -> drop 3 every 3 months. 
         // Simplified: Yearly drops.
         if (date.year <= 2019) return 75.0;
         if (date.year == 2020) return 66.0;
         if (date.year == 2021) return 54.0;
         if (date.year == 2022) return 45.0;
         if (date.year == 2023) return 36.0;
         return 30.0;   
    }
    
    return blockReward; // Default static reward from DB
  }

  /// Get effective network hash rate for a given date
  double getEffectiveNetworkHashRate(DateTime date, {String? coinId}) {
    double effectiveNetworkHashRate = networkHashRate;
    final int year = date.year;
    final String effectiveCoinId = coinId ?? _getCoinIdFromAlgo(algorithm);
    
    // Scaling for Bitcoin/SHA-256 (Historical Growth)
    if (effectiveCoinId == 'bitcoin') {
      if (year == 2009) effectiveNetworkHashRate *= 0.000000000001; // 1e-12
      else if (year <= 2010) effectiveNetworkHashRate *= 0.00000000002; // 2e-11
      else if (year <= 2011) effectiveNetworkHashRate *= 0.000000001;
      else if (year <= 2012) effectiveNetworkHashRate *= 0.00000002;
      else if (year <= 2015) effectiveNetworkHashRate *= 0.000002;
      else if (year <= 2019) effectiveNetworkHashRate *= 0.002;
      else if (year <= 2022) effectiveNetworkHashRate *= 0.2;
    }
    
    return effectiveNetworkHashRate;
  }
  
  /// Calculate mining profitability (revenue - electricity cost)
  double calculateProfitability(
    double yourHashRateMHs,
    double powerWatts,
    double coinPrice,
    double electricityRate, // USD per kWh
    {DateTime? gameDate}
  ) {
    double revenue = calculateDailyRevenue(yourHashRateMHs, coinPrice, gameDate: gameDate);
    double powerCostPerDay = (powerWatts / 1000) * 24 * electricityRate;
    return revenue - powerCostPerDay;
  }
  
  double _convertToNetworkUnit(double mhs) {
    switch (hashRateUnit) {
      case 'H/s': return mhs * 1000000;
      case 'KH/s': return mhs * 1000;
      case 'MH/s': return mhs;
      case 'GH/s': return mhs / 1000;
      case 'TH/s': return mhs / 1000000;
      case 'PH/s': return mhs / 1000000000;
      case 'Sol/s': return mhs * 1000000;
      default: return mhs;
    }
  }

  static String _getCoinIdFromAlgo(String algo) {
    switch (algo) {
      case 'SHA-256': return 'bitcoin';
      case 'Ethash': return 'ethereum-classic';
      case 'Scrypt': return 'litecoin';
      case 'RandomX': return 'monero';
      case 'Equihash': return 'zcash';
      case 'KawPow': return 'ravencoin';
      default: return '';
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
      networkHashRate: 8000000.0, // Network is ~8000 TH/s = 8,000,000 GH/s (increased 10x for balance)
      blockReward: 1.25, // Reduced from 12.5 to 1.25 (10x reduction)
      blockTime: 150,
      difficulty: 25000000.0,
      hashRateUnit: 'MH/s', // WhatToMine uses MH/s for Scrypt
    ),
    
    'dogecoin': MiningData(
      algorithm: 'Scrypt',
      isMineable: true,
      networkHashRate: 900000.0, // Network is ~900 TH/s = 900,000 GH/s = 900,000,000 MH/s
      blockReward: 100.0, // Reduced from 10000 to 100 for better game balance
      blockTime: 60,
      difficulty: 9000000.0,
      hashRateUnit: 'MH/s', // WhatToMine uses MH/s for Scrypt
    ),
    
    'monero': MiningData(
      algorithm: 'RandomX',
      isMineable: true,
      networkHashRate: 270000000.0, // Network is ~270 GH/s = 270,000,000 KH/s (increased 100x for balance)
      blockReward: 0.06, // Reduced from 0.6 to 0.06 (10x reduction)
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
      networkHashRate: 900000000000.0, // Network is ~900.0 GSol/s = 900,000,000,000 Sol/s (increased 100x for balance)
      blockReward: 0.3125, // Reduced from 3.125 to 0.3125 (10x reduction)
      blockTime: 75,
      difficulty: 53000000.0,
      hashRateUnit: 'Sol/s', // WhatToMine uses Sol/s (Solutions/s) - treat as H/s scale
    ),
    
    'ravencoin': MiningData(
      algorithm: 'KawPow',
      isMineable: true,
      networkHashRate: 6500.0, // Network is ~6.5 TH/s = 6500 GH/s
      blockReward: 2500.0,
      blockTime: 60,
      difficulty: 68000.0,
      hashRateUnit: 'GH/s', // KAWPOW networks report in GH/s
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
      algorithm: 'KawPow',
      isMineable: true,
      networkHashRate: 950.0, // 950 GH/s
      blockReward: 10000.0,
      blockTime: 60,
      difficulty: 12500.0,
      hashRateUnit: 'GH/s', // KAWPOW networks report in GH/s
    ),
    
    'clore-ai': MiningData(
      algorithm: 'KawPow',
      isMineable: true,
      networkHashRate: 1200.0, // 1.2 TH/s = 1200 GH/s
      blockReward: 125.0,
      blockTime: 60,
      difficulty: 15200.0,
      hashRateUnit: 'GH/s', // KAWPOW networks report in GH/s
    ),
    
    'neoxa': MiningData(
      algorithm: 'KAWPOW',
      isMineable: true,
      networkHashRate: 750.0, // 750 GH/s
      blockReward: 7500.0,
      blockTime: 120,
      difficulty: 9500.0,
      hashRateUnit: 'GH/s', // KAWPOW networks report in GH/s
    ),
    'tether': MiningData(
      algorithm: 'N/A',
      isMineable: false,
      networkHashRate: 0,
      blockReward: 0,
      blockTime: 0,
      difficulty: 0,
      hashRateUnit: 'H/s',
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
    DateTime? gameDate,
  }) {
    final miningData = MiningDatabase.getMiningData(coinId);
    
    if (miningData == null || !miningData.isMineable) {
      return {
        'isMineable': false,
        'reason': miningData == null ? 'Unknown coin' : 'Proof-of-Stake (cannot mine)',
      };
    }
    
    final dailyRevenue = miningData.calculateDailyRevenue(hashRateMHs, coinPrice, gameDate: gameDate);
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
