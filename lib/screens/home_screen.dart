import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/utils/animations.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/crypto_list_tile.dart';
import '../widgets/mining_status_card.dart';
import '../widgets/location_display.dart';
import 'mining_screen.dart';
import 'trading_screen.dart';
import 'portfolio_screen.dart';
import 'shop_screen.dart';

/// Main home screen with navigation and dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = const [
    DashboardTab(),
    MiningScreen(),
    TradingScreen(),
    PortfolioScreen(),
    ShopScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRYPTO MINING EMPIRE'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'reset') {
                _showResetDialog(context);
              } else if (value == 'save') {
                final gameState = context.read<GameStateProvider>();
                gameState.saveGame();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Game saved!'),
                    backgroundColor: CyberpunkTheme.accentGreen,
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save, color: CyberpunkTheme.textPrimary),
                    SizedBox(width: 8),
                    Text('Save Game'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Reset Game'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CyberpunkTheme.backgroundLight,
              CyberpunkTheme.surfaceColor,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: CyberpunkTheme.primaryBlue.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: CyberpunkTheme.primaryBlue,
          unselectedItemColor: CyberpunkTheme.textSecondary,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_input_antenna),
              label: 'Mining',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz),
              label: 'Trade',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Portfolio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Shop',
            ),
          ],
        ),
      ),
    );
  }
  
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CyberpunkTheme.surfaceColor,
        title: Text(
          'Reset Game?',
          style: GoogleFonts.inter(
            color: CyberpunkTheme.accentOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will delete all your progress and start fresh. This cannot be undone!',
          style: GoogleFonts.inter(
            color: CyberpunkTheme.textPrimary,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(
                color: CyberpunkTheme.accentGreen,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final gameState = context.read<GameStateProvider>();
              await gameState.resetGame();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Game reset! Starting fresh...'),
                  backgroundColor: CyberpunkTheme.primaryBlue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberpunkTheme.accentOrange,
            ),
            child: Text(
              'RESET',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashboard Tab - Overview of everything
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    final priceProvider = context.watch<CryptoPriceProvider>();
    
    final prices = priceProvider.cryptoData.map(
      (key, value) => MapEntry(key, value.price),
    );
    final netWorth = gameState.calculateNetWorth(prices);
    
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: CyberpunkTheme.backgroundLight,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'CRYPTO MINING EMPIRE',
              style: TextStyle(
                ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CyberpunkTheme.accentPurple.withOpacity(0.3),
                    CyberpunkTheme.primaryBlue.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Balance Cards
              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      title: 'Balance',
                      value: '\$${gameState.balance.toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet,
                      color: CyberpunkTheme.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DashboardCard(
                      title: 'Net Worth',
                      value: '\$${netWorth.toStringAsFixed(2)}',
                      icon: Icons.trending_up,
                      color: CyberpunkTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Mining Stats
              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      title: 'Hash Rate',
                      value: '${gameState.totalHashRate.toStringAsFixed(2)} MH/s',
                      icon: Icons.speed,
                      color: CyberpunkTheme.accentOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DashboardCard(
                      title: 'GPUs',
                      value: '${gameState.gpuCount}',
                      icon: Icons.memory,
                      color: CyberpunkTheme.accentOrange,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Location Display - Visual progression
              LocationDisplay(
                location: gameState.currentLocation,
                nextLocation: gameState.nextLocation,
                progress: gameState.locationProgress,
              ),
              
              const SizedBox(height: 24),
              
              // Mining Status
              const MiningStatusCard(),
              
              const SizedBox(height: 24),
              
              // Top Cryptocurrencies Header
              Text(
                'TOP CRYPTOCURRENCIES',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: CyberpunkTheme.primaryBlue,
                  ),
              ),
              
              const SizedBox(height: 12),
              
              // Crypto List
              if (priceProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                ...priceProvider.cryptoData.values.take(10).map(
                  (crypto) => CryptoListTile(crypto: crypto),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}
