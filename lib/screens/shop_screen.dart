import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../providers/game_state_provider.dart';
import '../core/utils/efficiency_calculator.dart';
import '../widgets/crypto_toast.dart';
import '../core/config/shop_config.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'CPUs'),
            Tab(text: 'GPUs'),
            Tab(text: 'BUILDINGS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CPUShopTab(),
          GPUShopTab(),
          BuildingShopTab(),
        ],
      ),
    );
  }
}

/// GPU Shop Tab with Filter
class GPUShopTab extends StatefulWidget {
  const GPUShopTab({super.key});
  
  @override
  State<GPUShopTab> createState() => _GPUShopTabState();
}

class _GPUShopTabState extends State<GPUShopTab> {
  bool _filterByEra = false; // Era filter toggle
  
  // All algorithms early GPUs can mine (before ASICs made them obsolete)
  static const List<String> _gpuAlgorithms = ShopConfig.gpuAlgorithms;

  static final List<Map<String, dynamic>> gpus = ShopConfig.gpus;

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    
    // Apply era filter if enabled
    var filteredGpus = _filterByEra
        ? gpus.where((gpu) => (gpu['releaseYear'] as int? ?? 2000) <= gameState.gameYear).toList()
        : gpus.toList();
    filteredGpus.sort((a, b) => (a['cost'] as num).compareTo(b['cost'] as num));
    
    return Column(
      children: [
        // Filter Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: CyberpunkTheme.surfaceColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${filteredGpus.length} items', style: TextStyle(color: CyberpunkTheme.textTertiary)),
              Row(
                children: [
                  Text('Era Filter', style: TextStyle(color: CyberpunkTheme.textSecondary, fontSize: 12)),
                  const SizedBox(width: 8),
                  Switch(
                    value: _filterByEra,
                    onChanged: (v) => setState(() => _filterByEra = v),
                    activeColor: CyberpunkTheme.primaryBlue,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Item List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredGpus.length,
            itemBuilder: (context, index) {
              final gpu = filteredGpus[index];
        final efficiency = EfficiencyCalculator.calculateEfficiency(
          gpu['hashRate'].toDouble(), 
          gpu['power'].toDouble()
        );
        final efficiencyRating = EfficiencyCalculator.getEfficiencyRating(
          gpu['hashRate'].toDouble(), 
          gpu['power'].toDouble()
        );
        
        final hashRateUnit = gpu['hashRateUnit'] ?? 'MH/s';
        final isASIC = gpu['isASIC'] ?? false;
        final algorithm = gpu['algorithm'] ?? 'Ethash';
        final List<String> supportedAlgorithms = gpu['supportedAlgorithms'] ?? [algorithm];
        
        String algoDisplay = supportedAlgorithms.length > 1 
            ? supportedAlgorithms.join(', ')
            : algorithm;
            
        if (algoDisplay.length > 25) {
           algoDisplay = 'Multi-Algo (${supportedAlgorithms.length})';
        }
        
        final Set<String> allCompatibleCoins = {};
        for (final algo in supportedAlgorithms) {
          allCompatibleCoins.addAll(AlgorithmCompatibility.getCompatibleCoins(algo));
        }
        
        final coinsDisplay = allCompatibleCoins.take(5).map((c) => 
          c.split('-').map((w) => w[0].toUpperCase() + w.substring(1)).join('')
        ).join(', ') + (allCompatibleCoins.length > 5 ? '...' : '');
        
        double hashRateMH = gpu['hashRate'].toDouble();
        if (hashRateUnit == 'TH/s') hashRateMH *= 1000000;
        else if (hashRateUnit == 'GH/s') hashRateMH *= 1000;
        else if (hashRateUnit == 'KH/s') hashRateMH /= 1000;
        
        final dailyRevenue = hashRateMH * 0.001; 
        final powerCost = (gpu['power'].toDouble() / 1000) * 24 * 0.12;
        final dailyProfit = dailyRevenue - powerCost;
        final roiDays = dailyProfit > 0 ? (gpu['cost'].toDouble() / dailyProfit) : 9999.0;
        
        return _ShopItemCard(
          name: gpu['name'],
          imageUrl: gpu['imageUrl'],
          cost: gpu['cost'].toDouble(),
          description: gpu['description'],
          tier: gpu['tier'],
          algorithm: algoDisplay,
          compatibleCoins: coinsDisplay,
          stats: [
            {'label': 'Hash Rate', 'value': '${gpu['hashRate']} $hashRateUnit', 'icon': Icons.speed},
            {'label': 'Est. ROI', 'value': dailyProfit > 0 ? '${roiDays.toStringAsFixed(0)} Days' : 'Never', 'icon': Icons.calendar_today, 'rating': dailyProfit > 0 ? (roiDays < 200 ? 'Good' : 'Medium') : 'Bad'},
            {'label': 'Efficiency', 'value': '${efficiency.toStringAsFixed(2)} MH/W', 'icon': Icons.eco, 'rating': efficiencyRating},
          ],
          onPurchase: () {
            final gpuItem = GPU(
              name: gpu['name'],
              cost: gpu['cost'].toDouble(),
              hashRate: gpu['hashRate'].toDouble(),
              hashRateUnit: hashRateUnit,
              powerWatts: gpu['power'].toDouble(),
              algorithm: gpu['algorithm'] ?? 'Ethash',
              supportedAlgorithms: supportedAlgorithms,
              minerType: isASIC ? MinerType.asic : MinerType.gpu,
            );
            
            // Check era restriction - hardware must exist in current year
            final releaseYear = gpu['releaseYear'] as int? ?? 2000;
            if (gameState.gameYear < releaseYear) {
              CryptoToast.error(context, '🔒 ${gpu['name']} not invented yet! Available in $releaseYear.');
              return;
            }
            
            // Check for negative balance - can't buy with debt
            if (gameState.balance < 0) {
              CryptoToast.error(context, '💸 You are in debt! Pay off power costs before buying.');
              return;
            }
            
            // Check capacity and funds separately for correct error messages
            final hasEnoughFunds = gameState.balance >= gpu['cost'];
            final hasCapacity = gameState.gpuCount < gameState.maxGpuCapacity;
            
            if (!hasCapacity && hasEnoughFunds) {
              CryptoToast.error(context, 'GPU LIMIT REACHED! Purchase a bigger building to expand capacity.');
              return;
            }
            
            if (!hasEnoughFunds) {
              CryptoToast.error(context, '💰 Insufficient funds! Need \$${gpu['cost']}');
              return;
            }
            
            if (gameState.purchaseGPU(gpuItem)) {
              CryptoToast.purchase(context, gpu['name'], gpu['cost'].toDouble());
            }
          },
          canAfford: gameState.balance >= gpu['cost'] && 
                     gameState.gpuCount < gameState.maxGpuCapacity &&
                     gameState.balance >= 0 &&
                     gameState.gameYear >= (gpu['releaseYear'] as int? ?? 2000),
          isLocked: gameState.gameYear < (gpu['releaseYear'] as int? ?? 2000),
          lockReason: gameState.gameYear < (gpu['releaseYear'] as int? ?? 2000) 
              ? 'Unlocks in ${gpu['releaseYear']}' 
              : null,
        );
            },
          ),
        ),
      ],
    );
  }
}

/// CPU Shop Tab
class CPUShopTab extends StatelessWidget {
  const CPUShopTab({super.key});
  
  static final List<Map<String, dynamic>> cpus = ShopConfig.cpus;

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    
    final sortedCpus = cpus
        .where((cpu) => (cpu['releaseYear'] as int? ?? 2000) <= gameState.gameYear)
        .toList()
      ..sort((a, b) => (a['cost'] as num).compareTo(b['cost'] as num));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedCpus.length,
      itemBuilder: (context, index) {
        final cpu = sortedCpus[index];
        final efficiency = EfficiencyCalculator.calculateEfficiency(
          cpu['hashRate'].toDouble(), 
          cpu['power'].toDouble()
        );
        final efficiencyRating = EfficiencyCalculator.getEfficiencyRating(
          cpu['hashRate'].toDouble(), 
          cpu['power'].toDouble()
        );
        
        final hashRateUnit = cpu['hashRateUnit'] ?? 'KH/s';
        final algorithm = cpu['algorithm'] ?? 'RandomX';
        final compatibleCoins = AlgorithmCompatibility.getCompatibleCoins(algorithm);
        final coinsDisplay = compatibleCoins.map((c) => 
          c.split('-').map((w) => w[0].toUpperCase() + w.substring(1)).join('')
        ).join(', ');
        
        return _ShopItemCard(
          name: cpu['name'],
          imageUrl: cpu['imageUrl'],
          cost: cpu['cost'].toDouble(),
          description: cpu['description'],
          tier: cpu['tier'],
          algorithm: algorithm,
          compatibleCoins: coinsDisplay,
          stats: [
            {'label': 'Hash Rate', 'value': '${cpu['hashRate']} $hashRateUnit', 'icon': Icons.speed},
            {'label': 'Power', 'value': '${cpu['power']} W', 'icon': Icons.power},
            {'label': 'Cores', 'value': '${cpu['cores']}', 'icon': Icons.memory},
            {'label': 'Efficiency', 'value': '${efficiency.toStringAsFixed(3)} KH/W', 'icon': Icons.eco, 'rating': efficiencyRating},
          ],
          onPurchase: () {
            final cpuItem = GPU(
              name: cpu['name'],
              cost: cpu['cost'].toDouble(),
              hashRate: cpu['hashRate'].toDouble(),
              hashRateUnit: hashRateUnit,
              powerWatts: cpu['power'].toDouble(),
              algorithm: cpu['algorithm'] ?? 'RandomX',
              minerType: MinerType.cpu,
            );
            
            // CPUs have no capacity limit - only check funds
            if (gameState.purchaseGPU(cpuItem)) {
              CryptoToast.purchase(context, cpu['name'], cpu['cost'].toDouble());
            } else {
              CryptoToast.error(context, 'Insufficient funds!');
            }
          },
          canAfford: gameState.balance >= cpu['cost'],
        );
      },
    );
  }
}

/// Building Shop Tab
class BuildingShopTab extends StatelessWidget {
  const BuildingShopTab({super.key});
  
  static final List<Map<String, dynamic>> buildings = ShopConfig.buildings;

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    
    final sortedBuildings = buildings
        .where((b) => (b['releaseYear'] as int? ?? 2000) <= gameState.gameYear)
        .toList()
      ..sort((a, b) => (a['cost'] as num).compareTo(b['cost'] as num));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedBuildings.length,
      itemBuilder: (context, index) {
        final building = sortedBuildings[index];
        final powerMultiplier = 1.0 - (building['discount'] / 100.0);
        
        return _ShopItemCard(
          name: building['name'],
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
              description: building['description'] ?? '',
              imageUrl: building['imageUrl'] ?? '',
              maxSlots: int.tryParse(building['capacity']?.split('-')?.last?.split(' ')?.first ?? '0') ?? 0,
            );
            
            if (gameState.purchaseBuilding(buildingItem)) {
              CryptoToast.purchase(context, building['name'], building['cost'].toDouble());
            } else {
              CryptoToast.error(context, 'Insufficient funds!');
            }
          },
          canAfford: gameState.balance >= building['cost'],
        );
      },
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double cost;
  final String? description;
  final String? tier;
  final String? algorithm;
  final String? compatibleCoins;
  final List<Map<String, dynamic>> stats;
  final VoidCallback onPurchase;
  final bool canAfford;
  final bool isLocked;
  final String? lockReason;
  
  const _ShopItemCard({
    required this.name,
    this.imageUrl,
    required this.cost,
    this.description,
    this.tier,
    this.algorithm,
    this.compatibleCoins,
    required this.stats,
    required this.onPurchase,
    required this.canAfford,
    this.isLocked = false,
    this.lockReason,
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E), // Solid dark grey to match studio shots
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl != null
                      ? Image.asset(
                          imageUrl!,
                          fit: BoxFit.contain, // Show full item
                          errorBuilder: (ctx, err, st) => const Icon(Icons.memory, size: 40, color: Colors.white54),
                        )
                      : const Icon(Icons.memory, size: 40, color: Colors.white54),
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
                          color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                        ),
                        child: Text(
                          tier!,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            if (algorithm != null) ...[
              Row(
                children: [
                  const Icon(Icons.code, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('Algo: $algorithm', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (compatibleCoins != null && compatibleCoins!.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.currency_bitcoin, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Coins: $compatibleCoins', 
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: stats.map((stat) => _StatItem(
                label: stat['label'],
                value: stat['value'],
                icon: stat['icon'],
                rating: stat['rating'],
              )).toList(),
            ),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: (canAfford && !isLocked) ? onPurchase : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLocked 
                      ? Colors.grey.shade700 
                      : (canAfford ? CyberpunkTheme.primaryBlue : Colors.grey.shade800),
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: isLocked ? Colors.grey.shade700 : Colors.grey.shade900,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLocked) ...[
                      const Icon(Icons.lock, size: 16, color: Colors.white54),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      isLocked 
                          ? (lockReason ?? 'LOCKED') 
                          : (canAfford ? 'PURCHASE' : 'INSUFFICIENT FUNDS'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.white54 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? rating;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    Color valueColor = Colors.white;
    if (rating == 'Good') valueColor = CyberpunkTheme.accentGreen;
    if (rating == 'Bad') valueColor = CyberpunkTheme.accentRed;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: CyberpunkTheme.primaryBlue.withOpacity(0.7)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
