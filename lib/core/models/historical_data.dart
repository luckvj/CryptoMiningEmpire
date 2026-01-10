// Historical price data and market events for dynamic time simulation
import 'dart:math';

/// Monthly historical prices for major cryptocurrencies (approximate averages)
class HistoricalPriceData {
  static final Random _random = Random();
  
  /// Coin creation/launch dates
  static final Map<String, DateTime> coinCreationDates = {
    'bitcoin': DateTime(2009, 1, 3),
    'ethereum': DateTime(2015, 7, 30),
    'litecoin': DateTime(2011, 10, 7),
    'dogecoin': DateTime(2013, 12, 6),
    'monero': DateTime(2014, 4, 18),
    'dash': DateTime(2014, 1, 18),
    'tether': DateTime(2014, 10, 6), // USDT launch
    'zcash': DateTime(2016, 10, 28),
    'ethereum-classic': DateTime(2016, 7, 20),
    'ravencoin': DateTime(2018, 1, 3),
    'ergo': DateTime(2019, 7, 1),
    'kadena': DateTime(2019, 11, 4),
    'kaspa': DateTime(2021, 11, 7),
    'flux': DateTime(2018, 9, 10),
    'conflux': DateTime(2020, 10, 29),
    'solana': DateTime(2020, 3, 16),
    'cardano': DateTime(2017, 9, 29),
    'polkadot': DateTime(2020, 5, 26),
    'avalanche-2': DateTime(2020, 9, 21),
    'chainlink': DateTime(2017, 9, 19),
    'uniswap': DateTime(2020, 9, 17),
    'shiba-inu': DateTime(2020, 8, 1),
    'pepe': DateTime(2023, 4, 17),
    'ripple': DateTime(2012, 9, 1), // XRP
  };
  
  /// List of coins that can be mined (for click miner)
  static final Set<String> mineableCoins = {
    'bitcoin', 'litecoin', 'dogecoin', 'monero', 'dash', 'zcash',
    'ethereum-classic', 'ravencoin', 'ergo', 'kadena', 'kaspa', 'flux', 'conflux',
  };
  
  /// Check if a coin is mineable
  static bool isCoinMineable(String coinId) {
    return mineableCoins.contains(coinId);
  }
  
  /// Check if Bitcoin is GPU-mineable at a given date (before ASIC era ~2013)
  static bool isBitcoinGpuMineableAt(DateTime date) {
    // ASICs started dominating in late 2013
    // Before that, GPUs could profitably mine Bitcoin
    return date.year < 2014;
  }
  
  /// Get the algorithm that should be used for Bitcoin at a given date
  static String getBitcoinAlgorithmForEra(DateTime date) {
    // In early eras, treat Bitcoin as "GPU-mineable SHA-256"
    // After 2013, it's ASIC-only
    return 'SHA-256';
  }
  
  /// Check if a coin existed at a given date
  static bool coinExistsAt(String coinId, DateTime date) {
    final creationDate = coinCreationDates[coinId];
    if (creationDate == null) {
      // Unknown coins default to existing after 2020
      return date.year >= 2020;
    }
    return date.isAfter(creationDate) || date.isAtSameMomentAs(creationDate);
  }
  
  /// Get the launch year for a coin
  static int getLaunchYear(String coinId) {
    return coinCreationDates[coinId]?.year ?? 2020;
  }
  
  /// Check if a coin is mineable at a given date
  static bool isCoinMineableAt(String coinId, DateTime date) {
    if (!coinExistsAt(coinId, date)) return false;
    if (!mineableCoins.contains(coinId)) return false;
    
    // Special case: Ethereum was mineable until Sept 2022 (The Merge)
    if (coinId == 'ethereum') {
      return date.isBefore(DateTime(2022, 9, 15));
    }
    
    return true;
  }
  
  /// Get historical price for a coin at a specific date
  /// Get historical price for a coin at a specific date
  static double getPrice(String coinId, DateTime date) {
    // Return 0 if coin didn't exist yet
    if (!coinExistsAt(coinId, date)) return 0.0;
    
    final prices = _monthlyPrices[coinId] ?? {};
    if (prices.isEmpty) return 0.0; // No data available

    // 1. Sort available months for this coin
    final sortedKeys = prices.keys.toList()..sort();
    
    // 2. Format current date as key
    final currentKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';

    // 3. Find the closest "prev" and "next" data points
    String? prevKey;
    String? nextKey;

    for (int i = 0; i < sortedKeys.length; i++) {
       if (sortedKeys[i] == currentKey) {
         prevKey = sortedKeys[i];
         if (i + 1 < sortedKeys.length) nextKey = sortedKeys[i+1];
         break;
       } else if (sortedKeys[i].compareTo(currentKey) > 0) {
         nextKey = sortedKeys[i];
         if (i > 0) prevKey = sortedKeys[i-1];
         break;
       }
    }

    // Default if we are before any data
    if (prevKey == null && nextKey != null) return prices[nextKey]! * 0.1; // 10% of first recorded price
    // Default if we are after all data
    if (nextKey == null) return prices[prevKey] ?? 0.0;

    // 4. Interpolate between prev and next
    final prevPrice = prices[prevKey]!;
    final nextPrice = prices[nextKey]!;

    // Parse keys into dates for distance calculation
    final prevParts = prevKey!.split('-');
    final nextParts = nextKey!.split('-');
    final prevDate = DateTime(int.parse(prevParts[0]), int.parse(prevParts[1]), 1);
    final nextDate = DateTime(int.parse(nextParts[0]), int.parse(nextParts[1]), 1);

    final totalDays = nextDate.difference(prevDate).inDays;
    final progressDays = date.difference(prevDate).inDays;

    if (totalDays <= 0) return prevPrice;
    
    double progress = (progressDays / totalDays).clamp(0.0, 1.0);
    return prevPrice + (nextPrice - prevPrice) * progress;
  }
  

  
  /// Get difficulty multiplier for a specific date
  static double getDifficultyMultiplier(DateTime date) {
    final year = date.year;
    if (year <= 2010) return 0.00001;
    if (year == 2011) return 0.0001;
    if (year == 2012) return 0.001;
    if (year == 2013) return 0.005;
    if (year == 2014) return 0.01;
    if (year == 2015) return 0.02;
    if (year == 2016) return 0.05;
    if (year == 2017) return 0.1;
    if (year == 2018) return 0.2;
    if (year == 2019) return 0.3;
    if (year == 2020) return 0.5;
    if (year == 2021) return 0.7;
    if (year == 2022) return 0.8;
    if (year == 2023) return 0.9;
    return 1.0;
  }
  
  /// Apply random volatility to a price (±5%)
  static double applyVolatility(double basePrice) {
    final volatility = 0.95 + _random.nextDouble() * 0.10; // 0.95 to 1.05
    return basePrice * volatility;
  }
  
  // Monthly price data (key format: "YYYY-MM") - Real historical BTC prices
  static final Map<String, Map<String, double>> _monthlyPrices = {
    'bitcoin': {
      // 2009 - The Genesis (Symbolic value, effectively 0)
      '2009-01': 0.00001, '2009-06': 0.00001, '2009-12': 0.00001,
      // 2010 - Real History: Starts ~0, first exchange Mar ($0.003), Pizza May ($0.004), Jul Spike ($0.08), Dec ($0.30)
      '2010-01': 0.001, '2010-02': 0.002, '2010-03': 0.003, '2010-04': 0.0035, 
      '2010-05': 0.004, '2010-06': 0.005, '2010-07': 0.07, '2010-08': 0.06, 
      '2010-09': 0.06, '2010-10': 0.11, '2010-11': 0.25, '2010-12': 0.30,
      // 2011 - First major rally to $30
      '2011-01': 0.30, '2011-02': 1.00, '2011-04': 1.00, '2011-06': 31.00, 
      '2011-07': 14.00, '2011-11': 2.50, '2011-12': 4.00,
      // 2012 - Slow recovery
      '2012-01': 6.00, '2012-06': 6.50, '2012-08': 10.00, '2012-12': 13.50,
      // 2013 - First $1000  
      '2013-01': 13.00, '2013-04': 120.00, '2013-06': 100.00, '2013-11': 1150.00, '2013-12': 750.00,
      // 2014 - Mt. Gox crash
      '2014-01': 850.00, '2014-02': 580.00, '2014-06': 600.00, '2014-12': 310.00,
      // 2015 - Bear market bottom
      '2015-01': 210.00, '2015-06': 250.00, '2015-10': 270.00, '2015-12': 430.00,
      // 2016 - Halving year, recovery
      '2016-01': 430.00, '2016-06': 650.00, '2016-07': 660.00, '2016-12': 960.00,
      // 2017 - ICO bubble, $20k ATH
      '2017-01': 1000.00, '2017-03': 1100.00, '2017-06': 2500.00, '2017-09': 4200.00, '2017-12': 19200.00,
      // 2018 - Crypto winter
      '2018-01': 13500.00, '2018-02': 10000.00, '2018-06': 6200.00, '2018-12': 3700.00,
      // 2019 - Mini bull run
      '2019-01': 3500.00, '2019-06': 11400.00, '2019-12': 7200.00,
      // 2020 - COVID crash then bull run
      '2020-01': 8600.00, '2020-03': 5000.00, '2020-05': 9500.00, '2020-10': 13500.00, '2020-12': 29000.00,
      // 2021 - $69k ATH
      '2021-01': 33000.00, '2021-04': 58000.00, '2021-05': 37000.00, '2021-11': 69000.00, '2021-12': 46000.00,
      // 2022 - Crypto winter 2
      '2022-01': 38000.00, '2022-06': 20000.00, '2022-11': 16000.00, '2022-12': 16500.00,
      // 2023 - Recovery
      '2023-01': 23000.00, '2023-06': 30500.00, '2023-10': 34500.00, '2023-12': 42500.00,
      // 2024 - ETF approval, halving, new ATH
      '2024-01': 42000.00, '2024-03': 73000.00, '2024-04': 63000.00, '2024-07': 67000.00, '2024-11': 99000.00, '2024-12': 93000.00,
      // 2025
      '2025-01': 95000.00,
    },
    'ethereum': {
      '2015-08': 1.0, '2015-12': 0.90,
      '2016-03': 12.0, '2016-06': 14.0, '2016-12': 8.0,
      '2017-03': 50.0, '2017-06': 300.0, '2017-12': 750.0,
      '2018-01': 1300.0, '2018-06': 450.0, '2018-12': 130.0,
      '2019-06': 270.0, '2019-12': 130.0,
      '2020-03': 130.0, '2020-12': 730.0,
      '2021-05': 4000.0, '2021-11': 4800.0, '2021-12': 3700.0,
      '2022-06': 1100.0, '2022-12': 1200.0,
      '2023-12': 2300.0,
      '2024-03': 3500.0, '2024-12': 3400.0,
      '2025-01': 3500.0,
    },
    'litecoin': {
      '2011-10': 0.30, '2011-12': 4.0,
      '2013-11': 40.0, '2013-12': 24.0,
      '2014-12': 2.70,
      '2017-06': 30.0, '2017-12': 300.0,
      '2018-12': 30.0,
      '2021-05': 350.0, '2021-12': 150.0,
      '2024-12': 75.0,
    },
    'dogecoin': {
      '2013-12': 0.0002,
      '2014-01': 0.001, '2014-06': 0.0002, '2014-12': 0.0001,
      '2015-12': 0.00014,
      '2016-12': 0.00022,
      '2017-01': 0.00025, '2017-06': 0.003, '2017-12': 0.006,
      '2018-01': 0.012, '2018-06': 0.003, '2018-12': 0.002,
      '2019-12': 0.002,
      '2020-07': 0.003, '2020-12': 0.004,
      '2021-01': 0.01, '2021-02': 0.05, '2021-04': 0.40, '2021-05': 0.70, '2021-12': 0.17,
      '2022-06': 0.07, '2022-12': 0.07,
      '2023-12': 0.08,
      '2024-03': 0.12, '2024-11': 0.35, '2024-12': 0.30,
      '2025-01': 0.32,
    },
    'monero': {
      '2014-04': 2.50, '2014-12': 0.50,
      '2015-12': 0.50,
      '2016-08': 12.0, '2016-12': 10.0,
      '2017-06': 50.0, '2017-12': 350.0,
      '2018-01': 470.0, '2018-06': 130.0, '2018-12': 45.0,
      '2019-06': 90.0, '2019-12': 50.0,
      '2020-12': 155.0,
      '2021-05': 500.0, '2021-12': 210.0,
      '2022-12': 145.0,
      '2023-12': 165.0,
      '2024-12': 200.0,
      '2025-01': 210.0,
    },
    'dash': {
      '2014-01': 1.0, '2014-12': 2.0,
      '2015-12': 3.50,
      '2016-12': 11.0,
      '2017-03': 100.0, '2017-12': 1500.0,
      '2018-01': 1100.0, '2018-12': 70.0,
      '2019-12': 45.0,
      '2020-12': 100.0,
      '2021-05': 350.0, '2021-12': 120.0,
      '2022-12': 45.0,
      '2024-12': 35.0,
      '2025-01': 37.0,
    },
    'zcash': {
      '2016-10': 4300.0, '2016-11': 100.0, '2016-12': 50.0,
      '2017-06': 250.0, '2017-12': 500.0,
      '2018-01': 580.0, '2018-12': 55.0,
      '2019-12': 35.0,
      '2020-12': 70.0,
      '2021-05': 300.0, '2021-12': 150.0,
      '2022-12': 40.0,
      '2024-12': 50.0,
      '2025-01': 52.0,
    },
    'ethereum-classic': {
      '2016-07': 3.0, '2016-12': 1.30,
      '2017-06': 20.0, '2017-12': 35.0,
      '2018-01': 45.0, '2018-12': 5.0,
      '2019-12': 5.0,
      '2020-12': 7.50,
      '2021-05': 130.0, '2021-12': 35.0,
      '2022-12': 17.0,
      '2024-12': 25.0,
      '2025-01': 26.0,
    },
    'cardano': {
      '2017-10': 0.02, '2017-12': 0.70,
      '2018-01': 1.20, '2018-06': 0.15, '2018-12': 0.04,
      '2019-12': 0.035,
      '2020-07': 0.13, '2020-12': 0.17,
      '2021-02': 1.0, '2021-05': 2.0, '2021-09': 3.10, '2021-12': 1.30,
      '2022-12': 0.25,
      '2023-12': 0.60,
      '2024-03': 0.75, '2024-12': 0.90,
      '2025-01': 0.95,
    },
    'solana': {
      '2020-04': 0.75, '2020-12': 1.50,
      '2021-02': 15.0, '2021-05': 45.0, '2021-09': 175.0, '2021-11': 260.0, '2021-12': 170.0,
      '2022-06': 35.0, '2022-11': 13.0, '2022-12': 11.0,
      '2023-10': 30.0, '2023-12': 100.0,
      '2024-03': 175.0, '2024-11': 240.0, '2024-12': 200.0,
      '2025-01': 210.0,
    },
    'polkadot': {
      '2020-08': 3.0, '2020-12': 10.0,
      '2021-02': 40.0, '2021-05': 45.0, '2021-11': 55.0, '2021-12': 27.0,
      '2022-12': 4.50,
      '2023-12': 8.0,
      '2024-12': 7.50,
      '2025-01': 7.80,
    },
    'avalanche-2': {
      '2020-09': 5.0, '2020-12': 4.0,
      '2021-02': 35.0, '2021-09': 65.0, '2021-11': 140.0, '2021-12': 100.0,
      '2022-12': 11.0,
      '2023-12': 42.0,
      '2024-03': 55.0, '2024-12': 42.0,
      '2025-01': 44.0,
    },
    'chainlink': {
      '2017-09': 0.15, '2017-12': 0.5,
      '2018-01': 1.20, '2018-12': 0.30,
      '2019-06': 4.0, '2019-12': 2.0,
      '2020-08': 20.0, '2020-12': 12.0,
      '2021-05': 52.0, '2021-12': 20.0,
      '2022-12': 6.0,
      '2023-12': 15.0,
      '2024-12': 23.0,
      '2025-01': 24.0,
    },
    'ravencoin': {
      '2018-03': 0.04, '2018-06': 0.03, '2018-12': 0.01,
      '2019-12': 0.02,
      '2021-02': 0.15, '2021-12': 0.08,
      '2022-12': 0.015,
      '2024-12': 0.025,
      '2025-01': 0.026,
    },
    'kaspa': {
      '2021-11': 0.0001, '2021-12': 0.0005,
      '2022-06': 0.005, '2022-12': 0.01,
      '2023-02': 0.02, '2023-06': 0.04, '2023-12': 0.12,
      '2024-03': 0.15, '2024-08': 0.18, '2024-12': 0.13,
      '2025-01': 0.14,
    },
    'flux': {
      '2018-09': 0.05, '2018-12': 0.02,
      '2019-12': 0.03,
      '2020-12': 0.08,
      '2021-09': 1.50, '2021-12': 2.30,
      '2022-04': 3.0, '2022-12': 0.40,
      '2023-12': 0.60,
      '2024-12': 0.55,
      '2025-01': 0.57,
    },
    'ergo': {
      '2019-07': 0.50, '2019-12': 0.40,
      '2020-12': 0.50,
      '2021-05': 8.0, '2021-09': 18.0, '2021-12': 8.0,
      '2022-12': 1.50,
      '2023-12': 1.80,
      '2024-12': 1.20,
      '2025-01': 1.25,
    },
    'shiba-inu': {
      '2020-08': 0.0000000001,
      '2021-01': 0.000000001, '2021-05': 0.000035, '2021-10': 0.000085, '2021-12': 0.000033,
      '2022-12': 0.0000085,
      '2023-12': 0.000010,
      '2024-12': 0.000022,
      '2025-01': 0.000023,
    },
    'conflux': {
      '2020-11': 0.10, '2020-12': 0.12,
      '2021-04': 1.00, '2021-12': 0.20,
      '2022-12': 0.02,
      '2023-03': 0.40, '2023-12': 0.20,
      '2024-12': 0.25,
      '2025-01': 0.26,
    },
    'pepe': {
      '2023-04': 0.0000002, '2023-05': 0.000003,
      '2023-12': 0.000001,
      '2024-03': 0.000008, '2024-12': 0.000012,
      '2025-01': 0.000013,
    },
    'uniswap': {
      '2020-09': 3.00, '2020-12': 5.00,
      '2021-05': 40.00, '2021-12': 15.00,
      '2022-12': 5.00,
      '2023-12': 7.00,
      '2024-12': 10.00,
      '2025-01': 11.00,
    },
    'kadena': {
      '2020-06': 0.30, '2020-12': 0.15,
      '2021-04': 1.50, '2021-11': 20.00, '2021-12': 10.00,
      '2022-12': 0.90,
      '2023-12': 1.20,
      '2024-12': 1.50,
      '2025-01': 1.60,
    },
  };
}

/// Market events that impact prices
class MarketEvent {
  final DateTime date;
  final String title;
  final String description;
  final String severity; // 'positive', 'negative', 'neutral'
  final Map<String, double> priceImpact; // e.g. {'bitcoin': -0.30} = -30%
  
  const MarketEvent({
    required this.date,
    required this.title,
    required this.description,
    required this.severity,
    required this.priceImpact,
  });
}

class MarketEvents {
  static final List<MarketEvent> events = [
    // === 2010 ===
    MarketEvent(
      date: DateTime(2010, 5, 22),
      title: '🍕 Bitcoin Pizza Day',
      description: 'Laszlo Hanyecz paid 10,000 BTC for two pizzas - the first real-world Bitcoin transaction! Those pizzas are now worth millions.',
      severity: 'neutral',
      priceImpact: {},
    ),
    // Note: Mt. Gox Launches is handled by Trading feature unlock in game_state_provider.dart
    // to avoid duplicate announcements
    
    // === 2011 ===
    MarketEvent(
      date: DateTime(2011, 2, 9),
      title: '💵 Bitcoin Reaches \$1',
      description: 'Bitcoin reaches parity with the US dollar for the first time!',
      severity: 'positive',
      priceImpact: {'bitcoin': 0.20},
    ),
    MarketEvent(
      date: DateTime(2011, 2, 15),
      title: '🌑 Silk Road Launches',
      description: 'The anonymous marketplace Silk Road opens, driving Bitcoin adoption in underground markets.',
      severity: 'neutral',
      priceImpact: {'bitcoin': 0.15},
    ),
    MarketEvent(
      date: DateTime(2011, 6, 19),
      title: '🔓 Mt. Gox Hack',
      description: 'First major Bitcoin exchange hack. Price crashes from \$30 to \$0.01 briefly.',
      severity: 'negative',
      priceImpact: {'bitcoin': -0.90},
    ),
    // Note: Litecoin Launches handled by coin launch feature unlock
    // Note: Slush Pool Launches handled by pool feature unlock
    
    // === 2012 ===
    MarketEvent(
      date: DateTime(2012, 11, 28),
      title: '⚡ FIRST BITCOIN HALVING',
      description: 'Block reward reduced from 50 BTC to 25 BTC. Only 21 million Bitcoin will ever exist.',
      severity: 'positive',
      priceImpact: {'bitcoin': 0.30},
    ),
    
    // === 2013 ===
    MarketEvent(
      date: DateTime(2013, 10, 2),
      title: '🚔 Silk Road Shutdown',
      description: 'FBI shuts down Silk Road and arrests Ross Ulbricht. 144,000 BTC seized.',
      severity: 'negative',
      priceImpact: {'bitcoin': -0.20},
    ),
    MarketEvent(
      date: DateTime(2013, 11, 29),
      title: '🚀 Bitcoin Breaks \$1,000',
      description: 'Bitcoin reaches \$1,000 for the first time amid massive retail interest.',
      severity: 'positive',
      priceImpact: {'bitcoin': 0.50},
    ),
    // Note: Dogecoin Launches handled by coin launch feature unlock
    
    // === 2014 ===
    MarketEvent(
      date: DateTime(2014, 2, 24),
      title: '💀 Mt. Gox Collapse',
      description: 'Mt. Gox files for bankruptcy after losing 850,000 BTC. The crypto world is shaken.',
      severity: 'negative',
      priceImpact: {'bitcoin': -0.40},
    ),
    // Note: Monero Launches handled by coin launch feature unlock
    
    // === 2015 ===
    // Note: Ethereum Launches handled by coin launch feature unlock
    MarketEvent(
      date: DateTime(2015, 8, 25),
      title: '⚡ LITECOIN HALVING #1',
      description: 'Litecoin block reward reduced from 50 LTC to 25 LTC.',
      severity: 'positive',
      priceImpact: {'litecoin': 0.20},
    ),
    
    // === 2016 ===
    MarketEvent(
      date: DateTime(2016, 7, 9),
      title: '⚡ SECOND BITCOIN HALVING',
      description: 'Block reward reduced from 25 BTC to 12.5 BTC. Supply shock incoming.',
      severity: 'positive',
      priceImpact: {'bitcoin': 0.20},
    ),
    
    // === 2017 ===
    MarketEvent(
      date: DateTime(2017, 12, 17),
      title: '🎉 ICO Bubble Peak',
      description: 'Bitcoin reaches \$19,783. Ethereum at \$1,300. ICO mania at peak.',
      severity: 'positive',
      priceImpact: {'bitcoin': 0.30, 'ethereum': 0.40},
    ),
    
    // === 2018 ===
    MarketEvent(
      date: DateTime(2018, 1, 16),
      title: '❄️ Crypto Winter Begins',
      description: 'Market crashes 80% over the next year. ICO bubble bursts.',
      severity: 'negative',
      priceImpact: {'bitcoin': -0.50, 'ethereum': -0.60},
    ),
    
    // === 2019 ===
    MarketEvent(
      date: DateTime(2019, 8, 5),
      title: '⚡ LITECOIN HALVING #2',
      description: 'Litecoin block reward reduced from 25 LTC to 12.5 LTC.',
      severity: 'positive',
      priceImpact: {'litecoin': 0.15},
    ),
    
    // === 2020 ===
    MarketEvent(
      date: DateTime(2020, 3, 12),
      title: '📉 COVID Black Thursday',
      description: 'Global panic crashes all markets. Bitcoin drops 50% in one day.',
      severity: 'negative',
      priceImpact: {'bitcoin': -0.50, 'ethereum': -0.50},
    ),
    MarketEvent(
      date: DateTime(2020, 5, 11),
      title: '⚡ THIRD BITCOIN HALVING',
      description: 'Block reward reduced from 12.5 BTC to 6.25 BTC. Institutional buying begins.',
      severity: 'positive',
      priceImpact: {'bitcoin': 0.25},
    ),
    
    // === 2021 ===
    MarketEvent(
      date: DateTime(2021, 4, 14),
      title: '📊 Coinbase IPO',
      description: 'Coinbase goes public. Bitcoin hits \$64,000. Crypto goes mainstream.',
      severity: 'positive',
      priceImpact: {'bitcoin': 0.20, 'ethereum': 0.25},
    ),
    MarketEvent(
      date: DateTime(2021, 5, 19),
      title: '🇨🇳 China Mining Ban',
      description: 'China bans crypto mining. Hash rate drops 50%. Prices crash.',
      severity: 'negative',
      priceImpact: {'bitcoin': -0.35},
    ),
    MarketEvent(
      date: DateTime(2021, 11, 10),
      title: '🏆 Bitcoin ATH \$69K',
      description: 'Bitcoin reaches all-time high of \$69,000.',
      severity: 'positive',
      priceImpact: {'bitcoin': 0.15},
    ),
    
    // === 2022 ===
    MarketEvent(
      date: DateTime(2022, 5, 12),
      title: '🌙 LUNA/UST Collapse',
      description: 'Terra ecosystem collapses. \$40B wiped out. Contagion spreads.',
      severity: 'negative',
      priceImpact: {'bitcoin': -0.30, 'ethereum': -0.35},
    ),
    MarketEvent(
      date: DateTime(2022, 9, 15),
      title: '🔀 Ethereum Merge',
      description: 'Ethereum transitions from Proof of Work to Proof of Stake. Mining ends.',
      severity: 'neutral',
      priceImpact: {'ethereum': 0.10},
    ),
    MarketEvent(
      date: DateTime(2022, 11, 11),
      title: '💥 FTX Collapse',
      description: 'FTX files for bankruptcy. Industry-wide contagion.',
      severity: 'negative',
      priceImpact: {'bitcoin': -0.25, 'ethereum': -0.25},
    ),
    
    // === 2023 ===
    MarketEvent(
      date: DateTime(2023, 8, 2),
      title: '⚡ LITECOIN HALVING #3',
      description: 'Litecoin block reward reduced from 12.5 LTC to 6.25 LTC.',
      severity: 'positive',
      priceImpact: {'litecoin': 0.10},
    ),
    
    // === 2024 ===
    MarketEvent(
      date: DateTime(2024, 1, 10),
      title: '🎯 Bitcoin ETF Approved',
      description: 'SEC approves spot Bitcoin ETFs. Institutional flood begins.',
      severity: 'positive',
      priceImpact: {'bitcoin': 0.40},
    ),
    MarketEvent(
      date: DateTime(2024, 4, 19),
      title: '⚡ FOURTH BITCOIN HALVING',
      description: 'Block reward reduced from 6.25 BTC to 3.125 BTC.',
      severity: 'positive',
      priceImpact: {'bitcoin': 0.20},
    ),
  ];
  
  /// Get events within a date range (inclusive of same-day)
  static List<MarketEvent> getEventsInRange(DateTime start, DateTime end) {
    return events.where((e) {
      // Check if event date is >= start AND <= end (inclusive)
      final eventDate = DateTime(e.date.year, e.date.month, e.date.day);
      final startDate = DateTime(start.year, start.month, start.day);
      final endDate = DateTime(end.year, end.month, end.day);
      return (eventDate.isAfter(startDate) || eventDate.isAtSameMomentAs(startDate)) &&
             (eventDate.isBefore(endDate) || eventDate.isAtSameMomentAs(endDate));
    }).toList();
  }
  
  /// Get the next upcoming event from a date
  static MarketEvent? getNextEvent(DateTime from) {
    final upcoming = events.where((e) => e.date.isAfter(from)).toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming.first;
  }
}
