// Prestige system - Reset for permanent multipliers
import 'dart:math';

class PrestigeData {
  final int prestigeLevel;
  final double prestigePoints;
  final Map<String, int> upgradeLevels;
  
  const PrestigeData({
    this.prestigeLevel = 0,
    this.prestigePoints = 0,
    this.upgradeLevels = const {},
  });
  
  PrestigeData copyWith({
    int? prestigeLevel,
    double? prestigePoints,
    Map<String, int>? upgradeLevels,
  }) {
    return PrestigeData(
      prestigeLevel: prestigeLevel ?? this.prestigeLevel,
      prestigePoints: prestigePoints ?? this.prestigePoints,
      upgradeLevels: upgradeLevels ?? this.upgradeLevels,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'prestigeLevel': prestigeLevel,
    'prestigePoints': prestigePoints,
    'upgradeLevels': upgradeLevels,
  };
  
  factory PrestigeData.fromJson(Map<String, dynamic> json) {
    return PrestigeData(
      prestigeLevel: json['prestigeLevel'] ?? 0,
      prestigePoints: (json['prestigePoints'] ?? 0).toDouble(),
      upgradeLevels: Map<String, int>.from(json['upgradeLevels'] ?? {}),
    );
  }
}

class PrestigeUpgrade {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int maxLevel;
  final double baseCost;
  final double costMultiplier;
  final double effectPerLevel;
  final String effectType; // 'click', 'mining', 'trading', 'passive'
  
  const PrestigeUpgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.maxLevel,
    required this.baseCost,
    required this.costMultiplier,
    required this.effectPerLevel,
    required this.effectType,
  });
  
  double getCost(int currentLevel) {
    return baseCost * pow(costMultiplier, currentLevel);
  }
  
  double getEffect(int level) {
    return 1.0 + (effectPerLevel * level);
  }
}

class PrestigeUpgrades {
  static const List<PrestigeUpgrade> all = [
    // Click upgrades
    PrestigeUpgrade(
      id: 'click_power',
      name: 'Click Mastery',
      description: '+25% click power per level',
      icon: '👆',
      maxLevel: 10,
      baseCost: 1,
      costMultiplier: 2,
      effectPerLevel: 0.25,
      effectType: 'click',
    ),
    PrestigeUpgrade(
      id: 'click_crit',
      name: 'Critical Clicks',
      description: '+5% critical click chance per level',
      icon: '💥',
      maxLevel: 10,
      baseCost: 2,
      costMultiplier: 2.5,
      effectPerLevel: 0.05,
      effectType: 'click',
    ),
    
    // Mining upgrades
    PrestigeUpgrade(
      id: 'mining_speed',
      name: 'Mining Efficiency',
      description: '+20% mining speed per level',
      icon: '⛏️',
      maxLevel: 10,
      baseCost: 2,
      costMultiplier: 2,
      effectPerLevel: 0.20,
      effectType: 'mining',
    ),
    PrestigeUpgrade(
      id: 'gpu_discount',
      name: 'Hardware Deals',
      description: '-10% GPU cost per level',
      icon: '💰',
      maxLevel: 5,
      baseCost: 3,
      costMultiplier: 3,
      effectPerLevel: 0.10,
      effectType: 'mining',
    ),
    
    // Trading upgrades
    PrestigeUpgrade(
      id: 'trade_bonus',
      name: 'Trade Intuition',
      description: '+5% bonus on all trades per level',
      icon: '📈',
      maxLevel: 10,
      baseCost: 2,
      costMultiplier: 2.5,
      effectPerLevel: 0.05,
      effectType: 'trading',
    ),
    PrestigeUpgrade(
      id: 'market_insight',
      name: 'Market Insight',
      description: '+10% sell value per level',
      icon: '🔮',
      maxLevel: 5,
      baseCost: 5,
      costMultiplier: 3,
      effectPerLevel: 0.10,
      effectType: 'trading',
    ),
    
    // Passive upgrades
    PrestigeUpgrade(
      id: 'starting_cash',
      name: 'Trust Fund',
      description: '+\$1000 starting cash per level',
      icon: '💵',
      maxLevel: 10,
      baseCost: 1,
      costMultiplier: 1.5,
      effectPerLevel: 1000,
      effectType: 'passive',
    ),
    PrestigeUpgrade(
      id: 'time_warp',
      name: 'Time Warp',
      description: '+1x max time speed per level',
      icon: '⏩',
      maxLevel: 5,
      baseCost: 10,
      costMultiplier: 5,
      effectPerLevel: 1,
      effectType: 'passive',
    ),
  ];
  
  static PrestigeUpgrade? getById(String id) {
    try {
      return all.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Calculate prestige points earned based on net worth
double calculatePrestigePoints(double netWorth) {
  if (netWorth < 100000) return 0;
  // Formula: sqrt(netWorth / 100000) - diminishing returns
  return sqrt(netWorth / 100000);
}
