import 'dart:async';
import 'dart:math' as Math;
import 'package:flutter/foundation.dart';
import '../core/services/storage_service.dart';
import '../core/models/mining_data.dart';
import '../core/services/whattomine_service.dart';
import '../core/models/location_data.dart';

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
      print('🔄 Fetching WhatToMine mining data...');
      _whatToMineData = await WhatToMineService.fetchMiningData();
      print('✅ Loaded ${_whatToMineData.length} mineable coins from WhatToMine');
    } catch (e) {
      print('❌ Error fetching WhatToMine data: $e');
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
    switch (miningData.hashRateUnit) {
      case 'TH/s': // Network in Terahash (Bitcoin, Kadena)
        yourHashRateConverted = yourHashRate / 1000000; // MH to TH
        break;
      case 'GH/s': // Network in Gigahash (Dash, Autolykos, etc)
        yourHashRateConverted = yourHashRate / 1000; // MH to GH
        break;
      case 'MH/s': // Network in Megahash (Scrypt, KAWPOW, etc)
        yourHashRateConverted = yourHashRate; // Already in MH
        break;
      case 'KH/s': // Network in Kilohash (Monero, Equihash)
        yourHashRateConverted = yourHashRate * 1000; // MH to KH
        break;
      case 'H/s': // Network in Hash (BeamHash)
        yourHashRateConverted = yourHashRate * 1000000; // MH to H
        break;
      case 'Sol/s': // Solutions per second (Equihash variants - treat as H/s scale)
        yourHashRateConverted = yourHashRate * 1000000; // MH to Sol/s
        break;
      case 'PH/s': // Network in Petahash (Kaspa)
        yourHashRateConverted = yourHashRate / 1000000000; // MH to PH
        break;
      default:
        yourHashRateConverted = yourHashRate;
    }
    
    // Your percentage of network (will be TINY!)
    final yourPercentage = yourHashRateConverted / networkHashRate;
    
    // Blocks per second
    final blocksPerSecond = 1.0 / blockTime;
    
    // Expected coins per second (realistic, will be VERY small)
    final coinsPerSecond = blocksPerSecond * blockReward * yourPercentage;
    
    // Game multiplier: 1x for testing
    return coinsPerSecond * 1.0;
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
    _totalHashRate = _gpus.fold(0.0, (sum, gpu) => sum + gpu.hashRate);
    
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
    print('\n🔄 SWITCHED TO MINING: ${cryptoId.toUpperCase()}');
    print('   Current hashrate: $_totalHashRate MH/s');
    
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
    final hashBonus = 1 + Math.min(_totalHashRate / 10000, 1.0);
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
