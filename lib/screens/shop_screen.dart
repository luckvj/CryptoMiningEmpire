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
    // Entry Level GPUs - Real Hashrates for Ethash Mining
    {
      'name': 'NVIDIA GTX 1660 Super',
      'cost': 180,
      'hashRate': 31.5, // Real Ethash: ~31.5 MH/s
      'power': 125,
      'emoji': '🔰',
      'description': 'Budget-friendly entry GPU',
      'tier': 'Entry',
      'imageUrl': 'https://images.unsplash.com/photo-1591488320449-011701bb6704?w=800&q=80',
      'manufacturer': 'NVIDIA'
    },
    {
      'name': 'AMD RX 580 8GB',
      'cost': 140,
      'hashRate': 31.0, // Real Ethash: ~31 MH/s (optimized)
      'power': 185,
      'emoji': '🔰',
      'description': 'Classic mining card',
      'tier': 'Entry',
      'imageUrl': 'https://images.unsplash.com/photo-1587202372634-32705e3bf49c?w=800&q=80',
      'manufacturer': 'AMD'
    },
    {
      'name': 'NVIDIA RTX 3060',
      'cost': 299,
      'hashRate': 49.0, // Real Ethash: ~49 MH/s (LHR unlocked)
      'power': 170,
      'emoji': '⚡',
      'description': 'Solid mid-range performer',
      'tier': 'Mid-Range',
      'imageUrl': 'https://images.unsplash.com/photo-1562976540-1502c2145186?w=800&q=80',
      'manufacturer': 'NVIDIA'
    },
    {
      'name': 'NVIDIA RTX 3060 Ti',
      'cost': 399,
      'hashRate': 60.0, // Real Ethash: ~60 MH/s
      'power': 200,
      'emoji': '⚡',
      'description': 'Excellent efficiency',
      'tier': 'Mid-Range',
      'imageUrl': 'https://images.unsplash.com/photo-1555617981-dac3880eac6e?w=800&q=80',
      'manufacturer': 'NVIDIA'
    },
    {
      'name': 'NVIDIA RTX 3070',
      'cost': 499,
      'hashRate': 62.0, // Real Ethash: ~62 MH/s
      'power': 220,
      'emoji': '💪',
      'description': 'High performance mining',
      'tier': 'High-End',
      'imageUrl': 'https://images.unsplash.com/photo-1602524206684-dadbf7dfbe68?w=800&q=80',
      'manufacturer': 'NVIDIA'
    },
    {
      'name': 'AMD RX 6800 XT',
      'cost': 549,
      'hashRate': 64.0, // Real Ethash: ~64 MH/s
      'power': 300,
      'emoji': '💪',
      'description': 'AMD high-end competitor',
      'tier': 'High-End',
      'imageUrl': 'https://images.unsplash.com/photo-1591799264318-7e6ef8ddb7ea?w=800&q=80',
      'manufacturer': 'AMD'
    },
    {
      'name': 'NVIDIA RTX 3080',
      'cost': 699,
      'hashRate': 99.0, // Real Ethash: ~99 MH/s
      'power': 320,
      'emoji': '💪',
      'description': 'Enthusiast mining card',
      'tier': 'High-End',
      'imageUrl': 'https://images.unsplash.com/photo-1600861194942-f883fe6d936c?w=800&q=80',
      'manufacturer': 'NVIDIA'
    },
    {
      'name': 'NVIDIA RTX 3090',
      'cost': 999,
      'hashRate': 121.0, // Real Ethash: ~121 MH/s
      'power': 350,
      'emoji': '🔥',
      'description': 'Top-tier gaming GPU',
      'tier': 'Ultra',
      'imageUrl': 'https://images.unsplash.com/photo-1587202372583-49330a15584d?w=800&q=80',
      'manufacturer': 'NVIDIA'
    },
    // RTX 40 Series (Latest Gen - 2024-2026)
    {
      'name': 'NVIDIA RTX 4070',
      'cost': 599,
      'hashRate': 68.0, // Real Ethash equivalent: ~68 MH/s
      'power': 200,
      'emoji': '⚡',
      'description': 'Efficient next-gen',
      'tier': 'High-End',
      'imageUrl': 'https://images.unsplash.com/photo-1618472609823-2f2bc2c5d0e2?w=800&q=80',
      'manufacturer': 'NVIDIA'
    },
    {
      'name': 'NVIDIA RTX 4070 Ti',
      'cost': 799,
      'hashRate': 84.0, // Real Ethash equivalent: ~84 MH/s
      'power': 285,
      'emoji': '💎',
      'description': 'Ti performance boost',
      'tier': 'Ultra',
      'imageUrl': 'https://images.unsplash.com/photo-1622297845775-5ff3fef71d13?w=800&q=80',
      'manufacturer': 'NVIDIA'
    },
    {
      'name': 'NVIDIA RTX 4080',
      'cost': 1199,
      'hashRate': 103.0, // Real Ethash equivalent: ~103 MH/s
      'power': 320,
      'emoji': '💎',
      'description': 'Powerful 40-series',
      'tier': 'Ultra',
      'imageUrl': 'https://images.unsplash.com/photo-1612528443702-f6741f70a049?w=800&q=80',
      'manufacturer': 'NVIDIA'
    },
    {
      'name': 'NVIDIA RTX 4090',
      'cost': 1599,
      'hashRate': 133.0, // Real Ethash equivalent: ~133 MH/s
      'power': 450,
      'emoji': '👑',
      'description': 'Flagship GPU',
      'tier': 'Ultimate',
      'imageUrl': 'https://images.unsplash.com/photo-1625948515291-69613efd103f?w=800&q=80',
      'manufacturer': 'NVIDIA'
    },
    // AMD High-End (Latest - 2024)
    {
      'name': 'AMD RX 7900 XTX',
      'cost': 899,
      'hashRate': 95.0, // Real Ethash equivalent: ~95 MH/s
      'power': 355,
      'emoji': '🔴',
      'description': 'AMD flagship',
      'tier': 'Ultra',
      'imageUrl': 'https://images.unsplash.com/photo-1591405351990-4726e331f141?w=800&q=80',
      'manufacturer': 'AMD'
    },
    // Professional Mining Hardware (ASIC - Real Market Prices 2024-2026)
    {
      'name': 'Antminer S19 Pro',
      'cost': 2200,
      'hashRate': 110000,
      'power': 3250,
      'emoji': '🏭',
      'description': 'Bitcoin ASIC miner (110 TH/s)',
      'tier': 'ASIC',
      'isASIC': true,
      'imageUrl': 'https://m.media-amazon.com/images/I/61h8eQ8NVNL._AC_SL1500_.jpg',
      'manufacturer': 'Bitmain'
    },
    {
      'name': 'Antminer S19 XP',
      'cost': 3800,
      'hashRate': 140000,
      'power': 3010,
      'emoji': '🚀',
      'description': 'Latest Bitcoin ASIC (140 TH/s)',
      'tier': 'ASIC',
      'isASIC': true,
      'imageUrl': 'https://m.media-amazon.com/images/I/61h8eQ8NVNL._AC_SL1500_.jpg',
      'manufacturer': 'Bitmain'
    },
    {
      'name': 'Whatsminer M30S++',
      'cost': 2500,
      'hashRate': 112000,
      'power': 3472,
      'emoji': '⚙️',
      'description': 'High-efficiency ASIC (112 TH/s)',
      'tier': 'ASIC',
      'isASIC': true,
      'imageUrl': 'https://m.media-amazon.com/images/I/61xBp2zKCYL._AC_SL1500_.jpg',
      'manufacturer': 'MicroBT'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: gpus.length,
      itemBuilder: (context, index) {
        final gpu = gpus[index];
        final hashRate = gpu['hashRate'].toDouble();
        final power = gpu['power'].toDouble();
        final efficiency = hashRate / power; // MH/W
        final efficiencyRating = efficiency >= 0.30 ? '⭐⭐⭐' : efficiency >= 0.25 ? '⭐⭐' : '⭐';
        
        return _ShopItemCard(
          name: gpu['name'],
          emoji: gpu['emoji'] ?? '⛏️',
          imageUrl: gpu['imageUrl'],
          cost: gpu['cost'].toDouble(),
          description: gpu['description'],
          tier: gpu['tier'],
          stats: [
            {'label': 'Hash Rate', 'value': '${gpu['hashRate']} MH/s', 'icon': Icons.speed},
            {'label': 'Power', 'value': '${gpu['power']} W', 'icon': Icons.power},
            {'label': 'Efficiency', 'value': '${efficiency.toStringAsFixed(2)} MH/W', 'icon': Icons.eco, 'rating': efficiencyRating},
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
    {
      'name': 'Home Garage Setup',
      'cost': 500,
      'discount': 5,
      'emoji': '🏠',
      'description': 'Start small with basic ventilation',
      'capacity': '2-4 GPUs',
      'imageUrl': 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=400'
    },
    {
      'name': 'Spare Bedroom Mining',
      'cost': 1500,
      'discount': 8,
      'emoji': '🛏️',
      'description': 'Dedicated room with AC cooling',
      'capacity': '6-8 GPUs',
      'imageUrl': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400'
    },
    {
      'name': 'Small Mining Shed',
      'cost': 5000,
      'discount': 12,
      'emoji': '🏚️',
      'description': 'Outdoor shed with power upgrades',
      'capacity': '10-15 GPUs',
      'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'
    },
    {
      'name': 'Container Mining Farm',
      'cost': 15000,
      'discount': 18,
      'emoji': '📦',
      'description': 'Modified shipping container',
      'capacity': '20-30 GPUs',
      'imageUrl': 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=400'
    },
    {
      'name': 'Small Warehouse',
      'cost': 45000,
      'discount': 25,
      'emoji': '🏢',
      'description': 'Professional mining operation',
      'capacity': '50-100 GPUs',
      'imageUrl': 'https://images.unsplash.com/photo-1565008576549-57569a49371d?w=400'
    },
    {
      'name': 'Industrial Facility',
      'cost': 150000,
      'discount': 35,
      'emoji': '🏭',
      'description': 'Large-scale mining with cooling towers',
      'capacity': '200-500 GPUs',
      'imageUrl': 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400'
    },
    {
      'name': 'Data Center',
      'cost': 500000,
      'discount': 45,
      'emoji': '🏗️',
      'description': 'Enterprise-grade infrastructure',
      'capacity': '1000+ GPUs',
      'imageUrl': 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=400'
    },
    {
      'name': 'Mega Mining Complex',
      'cost': 1500000,
      'discount': 60,
      'emoji': '🌆',
      'description': 'Massive operation with cheap power',
      'capacity': 'Unlimited',
      'imageUrl': 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=400'
    },
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
          imageUrl: building['imageUrl'],
          cost: building['cost'].toDouble(),
          description: building['description'],
          tier: building['capacity'],
          stats: [
            {'label': 'Power Discount', 'value': '${building['discount']}%', 'icon': Icons.discount},
            {'label': 'Multiplier', 'value': '${powerMultiplier.toStringAsFixed(2)}x', 'icon': Icons.trending_down},
            {'label': 'Capacity', 'value': building['capacity'], 'icon': Icons.storage},
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
  final String? imageUrl;
  final double cost;
  final String? description;
  final String? tier;
  final List<Map<String, dynamic>> stats;
  final VoidCallback onPurchase;
  final bool canAfford;
  
  const _ShopItemCard({
    required this.name,
    required this.emoji,
    this.imageUrl,
    required this.cost,
    this.description,
    this.tier,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image or Emoji
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CyberpunkTheme.textPrimary,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: CyberpunkTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${cost.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CyberpunkTheme.accentOrange,
                      ),
                    ),
                    if (tier != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getTierColor(tier!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tier!,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
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
                  // Show efficiency rating badge if available
                  if (stat['rating'] != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getEfficiencyRatingColor(stat['rating']),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        stat['rating'],
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
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
  
  /// Get color based on tier
  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'entry':
        return Colors.grey;
      case 'mid-range':
        return Colors.blue;
      case 'high-end':
        return Colors.purple;
      case 'ultra':
        return Colors.deepPurple;
      case 'ultimate':
        return Colors.pink;
      case 'asic':
        return Colors.orange;
      default:
        // For building capacities or other tiers
        if (tier.contains('GPU')) {
          return Colors.teal;
        }
        return Colors.green;
    }
  }
  
  /// Get color based on efficiency rating
  Color _getEfficiencyRatingColor(String rating) {
    switch (rating.toLowerCase()) {
      case 'poor':
        return Colors.red;
      case 'fair':
        return Colors.orange;
      case 'good':
        return Colors.yellow.shade700;
      case 'great':
        return Colors.lightGreen;
      case 'excellent':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
