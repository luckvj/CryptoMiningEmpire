import 'dart:async';
import 'dart:math' as Math;
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';
import '../core/models/mining_data.dart';
// CoinWarz service removed - using static historical data instead
import '../core/models/location_data.dart';
import '../core/models/historical_data.dart';
import '../core/models/achievements.dart';
import '../core/models/mining_pool.dart';
import '../core/models/upgrades_tree.dart';
import '../core/models/prestige_system.dart';
import '../core/config/game_config.dart';

/// Game state management with mining, trading, and portfolio
class GameStateProvider extends ChangeNotifier {
  // Game Economy
  double _balance = 1000.0;
  Map<String, double> _holdings = {};
  Map<String, double> _totalMined = {};
  String _activeCrypto = GameConfig.defaultActiveCrypto; 
  int _gameYear = DateTime.now().year; // Default to current year
  
  // Dynamic Time System
  DateTime _gameDate = DateTime.now();
  double _timeSpeed = 1.0; // 0 = paused, 1 = normal, 2 = 2x, 5 = 5x
  bool _isDynamicTime = false; // false = static era mode
  Timer? _timeProgressionTimer;
  MarketEvent? _lastTriggeredEvent;
  
  // Mining Pool System
  MiningPool _currentPool = MiningPoolDatabase.solo;

  
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
  double _clickPower = 1.0; 
  int _totalClicks = 0;
  // Boost System (Temporary)
  DateTime? _boostEndTime;
  double _boostMultiplier = 1.0;
  DateTime? _marketLockoutEnd;
  Timer? _lockoutTimer;
 // Cooldown for crypto market updates
  Timer? _boostTimer;
  Timer? _autoSaveTimer;
  List<String> _unlockedAchievements = [];
  
  // Total trades tracking
  int _totalTrades = 0;
  Map<String, double> _purchasePrices = {}; // Track buy prices for profit calc
  
  // WhatToMine data cache - REMOVED (CoinWarz service deleted)
  // Using MiningDatabase for static historical data instead
  Timer? _whatToMineUpdateTimer;
  
  // Achievement notification callback
  Function(Achievement)? onAchievementUnlocked;
  // Market event notification callback
  Function(MarketEvent)? onMarketEvent;
  // Date change callback (for price sync)
  Function(DateTime)? onDateChanged;
  // Genesis Event callback
  Function()? onGenesisBlockMined;
  // Feature Unlock callback (for announcements)
  Function(String featureName, String description)? onFeatureUnlocked;
  
  // Announced features tracker
  Set<String> _announcedFeatures = {};

  // Margin Trading
  List<MarginPosition> _activePositions = [];
  List<MarginPosition> get activePositions => List.unmodifiable(_activePositions);

  // Genesis Mode State
  bool _isGenesisMode = false;
  double _genesisWalletBalance = 0.0;
  bool get isGenesisMode => _isGenesisMode;
  double get genesisWalletBalance => _genesisWalletBalance;
  
  // Pool State
  double _pendingPoolPayout = 0.0;
  double get pendingPoolPayout => _pendingPoolPayout;

  // Upgrade Levels - tracks current level for each upgrade ID
  Map<String, int> _upgradeLevels = {};
  int getUpgradeLevel(String upgradeId) => _upgradeLevels[upgradeId] ?? 0;
  Map<String, int> get upgradeLevels => Map.unmodifiable(_upgradeLevels);
  
  // Feature Announcements
  List<String> get announcedFeatures => _announcedFeatures.toList();

  // Prestige State
  PrestigeData _prestigeData = const PrestigeData();
  PrestigeData get prestigeData => _prestigeData;

  // Circulating supply tracking (simulated global supply)
  Map<String, double> _circulatingSupply = {
    'bitcoin': 0.0,
    'ethereum': 0.0,
    'dogecoin': 0.0,
    'litecoin': 0.0,
  };

  // Click Progression State
  double _clickProgress = 0.0;
  double _clickTarget = GameConfig.defaultClickTarget; // Required 'work' units to mine a block/reward
  double get clickProgress => _clickProgress;
  double get clickTarget => _clickTarget;
  
  // Click Cooldown System (based on in-game time)
  DateTime? _lastBlockMinedDate;
  int _clickCooldownDays = GameConfig.defaultClickCooldownDays; // Days to wait after mining a block
  bool get isClickOnCooldown {
    if (_lastBlockMinedDate == null) return false;
    final daysSinceBlock = _gameDate.difference(_lastBlockMinedDate!).inDays;
    return daysSinceBlock < _clickCooldownDays;
  }
  int get clickCooldownRemaining {
    if (_lastBlockMinedDate == null) return 0;
    final daysSinceBlock = _gameDate.difference(_lastBlockMinedDate!).inDays;
    return (_clickCooldownDays - daysSinceBlock).clamp(0, _clickCooldownDays);
  }
  
  static const Map<String, double> maxSupplies = GameConfig.maxSupplies;

  bool get isTradingAvailable {
    // Trading officially starts with Mt Gox in July 2010
    return _gameDate.isAfter(GameConfig.tradingUnlockDate);
  }
  
  // Time Travel Cooldown
  DateTime? _lastTimeTravelTime;
  final Duration _timeTravelCooldown = const Duration(seconds: 30);
  
  bool get isPoolMiningAvailable {
    // Pool mining starts with Slush Pool (Nov 27, 2010)
    return _gameDate.isAfter(GameConfig.poolMiningUnlockDate);
  }
  
  double getCirculatingSupply(String coinId) => _circulatingSupply[coinId] ?? 0.0;
  
  double getSupplyPercentage(String coinId) {
    final max = maxSupplies[coinId] ?? 1.0;
    return (getCirculatingSupply(coinId) / max).clamp(0.0, 1.0);
  }
  
  GameStateProvider() {
    _initializeGame();
  }
  
  // Getters
  double get balance => _balance;
  int get gameYear => _gameYear;
  Map<String, double> get holdings => Map.unmodifiable(_holdings);
  Map<String, double> get totalMined => Map.unmodifiable(_totalMined);
  String get activeCrypto => _activeCrypto;
  List<GPU> get gpus => List.unmodifiable(_gpus);
  List<Building> get buildings => List.unmodifiable(_buildings);
  double get totalHashRate => _totalHashRate * _currentLocation.hashRateBonus; 
  double get baseHashRate => _totalHashRate; 
  double get dailyPowerCost => _dailyPowerCost * _currentLocation.powerCostMultiplier; 
  double get baseDailyPowerCost => _dailyPowerCost; 
  bool get isMining => _isMining;
  int get gpuCount => _gpus.length;
  int get buildingCount => _buildings.length;
  int get maxGpuCapacity {
    // Base capacity (your room) is 1. Buildings add more.
    return 1 + _buildings.fold(0, (sum, building) => sum + building.maxSlots);
  }
  List<String> get achievements => List.unmodifiable(_unlockedAchievements);
  
  // Location getters
  LocationData get currentLocation => _currentLocation;
  LocationData? get nextLocation => LocationDatabase.getNextLocation(_calculateNetWorth(), gpuCount);
  double get locationProgress => LocationDatabase.getProgressToNext(_calculateNetWorth(), gpuCount);
  
  // Dynamic Time getters
  DateTime get gameDate => _gameDate;
  double get timeSpeed => _timeSpeed;
  bool get isDynamicTime => _isDynamicTime;
  bool get isTimePaused => _timeSpeed == 0;
  MarketEvent? get lastEvent => _lastTriggeredEvent;
  
  // Mining Pool getters
  MiningPool get currentPool => _currentPool;
  
  // Click Mining Getters
  double get currentClickHashRate => 10.0 * _clickPower * clickMultiplier;
  
  double get clickValueInDollars {
     // Calculate dollar value of 1 click (1 second of mining)
     final data = MiningDatabase.getMiningData(_activeCrypto);
     if (data == null) return 0.0;
     
     // New Logic: 1 Click = 1 Second of mining at currentClickHashRate
     // Revenue per day / 86400
     // NOTE: Using 0.0 for price since WhatToMine service was removed
     final revenue = data.calculateDailyRevenue(
        currentClickHashRate, 
        0.0, // WhatToMine service removed
        gameDate: _gameDate, 
        coinId: _activeCrypto
     );
     return revenue / 86400.0;
  }

  bool get isPoolMining => _currentPool.id != 'solo';
  
  // Trade tracking
  int get totalTrades => _totalTrades;
  
  // Clicker getters
  double get clickPower => _clickPower;
  int get totalClicks => _totalClicks;
  

  
  double get clickMultiplier => isBoostActive ? _boostMultiplier : 1.0;
  double get boostMultiplier => _boostMultiplier;
  bool get isBoostActive => _boostEndTime != null && _boostEndTime!.isAfter(DateTime.now());
  double get boostTimeRemaining => _boostEndTime == null ? 0 : _boostEndTime!.difference(DateTime.now()).inSeconds.toDouble();
  Duration get boostRemaining => _boostEndTime == null ? Duration.zero : _boostEndTime!.difference(DateTime.now());

  // Market Lockout Getters
  bool get isMarketLocked => _marketLockoutEnd != null && _marketLockoutEnd!.isAfter(DateTime.now());
  int get marketLockoutRemainingSeconds => _marketLockoutEnd == null ? 0 : _marketLockoutEnd!.difference(DateTime.now()).inSeconds;
  
  bool get canTimeTravel {
    if (_lastTimeTravelTime == null) return true;
    return DateTime.now().difference(_lastTimeTravelTime!) > _timeTravelCooldown;
  }
  
  int get timeTravelCooldownRemaining {
    if (_lastTimeTravelTime == null) return 0;
    final remaining = _timeTravelCooldown - DateTime.now().difference(_lastTimeTravelTime!);
    return remaining.isNegative ? 0 : remaining.inSeconds;
  }
  
  // Current location
  LocationData _currentLocation = LocationDatabase.locations.first;

  /// Calculate total daily revenue across all GPUs (Estimated using HashRate proxy)
  /// Since we don't have direct access to live prices here, we use HashPower as a proxy for empire size.
  /// 1 MH/s ~ $0.001 per day roughly in balanced mode
  double calculateTotalDailyRevenue() {
    return _totalHashRate * GameConfig.estimatedRevenuePerMHs; 
  }
  double _lastCalculatedDailyRevenue = 0.0;
  
  /// Initialize game - load save or start new
  Future<void> _initializeGame() async {
    final saveData = StorageService.loadGame();
    
    if (saveData != null) {
      _loadFromSave(saveData);
    } else {
      _startNewGame();
    }
    
    // Fetch WhatToMine data for accurate mining
    // Fetch WhatToMine data for accurate mining (Run in background, don't await)
    _fetchWhatToMineData();
    
    _startTimeProgression();
    _startAutoSave();
    _startWhatToMineUpdates();
    notifyListeners();
  }

  // ... (Lines 94-414 assumed unchanged or handled)

  /// Calculate reward using static database (fallback)
  /// Now delegates to MiningData for centralized historical logic
  double _calculateRewardFromStaticData(MiningData miningData, double hashRate) {
    // Calculate coins per day using the centralized logic
    // We pass the active crypto ID to ensure correct historical scaling (e.g. Halvings)
    double coinsPerDay = miningData.calculateCoinsPerDay(
      hashRate, // MH/s
      gameDate: _gameDate,
      coinId: _activeCrypto
    );
    
    // Convert to coins per second (Game loop runs every second)
    return coinsPerDay / 86400.0;
  }

  // ... (Lines 473-508 assumed unchanged)

  /// Update stats
  void _updateStats() {
    // Use hashRateInMHs for proper unit conversion
    // TH/s miners will be converted to MH/s equivalent
    double baseHashRate = _gpus.fold(0.0, (sum, gpu) => sum + gpu.hashRateInMHs);
    
    // Apply Prestige Multiplier for Mining Speed
    final miningSpeedUpgrade = PrestigeUpgrades.getById('mining_speed');
    double miningMultiplier = 1.0;
    if (miningSpeedUpgrade != null) {
       final level = _prestigeData.upgradeLevels['mining_speed'] ?? 0;
       if (level > 0) {
         // getEffect returns 1.0 + bonus (e.g. 1.20 for level 1)
         // Since getEffect takes level+1 in UI logic (display next level), we should check implementation
         // PrestigeUpgrade.getEffect(level) => 1.0 + (effectPerLevel * level)
         // So for level 1, it's 1.2. Correct.
         miningMultiplier = miningSpeedUpgrade.getEffect(level);
       }
    }
    
    _totalHashRate = baseHashRate * miningMultiplier;
    
    final totalPowerWatts = _gpus.fold(0.0, (sum, gpu) => sum + gpu.powerWatts);
    // Calculate power multiplier with a CAP at 75% discount (0.25 minimum)
    final rawPowerMultiplier = _buildings.isEmpty ? 1.0 
        : _buildings.map((b) => b.powerMultiplier).reduce((a, b) => a < b ? a : b);
    final powerMultiplier = rawPowerMultiplier < GameConfig.maxPowerDiscount ? GameConfig.maxPowerDiscount : rawPowerMultiplier; // Cap at 75% discount
    final totalPowerKW = (totalPowerWatts * powerMultiplier) / 1000.0;
    _dailyPowerCost = totalPowerKW * 24 * GameConfig.powerCostPerKWh; // $0.12 per kWh
    
    // Update click power based on miners - REMOVED TO RESPECT UPGRADES
    // _clickPower = 1.0 + (_gpus.length * 0.5); // <-- This was checking upgrade purchase
    
    // AUTO-ENABLE MINING when player has GPUs
    // This was the critical bug - _isMining was never set to true!
    _isMining = _gpus.isNotEmpty && _totalHashRate > 0;
    
    // Update current location
    _updateLocation();
    
    notifyListeners();
  }

  // ... (Lines 536-966)

  /// Reset/Restart game - Start fresh with specific year (defaults to genesis)
  Future<void> resetGame({int? year, double? initialBalance, bool genesisMode = false}) async {
    // Delete save file
    await StorageService.deleteSave();
    
    // Restart with fresh state
    _startNewGame();
    
    // ALWAYS reset Satoshi's Wallet on game restart
    _genesisWalletBalance = 0.0;
    
    if (year != null) {
      _gameYear = year;
      _gameDate = DateTime(year, 1, 1);
      _isGenesisMode = (year == 2009);
      
      // Scale starting balance based on era
      if (initialBalance != null) {
        _balance = initialBalance;
      } else {
        // Era-appropriate starting balance
        if (year >= 2020) {
          _balance = GameConfig.startingBalanceModern; // Modern era - need more capital
        } else if (year >= 2015) {
          _balance = GameConfig.startingBalanceASIC;  // ASIC era
        } else if (year >= 2011) {
          _balance = GameConfig.startingBalanceEarlyGPU;  // GPU mining era
        } else {
          _balance = GameConfig.startingBalanceGenesis;   // Genesis era
        }
      }
    } else {
      // No year specified = present day with more money
      final now = DateTime.now();
      // STABLE DATE: Use granularity of a day to keep simulation seeds consistent
      _gameDate = DateTime(now.year, now.month, now.day);
      _gameYear = now.year;
      _isGenesisMode = false;
      _balance = initialBalance ?? GameConfig.startingBalanceModern; // Present era gets $10,000
    }
    
    // Override for explicit genesis mode
    if (genesisMode) {
      _isGenesisMode = true;
      _gameDate = GameConfig.dateGenesisCheck;
      _gameYear = 2009;
      _balance = GameConfig.startingBalanceGenesis;
    }
    
    // Lock market for 30 seconds if returning to modern era or jumping
    if (year == null || year >= 2024) {
      lockMarket(30);
    }
    
    // Reset volatility in provider if it exists
    onDateChanged?.call(_gameDate);
    
    // Attempt 8: Auto-pause game on era entry
    setTimeSpeed(0);
    
    // Attempt 12: Set cooldown
    _lastTimeTravelTime = DateTime.now();
    
    _updateStats();
    notifyListeners();
  }

  /// Lock the crypto market for a specific duration
  void lockMarket(int seconds) {
    _marketLockoutEnd = DateTime.now().add(Duration(seconds: seconds));
    notifyListeners();
    
    // Start a ticker to notify listeners every second (for the countdown UI)
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isMarketLocked) {
        timer.cancel();
      }
      notifyListeners();
    });
  }
  
  /// Fetch WhatToMine data for mining calculations
  /// NOTE: CoinWarz service removed - game uses static historical data now
  Future<void> _fetchWhatToMineData() async {
    // No external API calls needed - using MiningDatabase for historical accuracy
  }
  
  /// Start periodic WhatToMine updates (every 10 minutes)
  void _startWhatToMineUpdates() {
    _whatToMineUpdateTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      _fetchWhatToMineData();
    });
  }
  
  /// Start new game
  void _startNewGame() {
    _balance = GameConfig.startingBalanceGenesis; // Starting with $130 for Genesis era (enough for HD 5870 @ $120)
    _holdings = {
      'bitcoin': 0.0,
      'ethereum': 0.0,
      'dogecoin': 0.0,
      'litecoin': 0.0,
    };
    _totalMined = {..._holdings};
    _activeCrypto = GameConfig.defaultActiveCrypto; // Default to Bitcoin
    _gpus = [];
    _buildings = [];
    _gameStartTime = DateTime.now();
    
    // START IN GENESIS ERA BY DEFAULT
    _gameDate = GameConfig.dateGenesisCheck;
    _gameYear = 2009;
    _isGenesisMode = true;
    _genesisWalletBalance = 0.0;
    
    _clickPower = GameConfig.defaultClickPower;
    _clickProgress = 0.0;
    _clickTarget = GameConfig.defaultClickTarget;
    _lastBlockMinedDate = null;
    _totalClicks = 0;
    _boostEndTime = null;
    _boostMultiplier = 1.0;
    
    // Upgrade levels reset
    _upgradeLevels = {};
    _announcedFeatures = {};
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
    
    // Legacy Genesis Migration
    // If we loaded a save from before the fix, 50 BTC might be in holdings but not genesis wallet
    if (_isGenesisMode && (_holdings['bitcoin'] ?? 0) >= 50.0 && _genesisWalletBalance == 0) {
       _genesisWalletBalance = 50.0;
       _holdings['bitcoin'] = (_holdings['bitcoin'] ?? 50.0) - 50.0;
       
       // Also fix total mined if it was polluted
       if ((_totalMined['bitcoin'] ?? 0) >= 50.0) {
          _totalMined['bitcoin'] = (_totalMined['bitcoin'] ?? 50.0) - 50.0;
       }
    }
    // Restore time state
    _gameDate = data.gameDate;
    _gameYear = data.gameDate.year;
    _timeSpeed = data.timeSpeed;
    _isDynamicTime = data.isDynamicTime;
    _announcedFeatures = data.announcedFeatures.toSet();

    // Restore positions
    _activePositions = data.positions.map((json) => MarginPosition.fromJson(json)).toList();
    
    // CRITICAL: Restart time progression if was running
    if (_isDynamicTime && _timeSpeed > 0) {
      _startTimeProgression();
    }
    _updateStats();
  }
  
  /// Start mining timer

  
  /// Calculate mining reward using WhatToMine data - REAL CALCULATIONS
  double _calculateMiningReward(String cryptoId, double hashRate) {
    // 1. Check chronological existence first!
    if (!HistoricalPriceData.coinExistsAt(cryptoId, _gameDate)) {
      return 0.0;
    }

    // 2. Use static database (WhatToMine/CoinWarz services removed)
    final miningData = MiningDatabase.getMiningData(cryptoId);
    
    // If not mineable or no data, return 0
    if (miningData == null || !miningData.isMineable) {
      return 0.0;
    }
    
    return _calculateRewardFromStaticData(miningData, hashRate);
  }
  
  // NOTE: _calculateRewardFromWhatToMine removed - CoinWarz service deleted
  // Using static MiningDatabase for mining calculations now
  
  /// Calculate reward using static database (fallback)

  
  /// Activate Click Boost (Temporary Random Multiplier)
  bool activateClickBoost(double cost) {
    if (_balance >= cost) {
      _balance -= cost;
      
      // Random multiplier between 2.0x and 10.0x
      final random = Math.Random();
      _boostMultiplier = 2.0 + random.nextDouble() * 8.0;
      
      // Set duration (30 seconds)
      _boostEndTime = DateTime.now().add(const Duration(seconds: 30));
      
      // Cancel existing timer if any
      _boostTimer?.cancel();
      
      // Start timer to refresh UI when boost ends
      _boostTimer = Timer(const Duration(seconds: 30), () {
        _boostEndTime = null;
        _boostMultiplier = 1.0;
        notifyListeners();
      });
      
      _updateStats();
      return true;
    }
    return false;
  }

  /// Calculate total hash rate in MH/s (with unit conversion)
  double _calculateTotalHashRate() {
    return _gpus.fold(0.0, (sum, gpu) => sum + gpu.hashRateInMHs);
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
      // ASIC Miners - SHA-256 optimized (TH/s converted to MH/s equivalent)
      'Antminer S19 Pro': {
        'SHA-256': 110000.0,  // 110 TH/s = 110,000,000 MH/s (in TH/s for BTC calculations)
        'Ethash': 0.0,
        'KawPow': 0.0,
        'Autolykos': 0.0,
        'Scrypt': 0.0,
        'Equihash': 0.0,
        'RandomX': 0.0,
        'Blake3': 0.0,
        'BeamHash': 0.0,
        'X11': 0.0,
      },
      'Antminer S19 XP': {
        'SHA-256': 140000.0,  // 140 TH/s
        'Ethash': 0.0,
        'KawPow': 0.0,
        'Autolykos': 0.0,
        'Scrypt': 0.0,
        'Equihash': 0.0,
        'RandomX': 0.0,
        'Blake3': 0.0,
        'BeamHash': 0.0,
        'X11': 0.0,
      },
      'Whatsminer M30S++': {
        'SHA-256': 112000.0,  // 112 TH/s
        'Ethash': 0.0,
        'KawPow': 0.0,
        'Autolykos': 0.0,
        'Scrypt': 0.0,
        'Equihash': 0.0,
        'RandomX': 0.0,
        'Blake3': 0.0,
        'BeamHash': 0.0,
        'X11': 0.0,
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
      
      // In Genesis mode, auto-select Bitcoin for both active crypto and miner assignment
      if (_isGenesisMode && _gpus.isEmpty) {
        _activeCrypto = 'bitcoin';
        gpu.miningCoinId = 'bitcoin'; // Set the miner to mine BTC
      }
      
      _gpus.add(gpu);
      _updateStats();
      _checkAchievements();
      return true;
    }
    return false;
  }
  
  /// Set the coin a specific miner should mine
  void setMinerCoin(int minerIndex, String coinId) {
    if (minerIndex >= 0 && minerIndex < _gpus.length) {
      final miner = _gpus[minerIndex];
      if (miner.canMine(coinId)) {
        miner.miningCoinId = coinId;
        notifyListeners();
      }
    }
  }
  
  /// Get all miners grouped by the coin they're mining
  Map<String, List<GPU>> get minersByCoin {
    final Map<String, List<GPU>> result = {};
    for (final miner in _gpus) {
      result.putIfAbsent(miner.miningCoinId, () => []);
      result[miner.miningCoinId]!.add(miner);
    }
    return result;
  }
  
  /// Get total hash rate for a specific coin
  double getHashRateForCoin(String coinId) {
    return _gpus
        .where((m) => m.miningCoinId == coinId)
        .fold(0.0, (sum, m) => sum + m.hashRateInMHs);
  }
  
  /// Purchase Building
  bool purchaseBuilding(Building building) {
    if (_balance >= building.cost) {
      _balance -= building.cost;
      _buildings.add(building);
      _updateStats();
      _checkAchievements();
      notifyListeners(); // Ensure UI updates immediately
      return true;
    }
    return false;
  }
  
  /// Purchase Upgrade - returns true if successful
  bool purchaseUpgrade(String upgradeId) {
    final upgrade = UpgradesDatabase.getById(upgradeId);
    if (upgrade == null) return false;
    
    final currentLevel = _upgradeLevels[upgradeId] ?? 0;
    
    // Check if already maxed
    if (currentLevel >= upgrade.maxLevel) return false;
    
    // Check prerequisites - each required upgrade must be at least level 1
    for (final reqId in upgrade.requirements) {
      if ((_upgradeLevels[reqId] ?? 0) < 1) {
        return false; // Prerequisite not met
      }
    }
    
    // Calculate cost
    final cost = upgrade.getCost(currentLevel);
    if (_balance < cost) return false;
    
    // Purchase!
    _balance -= cost;
    _upgradeLevels[upgradeId] = currentLevel + 1;
    
    // Apply upgrade effects based on category
    _applyUpgradeEffect(upgrade, currentLevel + 1);
    
    notifyListeners();
    return true;
  }
  
  /// Apply upgrade effect based on type
  void _applyUpgradeEffect(GameUpgrade upgrade, int newLevel) {
    switch (upgrade.category) {
      case 'click':
        // Click upgrades add to click power (MH/s per tap)
        // Each level adds effectPerLevel to base click power
        _clickPower += upgrade.effectPerLevel;
        break;
      case 'efficiency':
        // Efficiency upgrades reduce target/increase speed
        _clickTarget = (_clickTarget * 0.95).clamp(10.0, 1000.0);
        break;
      case 'automation':
        // Automation upgrades could add passive bonuses
        break;
      case 'special':
        // Special case handling
        break;
    }
  }
  
  /// Check if upgrade prerequisites are met
  bool canPurchaseUpgrade(String upgradeId) {
    final upgrade = UpgradesDatabase.getById(upgradeId);
    if (upgrade == null) return false;
    
    final currentLevel = _upgradeLevels[upgradeId] ?? 0;
    if (currentLevel >= upgrade.maxLevel) return false;
    
    // Check prerequisites
    for (final reqId in upgrade.requirements) {
      if ((_upgradeLevels[reqId] ?? 0) < 1) return false;
    }
    
    // Check cost
    final cost = upgrade.getCost(currentLevel);
    return _balance >= cost;
  }
  
  /// Check if prerequisites are met (regardless of cost)
  bool areUpgradePrerequisitesMet(String upgradeId) {
    final upgrade = UpgradesDatabase.getById(upgradeId);
    if (upgrade == null) return false;
    
    for (final reqId in upgrade.requirements) {
      if ((_upgradeLevels[reqId] ?? 0) < 1) return false;
    }
    return true;
  }
  
  /// Buy cryptocurrency
  bool buyCrypto(String cryptoId, double amount, double price) {
    if (!isTradingAvailable) return false;
    
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
    if (!isTradingAvailable) return false;
    
    final holding = _holdings[cryptoId] ?? 0.0;
    if (holding >= amount) {
      _holdings[cryptoId] = holding - amount;
      _balance += amount * price;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Open a Margin Position (Long/Short)
  /// Callback for margin not available (before USDT era)
  Function()? onMarginNotAvailable;
  
  /// Callback for liquidation
  Function(MarginPosition)? onLiquidated;

  /// Callback for manual position closure (Position, PnL, Return Amount)
  Function(MarginPosition, double, double)? onPositionClosed;
  
  bool openMarginPosition({
    required String coinId,
    required double amount, // The USD collateral
    required double entryPrice,
    required bool isShort,
    double leverage = 1.0,
  }) {
    if (!isTradingAvailable) return false;
    
    // USDT (the stablecoin needed for margin trading) launched Oct 6, 2014
    // Margin trading wasn't really possible before stablecoins
    final usdtLaunchDate = DateTime(2014, 10, 6);
    if (_gameDate.isBefore(usdtLaunchDate)) {
      onMarginNotAvailable?.call();
      return false;
    }
    
    // Basic validation
    if (amount <= 0 || entryPrice <= 0) return false;
    
    // Check if player can afford the collateral in USDT
    final usdtHoldings = _holdings['tether'] ?? 0.0;
    if (usdtHoldings >= amount) {
      _holdings['tether'] = usdtHoldings - amount;
      final position = MarginPosition(
        id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString(),
        cryptoId: coinId,
        amount: amount,
        entryPrice: entryPrice,
        type: isShort ? PositionType.short : PositionType.long,
        leverage: leverage,
        entryDate: _gameDate,
      );
      _activePositions.add(position);
      _totalTrades++;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Close a Margin Position
  void closeMarginPosition(String positionId, double currentPrice) {
    final index = _activePositions.indexWhere((p) => p.id == positionId);
    if (index != -1) {
      final position = _activePositions[index];
      final pnl = position.calculatePnL(currentPrice);
      
      // Return collateral + P/L (can be negative but not below 0 if liquidated)
      // All payouts are returned to USDT holdings
      final payout = position.amount + pnl;
      final cleanPayout = payout > 0 ? payout : 0.0;
      _holdings['tether'] = (_holdings['tether'] ?? 0.0) + cleanPayout;
      
      onPositionClosed?.call(position, pnl, cleanPayout);
      
      // Attempt 7: Auto-pause game on closure
      setTimeSpeed(0);
      
      _activePositions.removeAt(index);
      notifyListeners();
    }
  }

  /// Check all active margin positions for liquidation
  /// Liquidation occurs if P/L wipes out the collateral
  void checkLiquidations(Map<String, double> currentPrices) {
    if (_activePositions.isEmpty) return;

    List<String> toLiquidate = [];
    
    for (var position in _activePositions) {
      final currentPrice = currentPrices[position.cryptoId];
      if (currentPrice == null || currentPrice <= 0) continue;

      final pnl = position.calculatePnL(currentPrice);
      // Liquidation condition: P/L <= -Collateral
      // This means equity (Collateral + P/L) is 0 or less
      if (pnl <= -position.amount) {
        toLiquidate.add(position.id);
      }
    }

    if (toLiquidate.isEmpty) return;

    for (var positionId in toLiquidate) {
      final index = _activePositions.indexWhere((p) => p.id == positionId);
      if (index != -1) {
        final position = _activePositions[index];
        onLiquidated?.call(position);
        
        // Attempt 7: Auto-pause game on liquidation
        setTimeSpeed(0);
        
        _activePositions.removeAt(index);
      }
    }
    
    notifyListeners();
  }
  
  /// Switch active mining crypto
  void switchMiningCrypto(String cryptoId) {
    _activeCrypto = cryptoId;
    
    // SYNC: Update all compatible miners to mine this coin
    int updatedMiners = 0;
    for (final miner in _gpus) {
      if (miner.canMine(cryptoId)) {
        miner.miningCoinId = cryptoId;
        updatedMiners++;
      }
    }
    
    
    // Calculate expected mining rate for this coin
    final reward = _calculateMiningReward(cryptoId, _totalHashRate);
    
    notifyListeners();
  }
  
  // NOTE: getWhatToMineData removed - service was deleted
  
  /// Manual click/tap to mine
  /// NEW: Hashrate-based clicking logic (Real World Balancing)
  /// Returns the amount of coins earned from this click (only > 0 when block is mined)
  double performClick(double price) {
    // Check cooldown - can't click if on cooldown (except first block)
    if (isClickOnCooldown && (_totalMined[_activeCrypto] ?? 0) > 0) {
      return 0.0; // Still on cooldown
    }
    
    _totalClicks++;
    
    // Base Click Hashrate: starts at 10 MH/s (CPU equivalent)
    const double baseClickHash = 10.0; 
    final double clickHashRate = baseClickHash * _clickPower * clickMultiplier;
    
    // Add work to progress
    _clickProgress += clickHashRate;
    
    double coinsEarned = 0.0;
    
    // Check if block/reward threshold met
    if (_clickProgress >= _clickTarget) {
      // FULL BLOCK REWARD when progress bar fills
      final miningData = MiningDatabase.getMiningData(_activeCrypto);
      if (miningData != null) {
        // Get the actual block reward for the current date
        coinsEarned = miningData.getEffectiveBlockReward(_gameDate, coinId: _activeCrypto);
      }

      // Genesis Era Special Case - always 50 BTC for first block
      // These coins go to "Satoshi's Wallet" and can NEVER be spent
      if (_activeCrypto == 'bitcoin' && _gameYear == 2009 && (_totalMined['bitcoin'] ?? 0) == 0) {
         coinsEarned = 50.0;
         // Send to Satoshi's Wallet (unspendable)
         _genesisWalletBalance += coinsEarned;
         _totalMined[_activeCrypto] = (_totalMined[_activeCrypto] ?? 0.0) + coinsEarned;
         
         // DO NOT auto-resume time - player must click play button
         // Just trigger the success dialog
         Future.microtask(() {
           onGenesisBlockMined?.call(); // Trigger the success dialog only
           notifyListeners();
         });
         
         // Reset progress and return early - don't add to regular holdings
         _clickProgress = 0.0;
         notifyListeners();
         return coinsEarned;
      }

      if (coinsEarned > 0) {
        _holdings[_activeCrypto] = (_holdings[_activeCrypto] ?? 0.0) + coinsEarned;
        _totalMined[_activeCrypto] = (_totalMined[_activeCrypto] ?? 0.0) + coinsEarned;
        
        // Set cooldown - player must wait before clicking again
        _lastBlockMinedDate = _gameDate;
      }
      
      _clickProgress = 0.0; // Reset progress
    }
    
    notifyListeners();
    return coinsEarned;
  }
  
  /// Get estimated blocks per day for a specific coin at current hashrate
  double estimateBlocksPerDay(String coinId) {
    final miningData = MiningDatabase.getMiningData(coinId);
    if (miningData == null || totalHashRate <= 0) return 0.0;
    
    final dailyCoins = miningData.calculateCoinsPerDay(
      totalHashRate, 
      gameDate: _gameDate, 
      coinId: coinId
    );
    
    final blockReward = miningData.getEffectiveBlockReward(_gameDate, coinId: coinId);
    if (blockReward <= 0) return 0.0;
    
    return dailyCoins / blockReward;
  }

  /// Get the current dollar value per click (for display)
  /// Add balance (Debug/Cheat)
  void addBalance(double amount) {
    _balance += amount;
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
      gameDate: _gameDate,
      timeSpeed: _timeSpeed,
      isDynamicTime: _isDynamicTime,
      positions: _activePositions.map((p) => p.toJson()).toList(),
      genesisWalletBalance: _genesisWalletBalance,
      isGenesisMode: _isGenesisMode,
      upgradeLevels: _upgradeLevels,
      announcedFeatures: _announcedFeatures.toList(),
    );
    
    await StorageService.saveGame(saveData);
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
  
  // Check for completion in separate method
  void _checkGenesisCompletion() {
    if (_genesisWalletBalance >= 50.0) {
      _isGenesisMode = false; 
      // Do not touch holdings, as they are separate from Genesis Balance now.
      onGenesisBlockMined?.call();
      // DO NOT auto-start time - player must click play button manually
    }
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

/// Miner type enumeration
enum MinerType { cpu, gpu, asic }

/// Algorithm compatibility map - which algorithms can mine which coins
class AlgorithmCompatibility {
  static const Map<String, List<String>> algorithmToCoins = {
    'SHA-256': ['bitcoin', 'bitcoin-cash'],
    'Scrypt': ['litecoin', 'dogecoin'],
    'Ethash': ['ethereum-classic'],
    'KawPow': ['ravencoin'],
    'Autolykos': ['ergo'],
    'Equihash': ['zcash', 'bitcoin-gold'],
    'RandomX': ['monero'],
    'X11': ['dash'],
    'kHeavyHash': ['kaspa'],
    'Octopus': ['conflux-token'],
    'ZelHash': ['flux'],
  };
  
  /// Reverse mapping: coin to required miner type
  static const Map<String, String> coinToMinerType = {
    'bitcoin': 'ASIC (SHA-256)',
    'bitcoin-cash': 'ASIC (SHA-256)',
    'litecoin': 'GPU/ASIC (Scrypt)',
    'dogecoin': 'GPU/ASIC (Scrypt)',
    'ethereum-classic': 'GPU (Ethash)',
    'monero': 'CPU (RandomX)',
    'ravencoin': 'GPU (KawPow)',

    'ergo': 'GPU (Autolykos)',
    'zcash': 'GPU (Equihash)',
    'bitcoin-gold': 'GPU (Equihash)',
    'dash': 'ASIC (X11)',
    'flux': 'GPU (ZelHash)',
    'kaspa': 'GPU (kHeavyHash)',
    'conflux-token': 'GPU (Octopus)',
  };
  
  /// Get compatible coins for an algorithm
  static List<String> getCompatibleCoins(String algorithm) {
    return algorithmToCoins[algorithm] ?? [];
  }
  
  /// Check if a miner can mine a specific coin
  static bool canMine(String algorithm, String coinId) {
    final compatibleCoins = algorithmToCoins[algorithm];
    return compatibleCoins?.contains(coinId) ?? false;
  }
  
  /// Get default coin for an algorithm
  static String? getDefaultCoin(String algorithm) {
    final coins = algorithmToCoins[algorithm];
    return coins?.isNotEmpty == true ? coins!.first : null;
  }
  
  /// Get required miner type for a coin
  static String getMinerTypeForCoin(String coinId) {
    return coinToMinerType[coinId] ?? 'GPU';
  }
  
  /// Get algorithm info for display
  static String getAlgorithmInfo(String algorithm) {
    final coins = algorithmToCoins[algorithm] ?? [];
    if (coins.isEmpty) return 'No compatible coins';
    return 'Mines: ${coins.map((c) => c.split('-').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')).join(', ')}';
  }
}
/// GPU/Miner Model - supports CPUs, GPUs, and ASICs
class GPU {
  final String name;
  final double cost;
  final double hashRate;
  final String hashRateUnit; // TH/s, GH/s, MH/s, KH/s, Sol/s
  final double powerWatts;
  final String algorithm; // Primary algorithm (e.g. Ethash)
  final List<String> supportedAlgorithms; // All supported algorithms
  final MinerType minerType; // cpu, gpu, asic
  String miningCoinId; // The coin this miner is currently mining
  
  GPU({
    required this.name,
    required this.cost,
    required this.hashRate,
    this.hashRateUnit = 'MH/s',
    required this.powerWatts,
    this.algorithm = 'Ethash',
    List<String>? supportedAlgorithms,
    this.minerType = MinerType.gpu,
    String? miningCoinId,
  }) : supportedAlgorithms = supportedAlgorithms ?? (minerType == MinerType.gpu ? ['Ethash', 'KawPow', 'SHA-256'] : [algorithm]),
       miningCoinId = miningCoinId ?? AlgorithmCompatibility.getDefaultCoin(algorithm) ?? (minerType == MinerType.gpu ? 'ethereum-classic' : 'bitcoin');
  
  /// Legacy getter for compatibility
  bool get isASIC => minerType == MinerType.asic;
  bool get isCPU => minerType == MinerType.cpu;
  bool get isGPU => minerType == MinerType.gpu;
  
  /// Get formatted hash rate with unit
  String get formattedHashRate => '${hashRate.toStringAsFixed(hashRate >= 100 ? 0 : 1)} $hashRateUnit';
  
  /// Get miner type display name
  String get minerTypeDisplay {
    switch (minerType) {
      case MinerType.cpu: return 'CPU';
      case MinerType.gpu: return 'GPU';
      case MinerType.asic: return 'ASIC';
    }
  }
  
  /// Get list of coins this miner can mine
  List<String> get compatibleCoins {
    final allCoins = <String>[];
    for (final algo in supportedAlgorithms) {
      allCoins.addAll(AlgorithmCompatibility.getCompatibleCoins(algo));
    }
    return allCoins.toSet().toList();
  }
  
  /// Check if this miner can mine a specific coin
  bool canMine(String coinId) {
    for (final algo in supportedAlgorithms) {
      if (AlgorithmCompatibility.canMine(algo, coinId)) return true;
    }
    return false;
  }

  GPU copyWith({
    String? name,
    double? cost,
    double? hashRate,
    String? hashRateUnit,
    double? powerWatts,
    String? algorithm,
    List<String>? supportedAlgorithms,
    MinerType? minerType,
    String? miningCoinId,
  }) {
    return GPU(
      name: name ?? this.name,
      cost: cost ?? this.cost,
      hashRate: hashRate ?? this.hashRate,
      hashRateUnit: hashRateUnit ?? this.hashRateUnit,
      powerWatts: powerWatts ?? this.powerWatts,
      algorithm: algorithm ?? this.algorithm,
      supportedAlgorithms: supportedAlgorithms ?? this.supportedAlgorithms,
      minerType: minerType ?? this.minerType,
      miningCoinId: miningCoinId ?? this.miningCoinId,
    );
  }
  
  /// Set the coin this miner is mining (with validation)
  bool setMiningCoin(String coinId) {
    if (canMine(coinId)) {
      miningCoinId = coinId;
      return true;
    }
    return false;
  }
  
  /// Convert hash rate to MH/s equivalent for calculations
  double get hashRateInMHs {
    // Basic unit conversion
    double rateInMHs;
    switch (hashRateUnit) {
      case 'TH/s': rateInMHs = hashRate * 1000000; break;
      case 'GH/s': rateInMHs = hashRate * 1000; break;
      case 'MH/s': rateInMHs = hashRate; break;
      case 'KH/s': rateInMHs = hashRate / 1000; break;
      case 'Sol/s': rateInMHs = hashRate * 0.000001; break; // Sol/s is essentially Hash/s? Zcash 1 KSol = 1000 Sol. If measured in MH/s...
      // Equihash solutions per second are not directly comparable to hashes.
      // But typically 1 MSol/s is a lot.
      // Let's stick to a simpler conversion or use the previous one.
      // Previous: return hashRate / 1000000;
      default: rateInMHs = hashRate;
    }
    
    // Quick balancing for GPU mining algorithms (relative to Ethash base)
    if (isGPU) {
      // Find which algo we are currently mining
      String currentAlgo = algorithm;
      for (final algo in supportedAlgorithms) {
        if (AlgorithmCompatibility.canMine(algo, miningCoinId)) {
          currentAlgo = algo;
          break;
        }
      }
      
      // Apply modifiers relative to Ethash (assuming base rate is Ethash)
      if (currentAlgo == 'KawPow') return rateInMHs * 0.5; // KawPow is ~1/2 Ethash
      if (currentAlgo == 'Autolykos') return rateInMHs * 2.0; // Autolykos is ~2x Ethash
      if (currentAlgo == 'ZelHash') return rateInMHs * 0.5; // Flux is ~1/2 Ethash
    }
    
    return rateInMHs;
  }
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'cost': cost,
    'hashRate': hashRate,
    'hashRateUnit': hashRateUnit,
    'powerWatts': powerWatts,
    'algorithm': algorithm,
    'supportedAlgorithms': supportedAlgorithms,
    'minerType': minerType.name,
    'miningCoinId': miningCoinId,
  };
  
  factory GPU.fromJson(Map<String, dynamic> json) => GPU(
    name: json['name'],
    cost: json['cost'],
    hashRate: json['hashRate'],
    hashRateUnit: json['hashRateUnit'] ?? 'MH/s',
    powerWatts: json['powerWatts'],
    algorithm: json['algorithm'] ?? 'Ethash',
    supportedAlgorithms: (json['supportedAlgorithms'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    minerType: MinerType.values.firstWhere(
      (e) => e.name == (json['minerType'] ?? 'gpu'),
      orElse: () => MinerType.gpu,
    ),
    miningCoinId: json['miningCoinId'],
  );
}

/// Building Model
class Building {
  final String name;
  final double cost;
  final double powerMultiplier;
  final String description;
  final String imageUrl;
  final int maxSlots;
  
  Building({
    required this.name,
    required this.cost,
    required this.powerMultiplier,
    this.description = '',
    this.imageUrl = '',
    this.maxSlots = 0,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'cost': cost,
    'powerMultiplier': powerMultiplier,
    'description': description,
    'imageUrl': imageUrl,
    'maxSlots': maxSlots,
  };
  
  factory Building.fromJson(Map<String, dynamic> json) => Building(
    name: json['name'],
    cost: json['cost'],
    powerMultiplier: json['powerMultiplier'],
    description: json['description'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    maxSlots: json['maxSlots'] ?? 0,
  );
}

/// Margin Trading Position Model
/// Margin Trading Position Model
class MarginPosition {
  final String id;
  final String cryptoId;
  final double amount; // Margin collateral in USD
  final double entryPrice;
  final PositionType type;
  final double leverage;
  final DateTime entryDate;
  bool isActive;

  MarginPosition({
    required this.id,
    required this.cryptoId,
    required this.amount,
    required this.entryPrice,
    required this.type,
    this.leverage = 1.0,
    required this.entryDate,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'cryptoId': cryptoId,
    'amount': amount,
    'entryPrice': entryPrice,
    'type': type.toString(),
    'leverage': leverage,
    'entryDate': entryDate.toIso8601String(),
    'isActive': isActive,
  };

  factory MarginPosition.fromJson(Map<String, dynamic> json) => MarginPosition(
    id: json['id'],
    cryptoId: json['cryptoId'] ?? json['coinId'],
    amount: json['amount'].toDouble(),
    entryPrice: json['entryPrice'].toDouble(),
    type: json['type'].toString().contains('short') ? PositionType.short : PositionType.long,
    leverage: (json['leverage'] ?? 1.0).toDouble(),
    entryDate: DateTime.parse(json['entryDate']),
    isActive: json['isActive'] ?? true,
  );

  double get collateral => amount;

  double calculatePnL(double currentPrice) {
    if (!isActive) return 0.0;
    // P/L = (Price Change / Entry Price) * Collateral * Leverage
    if (type == PositionType.short) {
      return (entryPrice - currentPrice) / entryPrice * amount * leverage;
    } else {
      return (currentPrice - entryPrice) / entryPrice * amount * leverage;
    }
  }
}

enum PositionType { long, short }


extension DynamicTimeExtension on GameStateProvider {
  /// Enable dynamic time mode and start time progression at 1x speed
  void enableDynamicTime() {
    _isDynamicTime = true;
    // If time speed is 0 (paused), set to 1x to actually start time
    if (_timeSpeed <= 0) {
      _timeSpeed = 1.0;
    }
    _startTimeProgression();
    notifyListeners();
  }
  
  /// Disable dynamic time mode (pauses time, shows Start button)
  void disableDynamicTime() {
    _isDynamicTime = false;
    _timeSpeed = 0;
    _timeProgressionTimer?.cancel();
    notifyListeners();
  }
  
  /// Return to present time - just changes date, doesn't reset game
  /// (Time arbitrage is prevented by disabling dynamic time first)
  void returnToPresent() {
    final now = DateTime.now();
    _gameDate = DateTime(now.year, now.month, now.day);
    _gameYear = now.year;
    _isDynamicTime = false;
    _timeSpeed = 0;
    _timeProgressionTimer?.cancel();
    
    // Clear arbitrage/positions when returning to present to prevent exploits
    _activePositions.clear();
    
    onDateChanged?.call(_gameDate);
    notifyListeners();
  }
  
  /// Reset game and start at Genesis (2009)
  Future<void> resetGameToGenesis() async {
    // Full reset
    // Start with $130 (Enough for first GPU - HD 5870 @ $120)
    _balance = 130.0; 
    
    // Circulating supply tracking (simulated global supply)
    _circulatingSupply = {
      'bitcoin': 0.0,
      'ethereum': 0.0,
      'dogecoin': 0.0,
      'litecoin': 0.0,
    };
    _holdings = {
      'bitcoin': 0.0,
      'ethereum': 0.0,
      'dogecoin': 0.0,
      'litecoin': 0.0,
    };
    _totalMined = {..._holdings};
    _gpus = [];
    _buildings = [];
    _clickPower = 1.0;
    _clickProgress = 0.0;
    _clickTarget = 100.0;
    _totalClicks = 0;
    _unlockedAchievements.clear();
    _activePositions.clear();
    
    // Reset Satoshi's Wallet
    _genesisWalletBalance = 0.0;
    _lastBlockMinedDate = null; // Reset click cooldown
    
    // Start at Genesis
    _gameDate = DateTime(2009, 1, 3);
    _gameYear = 2009;
    _isGenesisMode = true; // Enable Genesis logic
    _isDynamicTime = false;
    _timeSpeed = 0;
    
    _timeProgressionTimer?.cancel();
    
    _updateStats();
    
    onDateChanged?.call(_gameDate);
    notifyListeners();
  }
  
  /// Set time speed: 0 = paused, 1 = normal, 2 = 2x, 5 = 5x
  void setTimeSpeed(double speed) {
    if (_timeSpeed == speed) return; // Prevent redundant rebuilds/timer restarts
    _timeSpeed = speed;
    _startTimeProgression();
    
    notifyListeners();
  }
  
  /// Start the time progression timer
  void _startTimeProgression() {
    _timeProgressionTimer?.cancel();
    
    // Genesis Freeze: Time is frozen until Genesis Block is mined
    if (_isGenesisMode && (_totalMined['bitcoin'] ?? 0) < 50) {
      return; 
    }
    
    if (_timeSpeed <= 0) return;
    
    // Adjust interval based on speed
    // 1x = Normal speed (maybe 1 day every 10 seconds? or as requested?)
    // User wants: STOP, PLAY (normal), 1d/s, 3d/s, 5d/s
    // If speed is integer representing "days per second":
    Duration interval;
    if (_timeSpeed == 0.1) { // Let's use 0.1 for "Normal Play" (slow time)
       interval = const Duration(seconds: 5); // 1 day every 5 seconds
    } else {
       interval = Duration(milliseconds: (1000 / _timeSpeed).round());
    }
    
    _timeProgressionTimer = Timer.periodic(interval, (_) {
      _advanceGameTime();
    });
  }
  
  /// Advance game time by one day
  void _advanceGameTime() {
    // Simulate mining for this day (Time Warp)
    // We simulate 24 hours of mining in one go
    // For Solo Mining: We need to run the probability check X times
    // For Pool Mining: We just add 24h worth of earnings
    
    if (_isMining && _totalHashRate > 0) {
      _simulateDayOfMining();
      
      // Deduct Daily Power Cost (allow negative balance)
      _balance -= dailyPowerCost;
    }
    // Coin launch announcements
    _checkCoinLaunches();
    
    _gameDate = _gameDate.add(const Duration(days: 1));
    _gameYear = _gameDate.year;
    
    // Notify price provider to update prices
    onDateChanged?.call(_gameDate);
    
    // Check for market events
    _checkMarketEvents();
    
    // Check for feature unlocks
    _checkFeatureUnlocks();
    
    // Check achievements
    checkAchievements();
    
    notifyListeners();
  }
  
  /// Check if any features have been unlocked and announce them
  void _checkFeatureUnlocks() {
    // Trading unlock (Mt. Gox)
    if (isTradingAvailable && !_announcedFeatures.contains('trading')) {
      _announcedFeatures.add('trading');
      disableDynamicTime(); // Freeze time until user dismisses
      onFeatureUnlocked?.call('📈 Trading Unlocked!', 'Mt. Gox has launched on July 18, 2010. You can now buy and sell Bitcoin!');
    }
    
    // Pool mining unlock (Slush Pool)
    if (isPoolMiningAvailable && !_announcedFeatures.contains('pools')) {
      _announcedFeatures.add('pools');
      disableDynamicTime(); // Freeze time until user dismisses
      onFeatureUnlocked?.call('⛏️ Mining Pools Unlocked!', 'Slush Pool has launched on November 27, 2010. Join a pool for more consistent rewards!');
    }
  }

  /// Check if any new coins have launched
  void _checkCoinLaunches() {
    final coinLaunches = {
      // === 2011 ===
      'litecoin': ('🪙 Litecoin Launched!', 'Litecoin, the "silver to Bitcoin\'s gold," is now available to mine!', DateTime(2011, 10, 7)),
      // === 2012 ===
      'ripple': ('🌊 Ripple (XRP) Launched!', 'Ripple brings fast, low-cost international payments to crypto.', DateTime(2012, 9, 1)),
      // === 2013 ===
      'dogecoin': ('🐕 Dogecoin Launched!', 'Much coin. Very crypto. Wow. Dogecoin is now available!', DateTime(2013, 12, 6)),
      // === 2014 ===
      'dash': ('⚡ Dash Launched!', 'Dash (formerly Darkcoin) brings fast, private transactions.', DateTime(2014, 1, 18)),
      'monero': ('🔒 Monero Launched!', 'Monero brings privacy-focused cryptocurrency to the market.', DateTime(2014, 4, 18)),
      'tether': ('💵 Tether (USDT) Launched!', 'The first major stablecoin is here! 1 USDT = 1 USD.', DateTime(2014, 10, 6)),
      // === 2015 ===
      'ethereum': ('💎 Ethereum Launched!', 'Ethereum mainnet is live! Smart contracts are now possible.', DateTime(2015, 7, 30)),
      // === 2016 ===
      'ethereum-classic': ('⚙️ Ethereum Classic Launched!', 'ETC splits from ETH after The DAO hack. "Code is Law."', DateTime(2016, 7, 20)),
      'zcash': ('🔐 Zcash Launched!', 'Zcash brings zero-knowledge privacy to cryptocurrency.', DateTime(2016, 10, 28)),
      // === 2017 ===
      'cardano': ('🔬 Cardano (ADA) Launched!', 'Cardano brings peer-reviewed blockchain research to market.', DateTime(2017, 9, 29)),
      'chainlink': ('🔗 Chainlink (LINK) Launched!', 'Decentralized oracle network connects smart contracts to real-world data.', DateTime(2017, 9, 19)),
      // === 2018 ===
      'ravencoin': ('🐦 Ravencoin Launched!', 'Ravencoin enables asset transfers on blockchain.', DateTime(2018, 1, 3)),
      'flux': ('🌐 Flux Launched!', 'Flux brings decentralized cloud computing to crypto.', DateTime(2018, 9, 10)),
      // === 2020 ===
      'solana': ('☀️ Solana Launched!', 'Solana brings high-speed, low-cost transactions at scale.', DateTime(2020, 3, 16)),
    };
    
    for (final entry in coinLaunches.entries) {
      final coinId = entry.key;
      final title = entry.value.$1;
      final desc = entry.value.$2;
      final launchDate = entry.value.$3;
      
      final gameDateNormalized = DateTime(_gameDate.year, _gameDate.month, _gameDate.day);
      final launchDateNormalized = DateTime(launchDate.year, launchDate.month, launchDate.day);
      
      // Trigger on exact match OR if past and not yet announced
      final isLaunchDay = gameDateNormalized.isAtSameMomentAs(launchDateNormalized);
      final isPastLaunch = gameDateNormalized.isAfter(launchDateNormalized);
      
      // CRITICAL: We only announce if it's the LAUNCH DAY or if it's new.
      // If we load a save from 2024, we don't want 50 old announcements.
      // We check if it's within the same week to allow some buffer, but skip ancient history.
      final daysSinceLaunch = _gameDate.difference(launchDate).inDays;
      final isRecentLaunch = daysSinceLaunch >= 0 && daysSinceLaunch <= 7;

      final shouldAnnounce = (isLaunchDay || isRecentLaunch) && 
                             !_announcedFeatures.contains('coin_$coinId');
      
      if (shouldAnnounce) {
        _announcedFeatures.add('coin_$coinId');
        disableDynamicTime();
        onFeatureUnlocked?.call(title, desc);
        return; // Only one announcement per check to properly freeze time
      }
      
      // If it's ancient history, mark as announced without the popup
      if (isPastLaunch && !isRecentLaunch && !_announcedFeatures.contains('coin_$coinId')) {
         _announcedFeatures.add('coin_$coinId');
      }
    }
  }

  /// Process Prestige Reset
  void prestige(double pointsToGain) {
    if (pointsToGain <= 0) return;
    
    // 1. Update Prestige Data
    _prestigeData = _prestigeData.copyWith(
      prestigePoints: _prestigeData.prestigePoints + pointsToGain,
      prestigeLevel: _prestigeData.prestigeLevel + 1,
    );
    
    // 2. Calculate starting bonus from upgrades
    double startingCash = 1000.0;
    
    // Passive: Starting Cash upgrade
    final startingCashUpgrade = PrestigeUpgrades.getById('starting_cash');
    if (startingCashUpgrade != null) {
      final level = _prestigeData.upgradeLevels['starting_cash'] ?? 0;
      if (level > 0) {
        startingCash += (startingCashUpgrade.effectPerLevel * level);
      }
    }
    
    // 3. Reset Game (Store and restore prestige data)
    final savedPrestige = _prestigeData;
    
    // Reset to "Present Day" (standard reset) but with bonus cash
    // We manually reset internal state instead of calling resetGame to control exact state
    StorageService.deleteSave();
    _startNewGame();
    
    // Restore prestige
    _prestigeData = savedPrestige;
    _balance = startingCash;
    
    // 4. Reset Time to Present
    final now = DateTime.now();
    _gameDate = now;
    _gameYear = now.year;
    
    _updateStats();
    notifyListeners();
  }

  /// Simulate one day of mining (or portion thereof based on tick)
  /// Called by GameTimer
  void _simulateDayOfMining() {
      // Mining pools shouldn't update unless time is moving
      if (_timeSpeed <= 0) {
        return;
      }
      
      // Group miners
      final Map<String, double> hashRateByCoin = {};
      for (final miner in _gpus) {
        hashRateByCoin[miner.miningCoinId] = 
            (hashRateByCoin[miner.miningCoinId] ?? 0.0) + miner.hashRateInMHs;
      }
      
      if (hashRateByCoin.isEmpty) {
        return;
      }
      
      // Mine each coin
      hashRateByCoin.forEach((coinId, myHashRate) {
           final miningData = MiningDatabase.getMiningData(coinId);
           if (miningData == null || !miningData.isMineable) return;

           final maxS = GameStateProvider.maxSupplies[coinId] ?? double.infinity;
           final currentS = _circulatingSupply[coinId] ?? 0.0;
           
            // Global Supply Simulation for the day (Always 24 hours since we advance by 1 day)
            const double tickDurationSeconds = 86400.0; 
            
            final blockReward = miningData.getEffectiveBlockReward(_gameDate, coinId: coinId);
            final globalCoinsPerSec = blockReward / (miningData.blockTime > 0 ? miningData.blockTime : 600);
            final globalCoinsPerTick = globalCoinsPerSec * tickDurationSeconds;
           
           _circulatingSupply[coinId] = (currentS + globalCoinsPerTick).clamp(0.0, maxS).toDouble();

           if (_circulatingSupply[coinId]! >= maxS) return; // Stop if supply reached

           // Expected Coins Per Day calculation (Standard)
           final expectedDailyCoins = miningData.calculateCoinsPerDay(
               myHashRate, 
               gameDate: _gameDate, 
               coinId: coinId
           );
           
           if (expectedDailyCoins <= 0) return;

           // Pool Logic
           if (_currentPool.id == 'solo') {
              // PROBABILISTIC CHECK for a full day
              final fullBlockReward = miningData.getEffectiveBlockReward(_gameDate, coinId: coinId);
              final expectedBlocksPerDay = expectedDailyCoins / fullBlockReward;
              
              // Probability for the full day
              final probPerDay = expectedBlocksPerDay;
              
              // Simulate finding blocks based on probability for the day
              if (Random().nextDouble() < probPerDay) {
                int blocksFound = 1; // For simplicity, assume 1 block if probability hits
                double payout = blocksFound * fullBlockReward;
                
                // Normal Mining - Genesis Block/Rewward (Block 0) must be clicked manually
                _holdings[coinId] = (_holdings[coinId] ?? 0.0) + payout;
                _totalMined[coinId] = (_totalMined[coinId] ?? 0.0) + payout;
              }

           } else {
              // Pool Mining: Deterministic Stream for the full day
              double rawPayoutPerDay = expectedDailyCoins;
              
              // Apply Pool Fee
              double fee = rawPayoutPerDay * (_currentPool.feePercent / 100.0);
              double netPayout = rawPayoutPerDay - fee;
              
              if (coinId == _activeCrypto) {
                  _pendingPoolPayout += netPayout;
                  
                  // Check Payout Threshold
                  if (_pendingPoolPayout >= _currentPool.minPayoutCoins) {
                      _holdings[coinId] = (_holdings[coinId] ?? 0.0) + _pendingPoolPayout;
                      _totalMined[coinId] = (_totalMined[coinId] ?? 0.0) + _pendingPoolPayout;
                      _pendingPoolPayout = 0.0;
                  }
              } else {
                  // Background coins auto-pay
                  _holdings[coinId] = (_holdings[coinId] ?? 0.0) + netPayout;
                  _totalMined[coinId] = (_totalMined[coinId] ?? 0.0) + netPayout;
              }
           }
      });
  }

  /// Check for market events on current date
  void _checkMarketEvents() {
    // Check for events on EXACT current date 
    final events = MarketEvents.getEventsInRange(
      _gameDate,
      _gameDate,
    );
    
    for (final event in events) {
      // Use unique event key for persistence tracking (prevents duplicates across saves)
      final eventKey = 'event_${event.date.year}_${event.date.month}_${event.date.day}_${event.title.hashCode}';
      
      if (!_announcedFeatures.contains(eventKey)) {
        _announcedFeatures.add(eventKey);
        disableDynamicTime(); // Freeze time until user dismisses
        onMarketEvent?.call(event);
        
        // Only award event achievements if player started BEFORE the event
        final playerStartedBefore = _gameStartTime.isBefore(event.date);
        
        if (playerStartedBefore) {
          if (event.severity == 'negative') {
            _unlockAchievement('survive_crash');
          }
          if (event.title.toLowerCase().contains('halving')) {
            _unlockAchievement('witness_halving');
          }
        }
        return; // Only one event per check to properly freeze time
      }
    }
  }
  
  /// Jump to a specific date
  void jumpToDate(DateTime date) {
    _gameDate = date;
    _gameYear = date.year;
    notifyListeners();
  }

  /// Join a mining pool
  void joinPool(String poolId) {
    final pool = MiningPoolDatabase.getById(poolId);
    if (pool != null) {
      _currentPool = pool;
      _pendingPoolPayout = 0.0;
      
      // Achievement
      if (poolId != 'solo') {
        _unlockAchievement('join_pool');
      }
      
      notifyListeners();
    }
  }
  
  /// Leave current pool and go solo
  void leavePool() {
    // Payout pending before leaving
    if (_pendingPoolPayout > 0) {
      _balance += _pendingPoolPayout;
      _pendingPoolPayout = 0.0;
    }
    _currentPool = MiningPoolDatabase.solo;
    notifyListeners();
  }
  
  /// Add to pending pool payout
  void addPoolPayout(double amount) {
    final afterFee = _currentPool.calculatePayout(amount);
    _pendingPoolPayout += afterFee;
    
    // Check if meets minimum payout threshold
    final satoshis = (_pendingPoolPayout * 100000000).round();
    if (satoshis >= _currentPool.minPayoutCoins) {
      _balance += _pendingPoolPayout;
      _pendingPoolPayout = 0.0;
    }
    
    notifyListeners();
  }

  /// Check and unlock achievements based on current state
  void checkAchievements() {
    // Mining achievements
    if (_gpus.isNotEmpty) _unlockAchievement('first_gpu');
    if (_gpus.length >= 10) _unlockAchievement('ten_gpus');
    if (_gpus.any((g) => g.minerType == MinerType.asic)) _unlockAchievement('first_asic');
    
    // Wealth achievements
    if (_balance >= 10000) _unlockAchievement('balance_10k');
    if (_balance >= 100000) _unlockAchievement('balance_100k');
    if (_calculateNetWorth() >= 1000000) _unlockAchievement('millionaire');
    if (_calculateNetWorth() >= 1000000000) _unlockAchievement('billionaire');
    
    // Mining totals
    final btcMined = _totalMined['bitcoin'] ?? 0.0;
    if (btcMined >= 1.0) _unlockAchievement('mine_1_btc');
    if (btcMined >= 100.0) _unlockAchievement('mine_100_btc');
    
    // Genesis block achievement (mined 50 BTC in Genesis era = have genesis wallet balance)
    if (_genesisWalletBalance >= 50.0) _unlockAchievement('genesis_block');
    
    // First block (any block mined ever)
    if (_totalMined.values.any((v) => v > 0)) _unlockAchievement('first_block');
    
    // Hash rate
    if (_totalHashRate >= 1000) _unlockAchievement('hashrate_1gh'); // 1 GH/s
    if (_totalHashRate >= 1000000) _unlockAchievement('hashrate_1th'); // 1 TH/s
    
    // Trading
    if (_totalTrades >= 1) _unlockAchievement('first_trade');
    if (_holdings.keys.length >= 10) _unlockAchievement('hold_10_coins');
    
    // Clicks
    if (_totalClicks >= 1000) _unlockAchievement('click_1000');
    if (_totalClicks >= 100000) _unlockAchievement('click_100000');
    
    // Time - only if player actually played through 5 years
    final yearsPlayed = _gameDate.difference(_gameStartTime).inDays / 365;
    if (yearsPlayed >= 5) _unlockAchievement('hodl_5_years');
    
    // Location
    if (_currentLocation.id == 'datacenter') _unlockAchievement('datacenter');
  }
  
  /// Unlock a specific achievement
  void _unlockAchievement(String id) {
    if (!_unlockedAchievements.contains(id)) {
      _unlockedAchievements.add(id);
      
      final achievement = AchievementDatabase.getById(id);
      if (achievement != null) {
        onAchievementUnlocked?.call(achievement);
      }
      
      notifyListeners();
    }
  }
  
  /// Check if achievement is unlocked
  bool hasAchievement(String id) => _unlockedAchievements.contains(id);
  
  /// Get progress for an achievement (0.0 to 1.0)
  double getAchievementProgress(String id) {
    switch (id) {
      case 'ten_gpus':
        return (_gpus.length / 10).clamp(0.0, 1.0);
      case 'mine_1_btc':
        return ((_totalMined['bitcoin'] ?? 0) / 1.0).clamp(0.0, 1.0);
      case 'mine_100_btc':
        return ((_totalMined['bitcoin'] ?? 0) / 100.0).clamp(0.0, 1.0);
      case 'millionaire':
        return (_calculateNetWorth() / 1000000).clamp(0.0, 1.0);
      case 'click_1000':
        return (_totalClicks / 1000).clamp(0.0, 1.0);
      case 'click_100000':
        return (_totalClicks / 100000).clamp(0.0, 1.0);
      default:
        return hasAchievement(id) ? 1.0 : 0.0;
    }
  }


  /// Resume time after event
  void resumeTime() {
    _isDynamicTime = true;
    if (_timeSpeed <= 0) _timeSpeed = 1.0;
    _startTimeProgression();
    notifyListeners(); 
  }
}
