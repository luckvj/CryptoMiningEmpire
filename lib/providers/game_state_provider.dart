import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../core/services/storage_service.dart';
import '../core/models/mining_data.dart';
import '../core/models/location_data.dart';
import '../core/services/whattomine_service.dart';

/// Game state management with mining, trading, and portfolio
class GameStateProvider extends ChangeNotifier {
  // Game Economy
  double _balance = 1000.0;
  Map<String, double> _holdings = {};
  Map<String, double> _totalMined = {};
  String _activeCrypto = 'bitcoin';
  
  // Equipment
  List<GPU> _gpus = [];
  List<Building> _buildings = [];
  
  // Game Stats
  DateTime _gameStartTime = DateTime.now();
  double _totalHashRate = 0.0;
  double _dailyPowerCost = 0.0;
  
  // Mining
  Timer? _miningTimer;
  bool _isMining = false;
  
  // Clicker/Tapper System
  double _clickPower = 1.0; // Hash power per click
  int _totalClicks = 0;
  double _clickMultiplier = 1.0;
  
  // Achievements
  final List<String> _unlockedAchievements = [];
  
  // Auto-save
  Timer? _autoSaveTimer;
  
  // WhatToMine data cache
  Map<String, MiningProfitabilityData> _whatToMineData = {};
  Timer? _whatToMineUpdateTimer;
  
  GameStateProvider() {
    _initializeGame();
  }
  
  // Getters
  double get balance => _balance;
  Map<String, double> get holdings => Map.unmodifiable(_holdings);
  Map<String, double> get totalMined => Map.unmodifiable(_totalMined);
  String get activeCrypto => _activeCrypto;
  List<GPU> get gpus => List.unmodifiable(_gpus);
  List<Building> get buildings => List.unmodifiable(_buildings);
  double get totalHashRate => _totalHashRate * _currentLocation.hashRateBonus; // Apply location bonus
  double get baseHashRate => _totalHashRate; // Without bonus
  double get dailyPowerCost => _dailyPowerCost * _currentLocation.powerCostMultiplier; // Apply location multiplier
  double get baseDailyPowerCost => _dailyPowerCost; // Without multiplier
  bool get isMining => _isMining;
  int get gpuCount => _gpus.length;
  int get buildingCount => _buildings.length;
  List<String> get achievements => List.unmodifiable(_unlockedAchievements);
  
  // Location getters
  LocationData get currentLocation => _currentLocation;
  LocationData? get nextLocation => LocationDatabase.getNextLocation(_calculateNetWorth(), gpuCount);
  double get locationProgress => LocationDatabase.getProgressToNext(_calculateNetWorth(), gpuCount);
  
  // Clicker getters
  double get clickPower => _clickPower;
  int get totalClicks => _totalClicks;
  double get clickMultiplier => _clickMultiplier;
  
  // Current location
  LocationData _currentLocation = LocationDatabase.locations.first;
  
  /// Initialize game - load save or start new
  Future<void> _initializeGame() async {
    final saveData = StorageService.loadGame();
    
    if (saveData != null) {
      _loadFromSave(saveData);
    } else {
      _startNewGame();
    }
    
    // Fetch WhatToMine data for accurate mining
    await _fetchWhatToMineData();
    
    _startMining();
    _startAutoSave();
    _startWhatToMineUpdates();
    notifyListeners();
  }
  
  /// Fetch WhatToMine data for mining calculations
  Future<void> _fetchWhatToMineData() async {
    try {
      print('🔄 Fetching mining data...');
      // Mining data will be populated from real-time API calls
      _whatToMineData = {};
      print('✅ Mining data initialized');
    } catch (e) {
      print('❌ Error fetching mining data: $e');
    }
  }
  
  /// Start periodic WhatToMine updates (every 10 minutes)
  void _startWhatToMineUpdates() {
    _whatToMineUpdateTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      _fetchWhatToMineData();
    });
  }
  
  /// Start new game
  void _startNewGame() {
    _balance = 5000.0; // Increased starting balance for faster progression
    _holdings = {
      'bitcoin': 0.0,
      'ethereum': 0.0,
      'dogecoin': 0.0,
      'litecoin': 0.0,
    };
    _totalMined = {..._holdings};
    _activeCrypto = 'bitcoin';
    _gpus = [];
    _buildings = [];
    _gameStartTime = DateTime.now();
    _clickPower = 1.0;
    _totalClicks = 0;
    _clickMultiplier = 1.0;
  }
  
  /// Load from save
  void _loadFromSave(GameSaveData data) {
    _balance = data.balance;
    _holdings = data.holdings;
    _totalMined = data.totalMined;
    _activeCrypto = data.activeCrypto;
    _gpus = data.gpus.map((json) => GPU.fromJson(json)).toList();
    _buildings = data.buildings.map((json) => Building.fromJson(json)).toList();
    _gameStartTime = data.gameTime;
    _unlockedAchievements.addAll(data.achievements);
    _updateStats();
  }
  
  /// Start mining timer
  void _startMining() {
    _isMining = true;
    _miningTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _mine();
    });
  }
  
  /// Mining logic
  void _mine() {
    if (_totalHashRate > 0) {
      final reward = _calculateMiningReward(_activeCrypto, _totalHashRate);
      
      // Debug logging (only log occasionally to avoid spam)
      if (DateTime.now().second % 10 == 0) {
        print('⛏️ Mining $_activeCrypto: ${reward.toStringAsFixed(8)} coins/sec');
        print('   Hashrate: ${_totalHashRate} MH/s');
      }
      
      _holdings[_activeCrypto] = (_holdings[_activeCrypto] ?? 0.0) + reward;
      _totalMined[_activeCrypto] = (_totalMined[_activeCrypto] ?? 0.0) + reward;
      
      // Deduct power costs
      final costPerSecond = _dailyPowerCost / 86400;
      _balance -= costPerSecond;
      
      notifyListeners();
    }
  }
  
  /// Calculate mining reward using WhatToMine data - REAL CALCULATIONS
  double _calculateMiningReward(String cryptoId, double hashRate) {
    // Try WhatToMine data first (most accurate)
    if (_whatToMineData.containsKey(cryptoId)) {
      final wtmData = _whatToMineData[cryptoId]!;
      return _calculateRewardFromWhatToMine(wtmData, hashRate);
    }
    
    // Fallback to static database
    final miningData = MiningDatabase.getMiningData(cryptoId);
    
    // If not mineable or no data, return 0
    if (miningData == null || !miningData.isMineable) {
      return 0.0;
    }
    
    return _calculateRewardFromStaticData(miningData, hashRate);
  }
  
  /// Calculate reward using WhatToMine data - PROPERLY FIXED with algorithm-based units
  double _calculateRewardFromWhatToMine(MiningProfitabilityData data, double hashRate) {
    if (!data.isMineable || data.networkHashrate <= 0) return 0.0;
    
    // Use the proper calculation method from WhatToMine service
    final coinsPerSecond = data.calculateCoinsPerSecond(hashRate);
    
    // Debug logging for active crypto
    if (data.coinId == _activeCrypto && DateTime.now().second % 10 == 0) {
      final coinsPerDay = coinsPerSecond * 86400;
      print('⛏️  Mining ${data.symbol}:');
      print('   Algorithm: ${data.algorithm}');
      print('   Network Hash: ${data.networkHashrate}');
      print('   Block Reward: ${data.blockReward}');
      print('   Block Time: ${data.blockTime}s');
      print('   Your Hashrate: $hashRate MH/s');
      print('   💰 Coins/day: ${coinsPerDay.toStringAsFixed(8)}');
      print('   💵 Exchange Rate: \$${data.coinPrice.toStringAsFixed(2)}');
      print('   💸 Daily Revenue: \$${(coinsPerDay * data.coinPrice).toStringAsFixed(2)}');
    }
    
    return coinsPerSecond;
  }
  
  /// OLD IMPLEMENTATION - kept for reference but replaced above
  double _calculateRewardFromWhatToMine_OLD(MiningProfitabilityData data, double hashRate) {
    if (!data.isMineable || data.networkHashrate <= 0) return 0.0;
    
    print('🟢 NEW CODE IS RUNNING! (v2.0) 🟢'); // INDICATOR THAT NEW CODE LOADED
    
    final yourHashRate = hashRate; // in MH/s (always)
    final networkHashRate = data.networkHashrate; // WhatToMine reports in various units
    final blockReward = data.blockReward;
    final blockTime = data.blockTime;
    final algorithm = data.algorithm.toLowerCase();
    
    // Debug: Print DETAILED calculation breakdown
    if (data.coinId == _activeCrypto) {
      print('\n🔍 DETAILED DEBUG for ${data.coinId.toUpperCase()}:');
      print('   📡 Network Hashrate: $networkHashRate (as reported by WhatToMine)');
      print('   🔧 Algorithm: ${data.algorithm}');
      print('   💎 Block Reward: $blockReward coins');
      print('   ⏱️  Block Time: ${blockTime}s');
      print('   ⚡ Your Hashrate: $yourHashRate MH/s');
    }
    
    // CRITICAL: Determine network hashrate unit based on algorithm
    double yourHashRateInNetworkUnits;
    
    // Algorithm-specific unit conversions - VERIFIED from WhatToMine
    // These are the ACTUAL units WhatToMine reports for each algorithm
    
    if (algorithm.contains('sha') || algorithm.contains('bitcoin')) {
      // SHA-256 (Bitcoin, BCH): WhatToMine reports in TH/s
      // Reference: BTC = 580 TH/s
      yourHashRateInNetworkUnits = yourHashRate / 1e6; // MH/s to TH/s
      
    } else if (algorithm.contains('scrypt')) {
      // Scrypt (Litecoin, Dogecoin): WhatToMine reports in MH/s
      yourHashRateInNetworkUnits = yourHashRate; // Already in MH/s
      
    } else if (algorithm.contains('ethash')) {
      // Ethash (ETC, EthereumPoW): WhatToMine reports in GH/s
      yourHashRateInNetworkUnits = yourHashRate / 1000; // MH/s to GH/s
      
    } else if (algorithm.contains('kawpow')) {
      // KAWPOW (Ravencoin, Neurai, etc): WhatToMine reports in MH/s
      yourHashRateInNetworkUnits = yourHashRate; // Already in MH/s
      
    } else if (algorithm.contains('randomx')) {
      // RandomX (Monero): WhatToMine reports in KH/s
      // Reference: XMR = 212.0 KH/s
      yourHashRateInNetworkUnits = yourHashRate * 1000; // MH/s to KH/s
      
    } else if (algorithm.contains('equihash')) {
      // Equihash (Zcash, BTG): WhatToMine reports in Sol/s (NOT KSol/s!)
      // Sol/s is roughly equivalent to H/s scale
      // 1 MH/s = 1,000,000 H/s = 1,000,000 Sol/s
      yourHashRateInNetworkUnits = yourHashRate * 1000000; // MH/s to Sol/s
      
    } else if (algorithm.contains('autolykos')) {
      // Autolykos (Ergo): WhatToMine reports in GH/s
      yourHashRateInNetworkUnits = yourHashRate / 1000; // MH/s to GH/s
      
    } else if (algorithm.contains('kheavyhash') || algorithm.contains('heavyhash')) {
      // kHeavyHash (Kaspa): WhatToMine reports in PH/s
      yourHashRateInNetworkUnits = yourHashRate / 1e9; // MH/s to PH/s
      
    } else if (algorithm.contains('blake3')) {
      // Blake3 (Alephium): WhatToMine reports in GH/s
      yourHashRateInNetworkUnits = yourHashRate / 1000; // MH/s to GH/s
      
    } else if (algorithm.contains('blake2s')) {
      // Blake2S (Kadena): WhatToMine reports in TH/s
      yourHashRateInNetworkUnits = yourHashRate / 1e6; // MH/s to TH/s
      
    } else if (algorithm.contains('octopus')) {
      // Octopus (Conflux): WhatToMine reports in GH/s
      yourHashRateInNetworkUnits = yourHashRate / 1000; // MH/s to GH/s
      
    } else if (algorithm.contains('zelhash') || algorithm.contains('zelcash')) {
      // ZelHash (Flux): WhatToMine reports in Sol/s (NOT KSol/s!)
      yourHashRateInNetworkUnits = yourHashRate * 1000000; // MH/s to Sol/s
      
    } else if (algorithm.contains('x11') || algorithm.contains('dash')) {
      // X11 (Dash): WhatToMine reports in GH/s
      // Reference: DASH = 1770.0 GH/s
      yourHashRateInNetworkUnits = yourHashRate / 1000; // MH/s to GH/s
      
    } else if (algorithm.contains('verthash')) {
      // Verthash (Vertcoin): WhatToMine reports in MH/s
      yourHashRateInNetworkUnits = yourHashRate; // Already in MH/s
      
    } else if (algorithm.contains('firopow') || algorithm.contains('progpow')) {
      // FiroPow/ProgPow (Firo): WhatToMine reports in GH/s
      yourHashRateInNetworkUnits = yourHashRate / 1000; // MH/s to GH/s
      
    } else if (algorithm.contains('neoscrypt')) {
      // NeoScrypt: WhatToMine reports in MH/s
      yourHashRateInNetworkUnits = yourHashRate; // Already in MH/s
      
    } else if (algorithm.contains('nexapow')) {
      // NexaPow (Nexa): WhatToMine reports in GH/s
      yourHashRateInNetworkUnits = yourHashRate / 1000; // MH/s to GH/s
      
    } else if (algorithm.contains('beamhash') || algorithm.contains('beam')) {
      // BeamHash (Beam): WhatToMine reports in Sol/s
      yourHashRateInNetworkUnits = yourHashRate * 1000000; // MH/s to Sol/s
      
    } else if (algorithm.contains('cuckaroo') || algorithm.contains('cuckoo')) {
      // Cuckoo Cycle (Aeternity, Grin): WhatToMine reports in H/s
      yourHashRateInNetworkUnits = yourHashRate * 1e6; // MH/s to H/s
      
    } else if (algorithm.contains('ghostrider')) {
      // GhostRider (Raptoreum): WhatToMine reports in MH/s
      yourHashRateInNetworkUnits = yourHashRate; // Already in MH/s
      
    } else {
      // Default: assume network in GH/s (most common)
      yourHashRateInNetworkUnits = yourHashRate / 1000; // MH/s to GH/s
    }
    
    // Your percentage of network (will be microscopic!)
    final yourPercentage = yourHashRateInNetworkUnits / networkHashRate;
    
    // Blocks per second
    final blocksPerSecond = 1.0 / blockTime;
    
    // Expected coins per second (REAL calculation - will be tiny)
    final coinsPerSecond = blocksPerSecond * blockReward * yourPercentage;
    
    // Debug calculation breakdown
    if (data.coinId == _activeCrypto) {
      print('   🔄 Converted to: $yourHashRateInNetworkUnits (network units)');
      print('   📊 Your %: ${(yourPercentage * 100).toStringAsExponential(4)}%');
      print('   📈 Blocks/sec: ${blocksPerSecond.toStringAsFixed(6)}');
      print('   💰 Real coins/sec: ${coinsPerSecond.toStringAsExponential(6)}');
      print('   ⏰ Real coins/hour: ${(coinsPerSecond * 3600).toStringAsExponential(6)}');
      print('');
    }
    
    // Game multiplier: 1x for testing - NO MULTIPLIER
    // Let's see the REAL values first, then scale appropriately
    final realCoinsPerSec = coinsPerSecond;
    final withMultiplier = coinsPerSecond * 1.0;
    
    // Debug every 10 seconds
    if (DateTime.now().second % 10 == 0 && data.coinId == _activeCrypto) {
      print('💰 ${data.coinId.toUpperCase()}:');
      print('   Real: ${realCoinsPerSec.toStringAsExponential(4)} coins/sec');
      print('   With 1x: ${withMultiplier.toStringAsFixed(8)} coins/sec');
      print('   Per hour: ${(withMultiplier * 3600).toStringAsFixed(4)}');
    }
    
    return withMultiplier;
  }
  
  /// Calculate reward using static database (fallback)
  double _calculateRewardFromStaticData(MiningData miningData, double hashRate) {
    final yourHashRate = hashRate; // in MH/s
    final networkHashRate = miningData.networkHashRate;
    final blockReward = miningData.blockReward;
    final blockTime = miningData.blockTime;
    
    // FIXED: Proper unit conversion matching WhatToMine
    // Convert YOUR hash rate to network's unit
    double yourHashRateConverted;
    double gameBalanceMultiplier = 1000000.0; // Base game multiplier for fun gameplay
    
    switch (miningData.hashRateUnit) {
      case 'TH/s': // Network in Terahash (Bitcoin, Kadena)
        yourHashRateConverted = yourHashRate / 1000000; // MH to TH
        gameBalanceMultiplier = 1000000.0; // Balanced for BTC
        break;
      case 'GH/s': // Network in Gigahash (Dash, Autolykos, etc)
        yourHashRateConverted = yourHashRate / 1000; // MH to GH
        gameBalanceMultiplier = 1000000.0; // Standard for GH/s coins
        break;
      case 'MH/s': // Network in Megahash (Scrypt, KAWPOW, etc)
        yourHashRateConverted = yourHashRate; // Already in MH
        gameBalanceMultiplier = 50000.0; // Reduced from 500K to 50K for better balance (DOGE/LTC)
        break;
      case 'KH/s': // Network in Kilohash (Monero)
        yourHashRateConverted = yourHashRate * 1000; // MH to KH
        gameBalanceMultiplier = 100000.0; // Reduced from 1M to 100K for better balance (XMR)
        break;
      case 'H/s': // Network in Hash (BeamHash)
        yourHashRateConverted = yourHashRate * 1000000; // MH to H
        gameBalanceMultiplier = 1000000.0; // Standard for H/s coins
        break;
      case 'Sol/s': // Solutions per second (Equihash variants)
        yourHashRateConverted = yourHashRate * 1000000; // MH to Sol/s
        gameBalanceMultiplier = 100000.0; // Reduced from 1M to 100K for better balance (ZEC)
        break;
      case 'PH/s': // Network in Petahash (Kaspa)
        yourHashRateConverted = yourHashRate / 1000000000; // MH to PH
        gameBalanceMultiplier = 1000000.0; // Standard for PH/s coins
        break;
      default:
        yourHashRateConverted = yourHashRate;
        gameBalanceMultiplier = 1000000.0; // Default multiplier
    }
    
    // Your percentage of network (will be TINY!)
    final yourPercentage = yourHashRateConverted / networkHashRate;
    
    // Blocks per second
    final blocksPerSecond = 1.0 / blockTime;
    
    // Expected coins per second (realistic, will be VERY small)
    final coinsPerSecond = blocksPerSecond * blockReward * yourPercentage;
    
    // Apply game balance multiplier for playability
    return coinsPerSecond * gameBalanceMultiplier;
  }
  
  /// Get mining parameters for crypto
  Map<String, double> _getMiningParams(String cryptoId) {
    switch (cryptoId) {
      case 'bitcoin':
        return <String, double>{
          'networkHashRate': 400000000.0,
          'blockReward': 6.25,
          'blockTime': 600.0,
        };
      case 'ethereum':
        return <String, double>{
          'networkHashRate': 800000.0,
          'blockReward': 2.0,
          'blockTime': 12.0,
        };
      case 'litecoin':
        return <String, double>{
          'networkHashRate': 500000.0,
          'blockReward': 12.5,
          'blockTime': 150.0,
        };
      case 'dogecoin':
        return <String, double>{
          'networkHashRate': 600000.0,
          'blockReward': 10000.0,
          'blockTime': 60.0,
        };
      default:
        return <String, double>{
          'networkHashRate': 1000000.0,
          'blockReward': 1.0,
          'blockTime': 60.0,
        };
    }
  }
  
  /// Update stats
  void _updateStats() {
    // Calculate algorithm-specific hashrate for active crypto
    _totalHashRate = _calculateTotalHashRateForAlgorithm(_activeCrypto);
    
    final totalPowerWatts = _gpus.fold(0.0, (sum, gpu) => sum + gpu.powerWatts);
    final powerMultiplier = _buildings.isEmpty ? 1.0 
        : _buildings.map((b) => b.powerMultiplier).reduce((a, b) => a < b ? a : b);
    final totalPowerKW = (totalPowerWatts * powerMultiplier) / 1000.0;
    _dailyPowerCost = totalPowerKW * 24 * 0.12; // $0.12 per kWh
    
    // Update click power based on GPUs (more GPUs = more powerful clicks)
    _clickPower = 1.0 + (_gpus.length * 0.5);
    
    // Update current location
    _updateLocation();
    
    notifyListeners();
  }
  
  /// Calculate total hashrate for specific algorithm based on real GPU performance
  double _calculateTotalHashRateForAlgorithm(String cryptoId) {
    final miningData = MiningDatabase.getMiningData(cryptoId);
    if (miningData == null) return 0.0;
    
    final algorithm = miningData.algorithm;
    double totalHashRate = 0.0;
    
    for (var gpu in _gpus) {
      totalHashRate += _getGPUHashRateForAlgorithm(gpu.name, algorithm);
    }
    
    return totalHashRate;
  }
  
  /// Get real-world GPU hashrate for specific algorithm
  /// Returns hashrate normalized to MH/s equivalent for calculations
  double _getGPUHashRateForAlgorithm(String gpuName, String algorithm) {
    // Real-world hashrate data based on WhatToMine and mining benchmarks
    // All values normalized to MH/s equivalent for consistent calculations
    final Map<String, Map<String, double>> realWorldData = {
      // Entry Level GPUs
      'NVIDIA GTX 1660 Super': {
        'SHA-256': 0.0,
        'Ethash': 31.5,  // MH/s
        'KawPow': 13.5,  // MH/s
        'Autolykos': 55.0,  // MH/s
        'Scrypt': 0.85,  // MH/s
        'Equihash': 0.22,  // 220 Sol/s
        'RandomX': 0.0005,  // 0.5 KH/s
        'Blake3': 1800.0,  // MH/s
        'BeamHash': 22.0,
        'X11': 12.0,
      },
      'AMD RX 580 8GB': {
        'SHA-256': 0.0,
        'Ethash': 31.0,  // MH/s (optimized)
        'KawPow': 12.0,  // MH/s
        'Autolykos': 50.0,  // MH/s
        'Scrypt': 0.8,  // MH/s
        'Equihash': 0.30,  // 300 Sol/s
        'RandomX': 0.0006,  // 0.6 KH/s
        'Blake3': 1500.0,  // MH/s
        'BeamHash': 20.0,
        'X11': 11.0,
      },
      // Mid-Range GPUs
      'NVIDIA RTX 3060': {
        'SHA-256': 0.0,
        'Ethash': 49.0,  // MH/s (LHR unlocked)
        'KawPow': 22.0,  // MH/s
        'Autolykos': 85.0,  // MH/s
        'Scrypt': 1.2,  // MH/s
        'Equihash': 0.28,  // 280 Sol/s
        'RandomX': 0.0008,  // 0.8 KH/s
        'Blake3': 2500.0,  // MH/s
        'BeamHash': 28.0,
        'X11': 18.0,
      },
      'NVIDIA RTX 3060 Ti': {
        'SHA-256': 0.0,
        'Ethash': 60.0,  // MH/s
        'KawPow': 30.0,  // MH/s
        'Autolykos': 120.0,  // MH/s
        'Scrypt': 1.5,  // MH/s
        'Equihash': 0.38,  // 380 Sol/s
        'RandomX': 0.001,  // 1.0 KH/s
        'Blake3': 3500.0,  // MH/s
        'BeamHash': 38.0,
        'X11': 24.0,
      },
      // High-End GPUs
      'NVIDIA RTX 3070': {
        'SHA-256': 0.0,
        'Ethash': 62.0,  // MH/s
        'KawPow': 32.0,  // MH/s
        'Autolykos': 125.0,  // MH/s
        'Scrypt': 1.6,  // MH/s
        'Equihash': 0.40,  // 400 Sol/s
        'RandomX': 0.0011,  // 1.1 KH/s
        'Blake3': 3800.0,  // MH/s
        'BeamHash': 40.0,
        'X11': 26.0,
      },
      'AMD RX 6800 XT': {
        'SHA-256': 0.0,
        'Ethash': 64.0,  // MH/s
        'KawPow': 33.0,  // MH/s
        'Autolykos': 130.0,  // MH/s
        'Scrypt': 1.7,  // MH/s
        'Equihash': 0.42,  // 420 Sol/s
        'RandomX': 0.0012,  // 1.2 KH/s
        'Blake3': 4000.0,  // MH/s
        'BeamHash': 42.0,
        'X11': 28.0,
      },
      'NVIDIA RTX 3080': {
        'SHA-256': 0.0,
        'Ethash': 99.0,  // MH/s
        'KawPow': 46.0,  // MH/s
        'Autolykos': 185.0,  // MH/s
        'Scrypt': 2.3,  // MH/s
        'Equihash': 0.65,  // 650 Sol/s
        'RandomX': 0.0017,  // 1.7 KH/s
        'Blake3': 5800.0,  // MH/s
        'BeamHash': 65.0,
        'X11': 40.0,
      },
      'NVIDIA RTX 3090': {
        'SHA-256': 0.0,
        'Ethash': 121.0,  // MH/s
        'KawPow': 58.0,  // MH/s
        'Autolykos': 230.0,  // MH/s
        'Scrypt': 2.9,  // MH/s
        'Equihash': 0.80,  // 800 Sol/s
        'RandomX': 0.0021,  // 2.1 KH/s
        'Blake3': 7200.0,  // MH/s
        'BeamHash': 80.0,
        'X11': 50.0,
      },
      // RTX 40 Series
      'NVIDIA RTX 4070': {
        'SHA-256': 0.0,
        'Ethash': 68.0,  // MH/s
        'KawPow': 34.0,  // MH/s
        'Autolykos': 135.0,  // MH/s
        'Scrypt': 1.8,  // MH/s
        'Equihash': 0.48,  // 480 Sol/s
        'RandomX': 0.0013,  // 1.3 KH/s
        'Blake3': 4200.0,  // MH/s
        'BeamHash': 48.0,
        'X11': 30.0,
      },
      'NVIDIA RTX 4070 Ti': {
        'SHA-256': 0.0,
        'Ethash': 84.0,  // MH/s
        'KawPow': 42.0,  // MH/s
        'Autolykos': 168.0,  // MH/s
        'Scrypt': 2.1,  // MH/s
        'Equihash': 0.58,  // 580 Sol/s
        'RandomX': 0.0016,  // 1.6 KH/s
        'Blake3': 5200.0,  // MH/s
        'BeamHash': 58.0,
        'X11': 36.0,
      },
      'NVIDIA RTX 4080': {
        'SHA-256': 0.0,
        'Ethash': 103.0,  // MH/s
        'KawPow': 51.0,  // MH/s
        'Autolykos': 206.0,  // MH/s
        'Scrypt': 2.6,  // MH/s
        'Equihash': 0.72,  // 720 Sol/s
        'RandomX': 0.002,  // 2.0 KH/s
        'Blake3': 6400.0,  // MH/s
        'BeamHash': 72.0,
        'X11': 45.0,
      },
      'NVIDIA RTX 4090': {
        'SHA-256': 0.0,
        'Ethash': 133.0,  // MH/s
        'KawPow': 66.0,  // MH/s
        'Autolykos': 266.0,  // MH/s
        'Scrypt': 3.3,  // MH/s
        'Equihash': 0.92,  // 920 Sol/s
        'RandomX': 0.0026,  // 2.6 KH/s
        'Blake3': 8200.0,  // MH/s
        'BeamHash': 92.0,
        'X11': 58.0,
      },
      // AMD Latest
      'AMD RX 7900 XTX': {
        'SHA-256': 0.0,
        'Ethash': 95.0,  // MH/s
        'KawPow': 47.0,  // MH/s
        'Autolykos': 190.0,  // MH/s
        'Scrypt': 2.4,  // MH/s
        'Equihash': 0.66,  // 660 Sol/s
        'RandomX': 0.0018,  // 1.8 KH/s
        'Blake3': 5900.0,  // MH/s
        'BeamHash': 66.0,
        'X11': 42.0,
      },
    };
    
    // Get hashrate for this GPU and algorithm
    final gpuData = realWorldData[gpuName];
    if (gpuData == null) return 35.0; // Default fallback
    
    // Return algorithm-specific hashrate normalized to MH/s
    return gpuData[algorithm] ?? gpuData['Ethash'] ?? 35.0;
  }
  
  /// Update location based on progress
  void _updateLocation() {
    final netWorth = _calculateNetWorth();
    final newLocation = LocationDatabase.getCurrentLocation(netWorth, gpuCount);
    
    if (newLocation.id != _currentLocation.id) {
      _currentLocation = newLocation;
      print('🏆 Location upgraded to: ${newLocation.name}');
      print('   Hashrate bonus: ${(newLocation.hashRateBonus * 100).toStringAsFixed(0)}%');
      print('   Power cost: ${(newLocation.powerCostMultiplier * 100).toStringAsFixed(0)}%');
    }
  }
  
  /// Calculate net worth for location progression
  double _calculateNetWorth() {
    // Simple estimate - would need prices passed in for accuracy
    return _balance;
  }
  
  /// Purchase GPU
  bool purchaseGPU(GPU gpu) {
    if (_balance >= gpu.cost) {
      _balance -= gpu.cost;
      _gpus.add(gpu);
      _updateStats();
      _checkAchievements();
      return true;
    }
    return false;
  }
  
  /// Purchase Building
  bool purchaseBuilding(Building building) {
    if (_balance >= building.cost) {
      _balance -= building.cost;
      _buildings.add(building);
      _updateStats();
      _checkAchievements();
      return true;
    }
    return false;
  }
  
  /// Buy cryptocurrency
  bool buyCrypto(String cryptoId, double amount, double price) {
    final cost = amount * price;
    if (_balance >= cost) {
      _balance -= cost;
      _holdings[cryptoId] = (_holdings[cryptoId] ?? 0.0) + amount;
      notifyListeners();
      return true;
    }
    return false;
  }
  
  /// Sell cryptocurrency
  bool sellCrypto(String cryptoId, double amount, double price) {
    final holding = _holdings[cryptoId] ?? 0.0;
    if (holding >= amount) {
      _holdings[cryptoId] = holding - amount;
      _balance += amount * price;
      notifyListeners();
      return true;
    }
    return false;
  }
  
  /// Switch active mining crypto
  void switchMiningCrypto(String cryptoId) {
    _activeCrypto = cryptoId;
    
    // Recalculate hashrate for new algorithm
    _totalHashRate = _calculateTotalHashRateForAlgorithm(cryptoId);
    
    print('\n🔄 SWITCHED TO MINING: ${cryptoId.toUpperCase()}');
    print('   Algorithm-specific hashrate: $_totalHashRate MH/s');
    
    // Immediately calculate and show expected rate
    final reward = _calculateMiningReward(cryptoId, _totalHashRate);
    print('   Expected rate: ${reward.toStringAsFixed(8)} coins/sec');
    print('   Expected daily: ${(reward * 86400).toStringAsFixed(6)} coins/day\n');
    
    notifyListeners();
  }
  
  /// Get WhatToMine data for a specific coin (public accessor)
  MiningProfitabilityData? getWhatToMineData(String coinId) {
    return _whatToMineData[coinId];
  }
  
  /// Manual click/tap to mine - COMPLETELY REWRITTEN
  void performClick(double price) {
    _totalClicks++;
    
    // Base reward per click (scale with coin value)
    double coinsPerClick;
    
    if (price < 0.01) {
      coinsPerClick = 100.0; // Cheap coins
    } else if (price < 0.1) {
      coinsPerClick = 10.0; // Low value like DOGE
    } else if (price < 1) {
      coinsPerClick = 1.0;
    } else if (price < 10) {
      coinsPerClick = 0.1;
    } else if (price < 100) {
      coinsPerClick = 0.01;
    } else if (price < 1000) {
      coinsPerClick = 0.001;
    } else {
      coinsPerClick = 0.0001; // BTC level
    }
    
    // Apply click power and multiplier
    coinsPerClick *= _clickPower * _clickMultiplier;
    
    // Small bonus from hash rate (max 2x at high levels)
    final hashBonus = 1 + math.min(_totalHashRate / 10000, 1.0);
    coinsPerClick *= hashBonus;
    
    final reward = coinsPerClick;
    
    // Add to holdings
    _holdings[_activeCrypto] = (_holdings[_activeCrypto] ?? 0.0) + reward;
    _totalMined[_activeCrypto] = (_totalMined[_activeCrypto] ?? 0.0) + reward;
    
    // Add value to balance
    _balance += reward * price;
    
    notifyListeners();
  }
  
  /// Upgrade click power
  bool upgradeClickPower(double cost) {
    if (_balance >= cost) {
      _balance -= cost;
      _clickPower *= 2.0; // Double click power
      notifyListeners();
      return true;
    }
    return false;
  }
  
  /// Upgrade click multiplier
  bool upgradeClickMultiplier(double cost) {
    if (_balance >= cost) {
      _balance -= cost;
      _clickMultiplier += 0.5; // Add 50% multiplier
      notifyListeners();
      return true;
    }
    return false;
  }
  
  /// Calculate net worth
  double calculateNetWorth(Map<String, double> prices) {
    double total = _balance;
    _holdings.forEach((cryptoId, amount) {
      total += amount * (prices[cryptoId] ?? 0.0);
    });
    return total;
  }
  
  /// Save game
  Future<void> saveGame() async {
    final saveData = GameSaveData(
      balance: _balance,
      holdings: _holdings,
      gpus: _gpus.map((g) => g.toJson()).toList(),
      buildings: _buildings.map((b) => b.toJson()).toList(),
      totalMined: _totalMined,
      activeCrypto: _activeCrypto,
      gameTime: _gameStartTime,
      achievements: _unlockedAchievements,
    );
    
    await StorageService.saveGame(saveData);
  }
  
  /// Reset/Restart game - Start fresh
  Future<void> resetGame() async {
    // Delete save file
    await StorageService.deleteSave();
    
    // Restart with fresh state
    _startNewGame();
    _updateStats();
    notifyListeners();
  }
  
  /// Auto-save
  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      saveGame();
    });
  }
  
  /// Check and unlock achievements
  void _checkAchievements() {
    // Add achievement logic here
  }
  
  @override
  void dispose() {
    _miningTimer?.cancel();
    _autoSaveTimer?.cancel();
    _whatToMineUpdateTimer?.cancel();
    saveGame(); // Save on exit
    super.dispose();
  }
}

/// GPU Model
class GPU {
  final String name;
  final double cost;
  final double hashRate;
  final double powerWatts;
  
  GPU({
    required this.name,
    required this.cost,
    required this.hashRate,
    required this.powerWatts,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'cost': cost,
    'hashRate': hashRate,
    'powerWatts': powerWatts,
  };
  
  factory GPU.fromJson(Map<String, dynamic> json) => GPU(
    name: json['name'],
    cost: json['cost'],
    hashRate: json['hashRate'],
    powerWatts: json['powerWatts'],
  );
}

/// Building Model
class Building {
  final String name;
  final double cost;
  final double powerMultiplier;
  
  Building({
    required this.name,
    required this.cost,
    required this.powerMultiplier,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'cost': cost,
    'powerMultiplier': powerMultiplier,
  };
  
  factory Building.fromJson(Map<String, dynamic> json) => Building(
    name: json['name'],
    cost: json['cost'],
    powerMultiplier: json['powerMultiplier'],
  );
}
