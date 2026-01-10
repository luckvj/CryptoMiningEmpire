/// Upgrades tree for MH-based click mining system
import 'dart:math';

class GameUpgrade {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category; // 'click', 'efficiency', 'automation', 'special'
  final int maxLevel;
  final double baseCost;
  final double costMultiplier;
  final double effectPerLevel;
  final List<String> requirements; // Upgrade IDs required
  final String? imageAsset; // Optional image path
  
  const GameUpgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.maxLevel,
    required this.baseCost,
    required this.costMultiplier,
    required this.effectPerLevel,
    this.requirements = const [],
    this.imageAsset,
  });
  
  double getCost(int level) => baseCost * pow(costMultiplier, level);
  double getEffect(int level) => effectPerLevel * level;
  
  /// Get human-readable requirement text
  String? getRequirementText() {
    if (requirements.isEmpty) return null;
    final names = requirements.map((id) {
      final upgrade = UpgradesDatabase.getById(id);
      return upgrade?.name ?? id;
    }).join(', ');
    return 'Requires: $names';
  }
}

class UpgradesDatabase {
  static const List<GameUpgrade> all = [
    // ===== CLICK UPGRADES (MH-based) =====
    GameUpgrade(
      id: 'basic_hashpower',
      name: 'Basic Hashpower',
      description: '+5 MH/s per tap',
      icon: '⚡',
      category: 'click',
      maxLevel: 25,
      baseCost: 50,
      costMultiplier: 1.2,
      effectPerLevel: 5.0, // +5 MH/s
    ),
    GameUpgrade(
      id: 'enhanced_clicking',
      name: 'Enhanced Clicking',
      description: '+10 MH/s per tap',
      icon: '💪',
      category: 'click',
      maxLevel: 20,
      baseCost: 200,
      costMultiplier: 1.3,
      effectPerLevel: 10.0, // +10 MH/s
      requirements: ['basic_hashpower'], // Level 5 implied
    ),
    GameUpgrade(
      id: 'power_taps',
      name: 'Power Taps',
      description: '+25 MH/s per tap',
      icon: '🔥',
      category: 'click',
      maxLevel: 15,
      baseCost: 1000,
      costMultiplier: 1.4,
      effectPerLevel: 25.0, // +25 MH/s
      requirements: ['enhanced_clicking'],
    ),
    GameUpgrade(
      id: 'turbo_clicks',
      name: 'Turbo Clicks',
      description: '+50 MH/s per tap',
      icon: '🚀',
      category: 'click',
      maxLevel: 10,
      baseCost: 5000,
      costMultiplier: 1.5,
      effectPerLevel: 50.0, // +50 MH/s
      requirements: ['power_taps'],
    ),
    GameUpgrade(
      id: 'mega_hashpower',
      name: 'Mega Hashpower',
      description: '+100 MH/s per tap',
      icon: '⚡',
      category: 'click',
      maxLevel: 5,
      baseCost: 25000,
      costMultiplier: 2.0,
      effectPerLevel: 100.0, // +100 MH/s
      requirements: ['turbo_clicks'],
    ),
    
    // ===== EFFICIENCY UPGRADES =====
    GameUpgrade(
      id: 'overclock',
      name: 'Overclock GPUs',
      description: '+5% mining hash rate',
      icon: '🔧',
      category: 'efficiency',
      maxLevel: 20,
      baseCost: 500,
      costMultiplier: 1.4,
      effectPerLevel: 0.05,
    ),
    GameUpgrade(
      id: 'power_save',
      name: 'Power Optimization',
      description: '-5% electricity cost',
      icon: '🔋',
      category: 'efficiency',
      maxLevel: 15,
      baseCost: 750,
      costMultiplier: 1.5,
      effectPerLevel: 0.05,
    ),
    GameUpgrade(
      id: 'cooling',
      name: 'Advanced Cooling',
      description: '+10% GPU efficiency',
      icon: '❄️',
      category: 'efficiency',
      maxLevel: 10,
      baseCost: 2000,
      costMultiplier: 1.8,
      effectPerLevel: 0.10,
      requirements: ['overclock'],
    ),
    GameUpgrade(
      id: 'progress_boost',
      name: 'Progress Accelerator',
      description: '-5% progress bar requirement',
      icon: '📊',
      category: 'efficiency',
      maxLevel: 10,
      baseCost: 3000,
      costMultiplier: 1.6,
      effectPerLevel: 0.05, // Reduces click target
    ),
    
    // ===== AUTOMATION UPGRADES =====
    GameUpgrade(
      id: 'passive_mining',
      name: 'Passive Mining',
      description: '+1 MH/s passive mining',
      icon: '🤖',
      category: 'automation',
      maxLevel: 20,
      baseCost: 1000,
      costMultiplier: 1.5,
      effectPerLevel: 1.0, // MH/s passive
    ),
    GameUpgrade(
      id: 'auto_progress',
      name: 'Auto Progress',
      description: '+2% progress per second',
      icon: '⚙️',
      category: 'automation',
      maxLevel: 10,
      baseCost: 5000,
      costMultiplier: 2.0,
      effectPerLevel: 0.02, // 2% of target per sec
      requirements: ['passive_mining'],
    ),
    GameUpgrade(
      id: 'mining_bot',
      name: 'Mining Bot',
      description: 'Automatic taps (+5 MH/s/sec)',
      icon: '🤖',
      category: 'automation',
      maxLevel: 15,
      baseCost: 10000,
      costMultiplier: 1.8,
      effectPerLevel: 5.0, // MH/s per second auto
      requirements: ['auto_progress'],
    ),
    
    // ===== SPECIAL UPGRADES =====
    GameUpgrade(
      id: 'cooldown_reducer',
      name: 'Cooldown Reducer',
      description: '-20% block cooldown time',
      icon: '⏱️',
      category: 'special',
      maxLevel: 5,
      baseCost: 15000,
      costMultiplier: 2.5,
      effectPerLevel: 0.20, // 20% reduction
    ),
    GameUpgrade(
      id: 'double_block',
      name: 'Double Block Chance',
      description: '+2% chance for double reward',
      icon: '🎰',
      category: 'special',
      maxLevel: 10,
      baseCost: 20000,
      costMultiplier: 2.0,
      effectPerLevel: 0.02, // 2% per level
      requirements: ['cooldown_reducer'],
    ),
    GameUpgrade(
      id: 'whale_radar',
      name: 'Whale Radar',
      description: 'Get alerts for market movements',
      icon: '🐋',
      category: 'special',
      maxLevel: 1,
      baseCost: 50000,
      costMultiplier: 1,
      effectPerLevel: 1,
    ),
  ];
  
  static GameUpgrade? getById(String id) {
    try {
      return all.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }
  
  static List<GameUpgrade> getByCategory(String category) {
    return all.where((u) => u.category == category).toList();
  }
}
