import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../providers/game_state_provider.dart';

/// Shop screen for purchasing GPUs and buildings
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SHOP'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: CyberpunkTheme.primaryBlue,
          labelColor: CyberpunkTheme.primaryBlue,
          unselectedLabelColor: CyberpunkTheme.textTertiary,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'GPUs'),
            Tab(text: 'BUILDINGS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GPUShopTab(),
          BuildingShopTab(),
        ],
      ),
    );
  }
}

/// GPU Shop Tab
class GPUShopTab extends StatelessWidget {
  const GPUShopTab({super.key});
  
  static final List<Map<String, dynamic>> gpus = [
    {'name': 'Basic GPU', 'cost': 100, 'hashRate': 50, 'power': 50, 'emoji': '🖥️'},
    {'name': 'Gaming GPU', 'cost': 500, 'hashRate': 250, 'power': 150, 'emoji': '🎮'},
    {'name': 'Mining GPU', 'cost': 2000, 'hashRate': 1000, 'power': 300, 'emoji': '⚡'},
    {'name': 'Pro Miner', 'cost': 5000, 'hashRate': 2500, 'power': 600, 'emoji': '💎'},
    {'name': 'ASIC S19', 'cost': 10000, 'hashRate': 5000, 'power': 1500, 'emoji': '🚀'},
    {'name': 'ASIC S19 Pro', 'cost': 25000, 'hashRate': 12500, 'power': 3000, 'emoji': '⭐'},
    {'name': 'Quantum Miner', 'cost': 100000, 'hashRate': 50000, 'power': 5000, 'emoji': '🌟'},
  ];

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: gpus.length,
      itemBuilder: (context, index) {
        final gpu = gpus[index];
        return _ShopItemCard(
          name: gpu['name'],
          emoji: gpu['emoji'] ?? '⛏️',
          cost: gpu['cost'].toDouble(),
          stats: [
            {'label': 'Hash Rate', 'value': '${gpu['hashRate']} MH/s', 'icon': Icons.speed},
            {'label': 'Power', 'value': '${gpu['power']} W', 'icon': Icons.power},
          ],
          onPurchase: () {
            final gpuItem = GPU(
              name: gpu['name'],
              cost: gpu['cost'].toDouble(),
              hashRate: gpu['hashRate'].toDouble(),
              powerWatts: gpu['power'].toDouble(),
            );
            
            if (gameState.purchaseGPU(gpuItem)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Purchased ${gpu['name']}!'),
                  backgroundColor: CyberpunkTheme.accentGreen,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Insufficient funds!'),
                  backgroundColor: CyberpunkTheme.accentOrange,
                ),
              );
            }
          },
          canAfford: gameState.balance >= gpu['cost'],
        );
      },
    );
  }
}

/// Building Shop Tab
class BuildingShopTab extends StatelessWidget {
  const BuildingShopTab({super.key});
  
  static final List<Map<String, dynamic>> buildings = [
    {'name': 'Small Warehouse', 'cost': 5000, 'discount': 10, 'emoji': '🏠'},
    {'name': 'Large Warehouse', 'cost': 25000, 'discount': 20, 'emoji': '🏢'},
    {'name': 'Industrial Complex', 'cost': 100000, 'discount': 30, 'emoji': '🏭'},
    {'name': 'Data Center', 'cost': 500000, 'discount': 50, 'emoji': '🏗️'},
    {'name': 'Mega Facility', 'cost': 2000000, 'discount': 70, 'emoji': '🌆'},
  ];

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: buildings.length,
      itemBuilder: (context, index) {
        final building = buildings[index];
        final powerMultiplier = 1.0 - (building['discount'] / 100.0);
        
        return _ShopItemCard(
          name: building['name'],
          emoji: building['emoji'] ?? '🏢',
          cost: building['cost'].toDouble(),
          stats: [
            {'label': 'Power Discount', 'value': '${building['discount']}%', 'icon': Icons.discount},
            {'label': 'Multiplier', 'value': '${powerMultiplier.toStringAsFixed(2)}x', 'icon': Icons.trending_down},
          ],
          onPurchase: () {
            final buildingItem = Building(
              name: building['name'],
              cost: building['cost'].toDouble(),
              powerMultiplier: powerMultiplier,
            );
            
            if (gameState.purchaseBuilding(buildingItem)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Purchased ${building['name']}!'),
                  backgroundColor: CyberpunkTheme.accentGreen,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Insufficient funds!'),
                  backgroundColor: CyberpunkTheme.accentOrange,
                ),
              );
            }
          },
          canAfford: gameState.balance >= building['cost'],
        );
      },
    );
  }
}

/// Shop Item Card Widget
class _ShopItemCard extends StatelessWidget {
  final String name;
  final String emoji;
  final double cost;
  final List<Map<String, dynamic>> stats;
  final VoidCallback onPurchase;
  final bool canAfford;
  
  const _ShopItemCard({
    required this.name,
    required this.emoji,
    required this.cost,
    required this.stats,
    required this.onPurchase,
    required this.canAfford,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: CyberpunkTheme.modernCard(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CyberpunkTheme.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '\$${cost.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CyberpunkTheme.accentOrange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            ...stats.map((stat) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(stat['icon'], size: 16, color: CyberpunkTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    '${stat['label']}: ',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: CyberpunkTheme.textTertiary,
                    ),
                  ),
                  Text(
                    stat['value'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CyberpunkTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            )).toList(),
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canAfford ? onPurchase : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford ? CyberpunkTheme.accentGreen : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  canAfford ? 'PURCHASE' : 'INSUFFICIENT FUNDS',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
