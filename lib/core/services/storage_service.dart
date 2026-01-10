import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Local storage service using Hive for save/load functionality
class StorageService {
  static late Box _gameBox;
  static const String _boxName = 'crypto_mining_empire';
  
  // Storage Keys
  static const String keyBalance = 'balance';
  static const String keyHoldings = 'holdings';
  static const String keyGPUs = 'gpus';
  static const String keyBuildings = 'buildings';
  static const String keyTotalMined = 'totalMined';
  static const String keyActiveCrypto = 'activeCrypto';
  static const String keyGameTime = 'gameTime';
  static const String keyLastSave = 'lastSave';
  static const String keyAchievements = 'achievements';
  static const String keySettings = 'settings';
  static const String keyGameDate = 'gameDate';
  static const String keyTimeSpeed = 'timeSpeed';
  static const String keyIsDynamicTime = 'isDynamicTime';
  static const String keyPositions = 'positions';
  // Genesis keys
  static const String keyGenesisWalletBalance = 'genesisWalletBalance';
  static const String keyIsGenesisMode = 'isGenesisMode';
  static const String keyUpgradeLevels = 'upgradeLevels'; // Also persisting upgrades while we are at it
  static const String keyAnnouncedFeatures = 'announcedFeatures';
  
  /// Initialize storage
  static Future<void> init() async {
    _gameBox = await Hive.openBox(_boxName);
  }
  
  /// Save game state
  static Future<void> saveGame(GameSaveData data) async {
    await _gameBox.put(keyBalance, data.balance);
    await _gameBox.put(keyHoldings, json.encode(data.holdings));
    await _gameBox.put(keyGPUs, json.encode(data.gpus));
    await _gameBox.put(keyBuildings, json.encode(data.buildings));
    await _gameBox.put(keyTotalMined, json.encode(data.totalMined));
    await _gameBox.put(keyActiveCrypto, data.activeCrypto);
    await _gameBox.put(keyGameTime, data.gameTime.toIso8601String());
    await _gameBox.put(keyLastSave, DateTime.now().toIso8601String());
    await _gameBox.put(keyAchievements, json.encode(data.achievements));
    await _gameBox.put(keyGameDate, data.gameDate.toIso8601String());
    await _gameBox.put(keyTimeSpeed, data.timeSpeed);
    await _gameBox.put(keyIsDynamicTime, data.isDynamicTime);
    await _gameBox.put(keyPositions, json.encode(data.positions));
    await _gameBox.put(keyGenesisWalletBalance, data.genesisWalletBalance);
    await _gameBox.put(keyIsGenesisMode, data.isGenesisMode);
    await _gameBox.put(keyUpgradeLevels, json.encode(data.upgradeLevels));
    await _gameBox.put(keyAnnouncedFeatures, json.encode(data.announcedFeatures));
  }
  
  /// Load game state
  static GameSaveData? loadGame() {
    try {
      final balance = _gameBox.get(keyBalance, defaultValue: 1000.0);
      final holdingsJson = _gameBox.get(keyHoldings);
      final gpusJson = _gameBox.get(keyGPUs);
      final buildingsJson = _gameBox.get(keyBuildings);
      final totalMinedJson = _gameBox.get(keyTotalMined);
      final activeCrypto = _gameBox.get(keyActiveCrypto, defaultValue: 'bitcoin');
      final gameTimeStr = _gameBox.get(keyGameTime);
      final achievementsJson = _gameBox.get(keyAchievements);
      final gameDateStr = _gameBox.get(keyGameDate);
      
      if (holdingsJson == null) return null; // No save file
      
      return GameSaveData(
        balance: balance,
        holdings: Map<String, double>.from(json.decode(holdingsJson)),
        gpus: (json.decode(gpusJson) as List).cast<Map<String, dynamic>>(),
        buildings: (json.decode(buildingsJson) as List).cast<Map<String, dynamic>>(),
        totalMined: Map<String, double>.from(json.decode(totalMinedJson)),
        activeCrypto: activeCrypto,
        gameTime: DateTime.parse(gameTimeStr),
        achievements: (json.decode(achievementsJson ?? '[]') as List).cast<String>(),
        gameDate: gameDateStr != null ? DateTime.parse(gameDateStr) : DateTime.now(),
        timeSpeed: _gameBox.get(keyTimeSpeed, defaultValue: 1.0),
        isDynamicTime: _gameBox.get(keyIsDynamicTime, defaultValue: false),

        positions: (json.decode(_gameBox.get(keyPositions, defaultValue: '[]')) as List).cast<Map<String, dynamic>>(),
        genesisWalletBalance: _gameBox.get(keyGenesisWalletBalance, defaultValue: 0.0),
        isGenesisMode: _gameBox.get(keyIsGenesisMode, defaultValue: false),
        upgradeLevels: Map<String, int>.from(json.decode(_gameBox.get(keyUpgradeLevels, defaultValue: '{}'))),
        announcedFeatures: (json.decode(_gameBox.get(keyAnnouncedFeatures, defaultValue: '[]')) as List).cast<String>(),
      );
    } catch (e) {
      print('Error loading game: $e');
      return null;
    }
  }
  
  /// Check if save file exists
  static bool hasSaveFile() {
    return _gameBox.containsKey(keyHoldings);
  }
  
  /// Delete save file
  static Future<void> deleteSave() async {
    await _gameBox.clear();
  }
  
  /// Save settings
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _gameBox.put(keySettings, json.encode(settings));
  }
  
  /// Load settings
  static Map<String, dynamic> loadSettings() {
    final settingsJson = _gameBox.get(keySettings);
    if (settingsJson == null) {
      return {
        'soundEnabled': true,
        'musicEnabled': true,
        'notificationsEnabled': true,
        'autoSave': true,
      };
    }
    return Map<String, dynamic>.from(json.decode(settingsJson));
  }
}

/// Game save data model
class GameSaveData {
  final double balance;
  final Map<String, double> holdings;
  final List<Map<String, dynamic>> gpus;
  final List<Map<String, dynamic>> buildings;
  final Map<String, double> totalMined;
  final String activeCrypto;
  final DateTime gameTime;
  final List<String> achievements;
  final DateTime gameDate;
  final double timeSpeed;
  final bool isDynamicTime;
  final List<Map<String, dynamic>> positions;
  final double genesisWalletBalance;
  final bool isGenesisMode;
  final Map<String, int> upgradeLevels;
  final List<String> announcedFeatures;
  
  GameSaveData({
    required this.balance,
    required this.holdings,
    required this.gpus,
    required this.buildings,
    required this.totalMined,
    required this.activeCrypto,
    required this.gameTime,
    required this.achievements,
    required this.gameDate,
    required this.timeSpeed,
    required this.isDynamicTime,
    required this.positions,
    required this.genesisWalletBalance,
    required this.isGenesisMode,
    required this.upgradeLevels,
    required this.announcedFeatures,
  });
}
