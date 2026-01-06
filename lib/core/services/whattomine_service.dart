import 'dart:convert';
import 'package:http/http.dart' as http;

/// WhatToMine.com API integration for real mining profitability data
class WhatToMineService {
  static const String baseUrl = 'https://whattomine.com/coins';
  
  /// Fetch ALL mineable coins from WhatToMine (returns top 50+)
  static Future<Map<String, MiningProfitabilityData>> fetchMiningData() async {
    try {
      // WhatToMine coins.json endpoint - FREE, no API key needed!
      final url = Uri.parse('$baseUrl.json');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coins = data['coins'] as Map<String, dynamic>;
        
        final Map<String, MiningProfitabilityData> miningData = {};
        
        // Process ALL coins from WhatToMine
        coins.forEach((coinName, value) {
          try {
            final coinData = value as Map<String, dynamic>;
            
            // Extract coin info with safe parsing
            final tag = (coinData['tag'] as String?)?.toUpperCase() ?? '';
            final algorithm = coinData['algorithm'] as String? ?? 'Unknown';
            
            // Parse numbers safely - WhatToMine sometimes returns strings like "N/A"
            final blockReward = _parseDouble(coinData['block_reward']) ?? 0.0;
            final blockTime = _parseDouble(coinData['block_time']) ?? 60.0;
            final networkHashrate = _parseDouble(coinData['nethash']) ?? 0.0;
            final exchangeRate = _parseDouble(coinData['exchange_rate']) ?? 0.0;
            final estimatedRewards = _parseDouble(coinData['estimated_rewards']) ?? 0.0;
            
            // Skip coins with no price data or no network hashrate
            if (exchangeRate <= 0 || networkHashrate <= 0) return;
            
            // Generate coin ID from name or tag
            final coinId = _generateCoinId(coinName, tag);
            
            // Debug output for specific coins
            if (tag == 'ZEC' || tag == 'XMR' || tag == 'BTC' || tag == 'RVN') {
              print('📊 WhatToMine data for $tag:');
              print('   Network Hash: $networkHashrate');
              print('   Algorithm: $algorithm');
              print('   Block Reward: $blockReward');
              print('   Block Time: $blockTime');
              print('   Exchange Rate: \$$exchangeRate');
            }
            
            miningData[coinId] = MiningProfitabilityData(
              coinId: coinId,
              name: coinName,
              symbol: tag,
              algorithm: algorithm,
              blockReward: blockReward,
              blockTime: blockTime,
              networkHashrate: networkHashrate,
              coinPrice: exchangeRate,
              estimatedRewards24h: estimatedRewards,
              isMineable: true,
            );
          } catch (e) {
            print('Error parsing coin $coinName: $e');
          }
        });
        
        print('✅ Fetched ${miningData.length} mineable coins from WhatToMine');
        return miningData;
      }
    } catch (e) {
      print('Error fetching WhatToMine data: $e');
    }
    
    return {};
  }
  
  /// Generate a unique coin ID from name and tag
  static String _generateCoinId(String name, String tag) {
    // First check if we have a known mapping
    final knownId = _mapCoinTag(tag);
    if (knownId != null) return knownId;
    
    // Otherwise, create ID from name (lowercase, hyphenated)
    return name.toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
  
  /// Map common WhatToMine tags to standard coin IDs
  static String? _mapCoinTag(String tag) {
    final mapping = {
      'BTC': 'bitcoin',
      'ETH': 'ethereum',
      'ETC': 'ethereum-classic',
      'LTC': 'litecoin',
      'DOGE': 'dogecoin',
      'XMR': 'monero',
      'ZEC': 'zcash',
      'BCH': 'bitcoin-cash',
      'RVN': 'ravencoin',
      'ERG': 'ergo',
      'FLUX': 'flux',
      'CFX': 'conflux',
      'KAS': 'kaspa',
      'NEXA': 'nexa',
      'ALPH': 'alephium',
      'DASH': 'dash',
      'BTG': 'bitcoin-gold',
      'XVG': 'verge',
      'VTC': 'vertcoin',
      'BEAM': 'beam',
      'FIRO': 'firo',
      'CLORE': 'clore-ai',
      'KDA': 'kadena',
      'ZANO': 'zano',
      'XNA': 'neurai',
    };
    
    return mapping[tag.toUpperCase()];
  }
  
  /// Safely parse a value to double, handling strings and nulls
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    
    // If already a number
    if (value is num) {
      return value.toDouble();
    }
    
    // If it's a string, try to parse
    if (value is String) {
      // Handle "N/A", "-", or empty strings
      if (value.isEmpty || value == 'N/A' || value == '-' || value == 'null') {
        return null;
      }
      
      // Try parsing
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }
}

/// Mining profitability data from WhatToMine
class MiningProfitabilityData {
  final String coinId;
  final String name;
  final String symbol;
  final String algorithm;
  final double blockReward;
  final double blockTime;
  final double networkHashrate;
  final double coinPrice;
  final double estimatedRewards24h; // Coins earned per day with reference hashrate
  final bool isMineable;
  
  const MiningProfitabilityData({
    required this.coinId,
    required this.name,
    required this.symbol,
    required this.algorithm,
    required this.blockReward,
    required this.blockTime,
    required this.networkHashrate,
    required this.coinPrice,
    required this.estimatedRewards24h,
    required this.isMineable,
  });
  
  /// Calculate realistic daily earnings for given hashrate in MH/s
  /// Returns coins per day based on proper algorithm-specific unit conversion
  double calculateDailyEarnings(double hashRateMHs) {
    if (!isMineable || networkHashrate == 0 || blockTime == 0) return 0.0;
    
    // Convert your hashrate (always in MH/s) to the network's unit
    final yourHashRateInNetworkUnits = _convertHashRateToNetworkUnits(hashRateMHs);
    
    // Your share of network (will be microscopic!)
    final yourShare = yourHashRateInNetworkUnits / networkHashrate;
    
    // Blocks per day
    final blocksPerDay = 86400 / blockTime;
    
    // Expected coins per day based on your share
    final coinsPerDay = blocksPerDay * blockReward * yourShare;
    
    return coinsPerDay;
  }
  
  /// Convert hashrate from MH/s to network-specific units based on algorithm
  double _convertHashRateToNetworkUnits(double hashRateMHs) {
    final algo = algorithm.toLowerCase();
    
    // SHA-256 (Bitcoin, BCH): WhatToMine reports in TH/s
    if (algo.contains('sha') || algo.contains('bitcoin')) {
      return hashRateMHs / 1e6; // MH/s to TH/s
    }
    
    // Scrypt (Litecoin, Dogecoin): WhatToMine reports in MH/s
    if (algo.contains('scrypt')) {
      return hashRateMHs; // Already in MH/s
    }
    
    // Ethash (ETC): WhatToMine reports in GH/s
    if (algo.contains('ethash')) {
      return hashRateMHs / 1000; // MH/s to GH/s
    }
    
    // KAWPOW (Ravencoin, Neurai, Clore): WhatToMine reports in GH/s
    // Network is typically 5-10 TH/s = 5000-10000 GH/s
    if (algo.contains('kawpow')) {
      return hashRateMHs / 1000; // MH/s to GH/s
    }
    
    // RandomX (Monero): WhatToMine reports in MH/s
    // Network is typically 2-3 GH/s = 2000-3000 MH/s
    if (algo.contains('randomx')) {
      return hashRateMHs; // Already in MH/s (NOT KH/s!)
    }
    
    // Equihash (Zcash, BTG): WhatToMine reports in Sol/s
    if (algo.contains('equihash')) {
      return hashRateMHs * 1e6; // MH/s to Sol/s (treat as H/s scale)
    }
    
    // Autolykos (Ergo): WhatToMine reports in GH/s
    if (algo.contains('autolykos')) {
      return hashRateMHs / 1000; // MH/s to GH/s
    }
    
    // kHeavyHash (Kaspa): WhatToMine reports in PH/s
    if (algo.contains('kheavyhash') || algo.contains('heavyhash')) {
      return hashRateMHs / 1e9; // MH/s to PH/s
    }
    
    // Blake3 (Alephium): WhatToMine reports in GH/s
    if (algo.contains('blake3')) {
      return hashRateMHs / 1000; // MH/s to GH/s
    }
    
    // Blake2S (Kadena): WhatToMine reports in TH/s
    if (algo.contains('blake2s')) {
      return hashRateMHs / 1e6; // MH/s to TH/s
    }
    
    // Octopus (Conflux): WhatToMine reports in GH/s
    if (algo.contains('octopus')) {
      return hashRateMHs / 1000; // MH/s to GH/s
    }
    
    // ZelHash (Flux): WhatToMine reports in Sol/s
    if (algo.contains('zelhash') || algo.contains('zelcash')) {
      return hashRateMHs * 1e6; // MH/s to Sol/s
    }
    
    // X11 (Dash): WhatToMine reports in GH/s
    if (algo.contains('x11') || algo.contains('dash')) {
      return hashRateMHs / 1000; // MH/s to GH/s
    }
    
    // Verthash (Vertcoin): WhatToMine reports in MH/s
    if (algo.contains('verthash')) {
      return hashRateMHs; // Already in MH/s
    }
    
    // FiroPow/ProgPow (Firo): WhatToMine reports in GH/s
    if (algo.contains('firopow') || algo.contains('progpow')) {
      return hashRateMHs / 1000; // MH/s to GH/s
    }
    
    // NeoScrypt: WhatToMine reports in MH/s
    if (algo.contains('neoscrypt')) {
      return hashRateMHs; // Already in MH/s
    }
    
    // NexaPow (Nexa): WhatToMine reports in GH/s
    if (algo.contains('nexapow')) {
      return hashRateMHs / 1000; // MH/s to GH/s
    }
    
    // BeamHash (Beam): WhatToMine reports in Sol/s
    if (algo.contains('beamhash') || algo.contains('beam')) {
      return hashRateMHs * 1e6; // MH/s to Sol/s
    }
    
    // Cuckoo Cycle (Aeternity, Grin): WhatToMine reports in H/s
    if (algo.contains('cuckaroo') || algo.contains('cuckoo')) {
      return hashRateMHs * 1e6; // MH/s to H/s
    }
    
    // GhostRider (Raptoreum): WhatToMine reports in MH/s
    if (algo.contains('ghostrider')) {
      return hashRateMHs; // Already in MH/s
    }
    
    // Default: assume network in GH/s (most common)
    return hashRateMHs / 1000; // MH/s to GH/s
  }
  
  /// Calculate daily revenue in USD
  double calculateDailyRevenue(double hashRateMHs) {
    return calculateDailyEarnings(hashRateMHs) * coinPrice;
  }
  
  /// Calculate coins per second for real-time mining (for game loop)
  double calculateCoinsPerSecond(double hashRateMHs) {
    final coinsPerDay = calculateDailyEarnings(hashRateMHs);
    return coinsPerDay / 86400; // Convert to per-second
  }
  
  /// Calculate profitability after power costs
  double calculateDailyProfit(double hashRateMHs, double powerWatts, double electricityRate) {
    final revenue = calculateDailyRevenue(hashRateMHs);
    final powerCost = (powerWatts / 1000) * 24 * electricityRate;
    return revenue - powerCost;
  }
}
