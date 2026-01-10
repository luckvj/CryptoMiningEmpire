// Daily challenges system
import 'dart:math';

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String type; // 'mine', 'trade', 'click', 'balance', 'buy'
  final double target;
  final double reward;
  final String rewardType; // 'cash', 'multiplier', 'boost'
  double progress;
  bool completed;
  
  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.reward,
    required this.rewardType,
    this.progress = 0,
    this.completed = false,
  });
  
  double get progressPercent => (progress / target).clamp(0.0, 1.0);
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'target': target,
    'progress': progress,
    'completed': completed,
  };
  
  factory DailyChallenge.fromJson(Map<String, dynamic> json, DailyChallenge template) {
    return DailyChallenge(
      id: template.id,
      title: template.title,
      description: template.description,
      type: template.type,
      target: template.target,
      reward: template.reward,
      rewardType: template.rewardType,
      progress: (json['progress'] ?? 0).toDouble(),
      completed: json['completed'] ?? false,
    );
  }
}

class DailyChallengesDatabase {
  static final Random _random = Random();
  
  static final List<DailyChallenge> _templates = [
    // Mining challenges
    DailyChallenge(
      id: 'mine_btc_001',
      title: 'Bitcoin Miner',
      description: 'Mine 0.001 BTC today',
      type: 'mine_btc',
      target: 0.001,
      reward: 500,
      rewardType: 'cash',
    ),
    DailyChallenge(
      id: 'mine_any_01',
      title: 'Active Miner',
      description: 'Mine any \$100 worth of crypto',
      type: 'mine_value',
      target: 100,
      reward: 200,
      rewardType: 'cash',
    ),
    
    // Trading challenges
    DailyChallenge(
      id: 'trade_5',
      title: 'Day Trader',
      description: 'Complete 5 trades',
      type: 'trades',
      target: 5,
      reward: 1000,
      rewardType: 'cash',
    ),
    DailyChallenge(
      id: 'trade_profit',
      title: 'Profitable Trader',
      description: 'Make \$500 profit from trades',
      type: 'trade_profit',
      target: 500,
      reward: 750,
      rewardType: 'cash',
    ),
    
    // Click challenges
    DailyChallenge(
      id: 'click_100',
      title: 'Clicker',
      description: 'Click to mine 100 times',
      type: 'clicks',
      target: 100,
      reward: 100,
      rewardType: 'cash',
    ),
    DailyChallenge(
      id: 'click_500',
      title: 'Click Master',
      description: 'Click to mine 500 times',
      type: 'clicks',
      target: 500,
      reward: 500,
      rewardType: 'cash',
    ),
    
    // Balance challenges
    DailyChallenge(
      id: 'earn_1k',
      title: 'Money Maker',
      description: 'Earn \$1,000 today',
      type: 'daily_earnings',
      target: 1000,
      reward: 300,
      rewardType: 'cash',
    ),
    
    // Hardware challenges
    DailyChallenge(
      id: 'buy_gpu',
      title: 'Hardware Upgrade',
      description: 'Buy a new GPU',
      type: 'buy_gpu',
      target: 1,
      reward: 250,
      rewardType: 'cash',
    ),
  ];
  
  /// Generate 3 random daily challenges
  static List<DailyChallenge> generateDailyChallenges() {
    final shuffled = List<DailyChallenge>.from(_templates)..shuffle(_random);
    return shuffled.take(3).map((template) => DailyChallenge(
      id: '${template.id}_${DateTime.now().day}',
      title: template.title,
      description: template.description,
      type: template.type,
      target: template.target,
      reward: template.reward,
      rewardType: template.rewardType,
    )).toList();
  }
}

class DailyLoginReward {
  final int day;
  final double cashReward;
  final String? bonusType;
  final double? bonusValue;
  
  const DailyLoginReward({
    required this.day,
    required this.cashReward,
    this.bonusType,
    this.bonusValue,
  });
}

class DailyLoginRewards {
  static const List<DailyLoginReward> week = [
    DailyLoginReward(day: 1, cashReward: 100),
    DailyLoginReward(day: 2, cashReward: 200),
    DailyLoginReward(day: 3, cashReward: 300),
    DailyLoginReward(day: 4, cashReward: 500),
    DailyLoginReward(day: 5, cashReward: 750, bonusType: 'boost', bonusValue: 2.0),
    DailyLoginReward(day: 6, cashReward: 1000),
    DailyLoginReward(day: 7, cashReward: 2500, bonusType: 'gpu_discount', bonusValue: 0.10),
  ];
  
  static DailyLoginReward getRewardForDay(int consecutiveDays) {
    final dayIndex = ((consecutiveDays - 1) % 7);
    return week[dayIndex];
  }
}
