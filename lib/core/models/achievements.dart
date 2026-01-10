// Achievement system for Crypto Mining Empire
import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String category; // 'mining', 'trading', 'wealth', 'time', 'special'
  
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
  });
}

class AchievementDatabase {
  static const List<Achievement> all = achievements; // Alias for backwards compatibility
  
  static const List<Achievement> achievements = [
    // ===== MINING ACHIEVEMENTS =====
    Achievement(
      id: 'first_gpu',
      name: 'First Steps',
      description: 'Purchase your first GPU',
      icon: Icons.memory,
      color: Colors.green,
      category: 'mining',
    ),
    Achievement(
      id: 'ten_gpus',
      name: 'GPU Farm',
      description: 'Own 10 GPUs simultaneously',
      icon: Icons.developer_board,
      color: Colors.blue,
      category: 'mining',
    ),
    Achievement(
      id: 'first_asic',
      name: 'ASIC Miner',
      description: 'Purchase your first ASIC',
      icon: Icons.precision_manufacturing,
      color: Colors.purple,
      category: 'mining',
    ),
    Achievement(
      id: 'mine_1_btc',
      name: 'Whole Coiner',
      description: 'Mine 1 BTC total',
      icon: Icons.currency_bitcoin,
      color: Colors.orange,
      category: 'mining',
    ),
    Achievement(
      id: 'mine_100_btc',
      name: "Satoshi's Apprentice",
      description: 'Mine 100 BTC total',
      icon: Icons.workspace_premium,
      color: Colors.amber,
      category: 'mining',
    ),
    Achievement(
      id: 'hashrate_1gh',
      name: 'Gigahash Club',
      description: 'Reach 1 GH/s total hash rate',
      icon: Icons.speed,
      color: Colors.cyan,
      category: 'mining',
    ),
    Achievement(
      id: 'hashrate_1th',
      name: 'Terahash Titan',
      description: 'Reach 1 TH/s total hash rate',
      icon: Icons.rocket_launch,
      color: Colors.red,
      category: 'mining',
    ),
    Achievement(
      id: 'solo_block',
      name: 'Lucky Strike',
      description: 'Find a block while solo mining',
      icon: Icons.stars,
      color: Colors.yellow,
      category: 'mining',
    ),
    Achievement(
      id: 'join_pool',
      name: 'Pool Party',
      description: 'Join a mining pool',
      icon: Icons.groups,
      color: Colors.lightBlue,
      category: 'mining',
    ),
    
    // ===== WEALTH ACHIEVEMENTS =====
    Achievement(
      id: 'balance_10k',
      name: 'Five Figures',
      description: 'Accumulate \$10,000 cash',
      icon: Icons.attach_money,
      color: Colors.green,
      category: 'wealth',
    ),
    Achievement(
      id: 'balance_100k',
      name: 'Six Figures',
      description: 'Accumulate \$100,000 cash',
      icon: Icons.monetization_on,
      color: Colors.lightGreen,
      category: 'wealth',
    ),
    Achievement(
      id: 'millionaire',
      name: 'Crypto Millionaire',
      description: 'Reach \$1,000,000 net worth',
      icon: Icons.diamond,
      color: Colors.teal,
      category: 'wealth',
    ),
    Achievement(
      id: 'billionaire',
      name: 'Crypto Billionaire',
      description: 'Reach \$1,000,000,000 net worth',
      icon: Icons.castle,
      color: Colors.deepPurple,
      category: 'wealth',
    ),
    
    // ===== TRADING ACHIEVEMENTS =====
    Achievement(
      id: 'first_trade',
      name: 'Trader',
      description: 'Complete your first trade',
      icon: Icons.swap_horiz,
      color: Colors.blue,
      category: 'trading',
    ),
    Achievement(
      id: 'hold_10_coins',
      name: 'Diversified',
      description: 'Hold 10 different cryptocurrencies',
      icon: Icons.pie_chart,
      color: Colors.indigo,
      category: 'trading',
    ),
    
    // ===== TIME/EVENT ACHIEVEMENTS =====
    Achievement(
      id: 'genesis_block',
      name: 'Genesis',
      description: 'Mine the Genesis Block in 2009',
      icon: Icons.fingerprint,
      color: Colors.amber,
      category: 'time',
    ),
    Achievement(
      id: 'survive_crash',
      name: 'Crash Survivor',
      description: 'Experience a market crash event',
      icon: Icons.flash_on,
      color: Colors.red,
      category: 'time',
    ),
    Achievement(
      id: 'hodl_5_years',
      name: 'HODL Master',
      description: 'Play through 5 years of game time',
      icon: Icons.lock_clock,
      color: Colors.deepOrange,
      category: 'time',
    ),
    Achievement(
      id: 'witness_halving',
      name: 'Halving Witness',
      description: 'Experience a Bitcoin halving event',
      icon: Icons.content_cut,
      color: Colors.amber,
      category: 'time',
    ),
    
    // ===== CLICK/SPECIAL ACHIEVEMENTS =====
    Achievement(
      id: 'click_1000',
      name: 'Clicker',
      description: 'Click to mine 1,000 times',
      icon: Icons.touch_app,
      color: Colors.grey,
      category: 'special',
    ),
    Achievement(
      id: 'click_100000',
      name: 'Carpal Tunnel',
      description: 'Click to mine 100,000 times',
      icon: Icons.sports_esports,
      color: Colors.blueGrey,
      category: 'special',
    ),
    Achievement(
      id: 'datacenter',
      name: 'Data Center',
      description: 'Upgrade to a Data Center facility',
      icon: Icons.business,
      color: Colors.grey,
      category: 'special',
    ),
    Achievement(
      id: 'first_block',
      name: 'Block Found!',
      description: 'Successfully mine your first block',
      icon: Icons.view_in_ar,
      color: Colors.orange,
      category: 'mining',
    ),
  ];
  
  static Achievement? getById(String id) {
    try {
      return achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
  
  static List<Achievement> getByCategory(String category) {
    return achievements.where((a) => a.category == category).toList();
  }
}
