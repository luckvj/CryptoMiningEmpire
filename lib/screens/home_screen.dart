import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/utils/animations.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/crypto_list_tile.dart';
import '../widgets/mining_status_card.dart';
import '../widgets/active_mining_display.dart';
import '../widgets/crypto_toast.dart';
import '../widgets/game_date_display.dart';
import 'mining_screen.dart';
import 'trading_screen_mobile.dart';
import 'portfolio_screen.dart';
import 'shop_screen.dart';
import 'trading_screen_web.dart';
import 'developer_options_screen.dart';
import 'achievements_screen.dart';
import 'upgrades_screen.dart';
import 'prestige_screen.dart';
import 'pool_mining_screen.dart';
import 'story_mode_screen.dart';
import 'statistics_screen.dart';
import 'daily_challenges_screen.dart';
import '../widgets/tutorial_popup.dart';
import '../widgets/achievement_toast.dart';
import '../core/models/achievements.dart';
import 'credits_screen.dart';


/// Smart hash rate formatter
String _formatHashRate(double hashRate) {
  if (hashRate >= 1000000) {
    return '${(hashRate / 1000000).toStringAsFixed(2)} TH/s';
  } else if (hashRate >= 1000) {
    return '${(hashRate / 1000).toStringAsFixed(2)} GH/s';
  } else {
    return '${hashRate.toStringAsFixed(2)} MH/s';
  }
}
/// Main home screen with navigation and dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final List<Widget> _screens = const [
    DashboardTab(),
    MiningScreen(),
    ShopScreen(),
    TradingScreenMobile(),
    PortfolioScreen(),
    StoryModeScreen(),
    UpgradesScreen(),
    AchievementsScreen(),
    PoolMiningScreen(),
    PrestigeScreen(),
    StatisticsScreen(),
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    // Setup date sync callback after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameState = context.read<GameStateProvider>();
      final priceProvider = context.read<CryptoPriceProvider>();
      
      // Sync prices when game date changes
      gameState.onDateChanged = (newDate) {
        priceProvider.setDate(newDate);
        
        // If market is locked (e.g. Return to Present), force a sync
        if (gameState.isMarketLocked) {
          priceProvider.syncMarket();
        }
      };
      
      // IMMEDIATE SYNC: Set initial date to ensure historical prices/coins are loaded
      priceProvider.setDate(gameState.gameDate);
      
      // Show achievement toast when unlocked
      gameState.onAchievementUnlocked = (achievement) {
        AchievementToast.show(context, achievement);
      };
      
      // Genesis Block Mined Listener
      gameState.onGenesisBlockMined = () {
        showDialog(
          context: context, 
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: CyberpunkTheme.backgroundDark,
            title: Text('GENESIS BLOCK MINED', style: GoogleFonts.orbitron(color: Colors.amber)),
            content: Text(
              'You have successfully mined the first 50 BTC!\n\n'
              'As history dictates, these coins have been moved to the unspendable Genesis Wallet.\n\n'
              'The Bitcoin Network is now live. Time is flowing.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('CONTINUE', style: GoogleFonts.orbitron(color: CyberpunkTheme.primaryBlue)),
              ),
            ],
          ),
        );
      };
      
      // Feature Unlock Announcements (Trading, Pools, etc.)
      gameState.onFeatureUnlocked = (featureName, description) {
        showDialog(
          context: context,
          barrierDismissible: false, // Force user to acknowledge
          builder: (ctx) => AlertDialog(
            backgroundColor: CyberpunkTheme.backgroundDark,
            title: Row(
              children: [
                const Icon(Icons.celebration, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text(featureName, style: GoogleFonts.orbitron(color: Colors.amber, fontSize: 16))),
              ],
            ),
            content: Text(description, style: GoogleFonts.inter(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // gameState.resumeTime(); // DO NOT RESUME - Let user choose speed
                  gameState.saveGame(); // Save immediately to persist announcement state
                },
                child: Text('AWESOME!', style: GoogleFonts.orbitron(color: CyberpunkTheme.accentGreen)),
              ),
            ],
          ),
        );
      };

      // Market Event Listener (Fix for random time stops)
      gameState.onMarketEvent = (event) {
        showDialog(
          context: context,
          barrierDismissible: false, // Force user to acknowledge
          builder: (ctx) => AlertDialog(
            backgroundColor: CyberpunkTheme.backgroundDark,
            title: Row(
              children: [
                Icon(
                  event.severity == 'negative' ? Icons.warning : Icons.trending_up, 
                  color: event.severity == 'negative' ? Colors.red : Colors.green
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    event.title, 
                    style: GoogleFonts.orbitron(
                      color: event.severity == 'negative' ? Colors.red : Colors.green,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              event.description, 
              style: GoogleFonts.inter(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // gameState.resumeTime(); // DO NOT RESUME - Let user choose speed
                  gameState.saveGame(); // Save to persist event state
                },
                child: Text('ACKNOWLEDGE', style: GoogleFonts.orbitron(color: CyberpunkTheme.primaryBlue)),
              ),
            ],
          ),
        );
      };

      
      // Show tutorial for first-time players
      if (!TutorialPopup.hasSeenTutorial()) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => TutorialPopup(
            onDismiss: () => Navigator.of(ctx).pop(),
          ),
        );
      }

      // HANDLE POSITION CLOSURES (P&L POPUP)
      gameState.onPositionClosed = (position, pnl, payout) {
        final isProfit = pnl >= 0;
        final percentage = (pnl / position.amount * 100);
        
        _showTradeAnnouncement(
          isProfit ? 'TRADE PROFIT' : 'TRADE LOSS',
          'Your ${position.cryptoId.toUpperCase()} position has been closed.\n\n'
          'Result: ${isProfit ? "+" : ""}\$${pnl.toStringAsFixed(2)} USDT\n'
          'ROI: ${percentage.toStringAsFixed(2)}%',
          isProfit ? Icons.trending_up : Icons.trending_down,
          isProfit ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed,
        );
      };

      // HANDLE LIQUIDATIONS
      gameState.onLiquidated = (position) {
        _showTradeAnnouncement(
          'LIQUIDATED',
          'Your ${position.cryptoId.toUpperCase()} margin position was forcibly closed due to high volatility and insufficient collateral.\n\n'
          'Loss: 100% of collateral',
          Icons.gavel_rounded,
          CyberpunkTheme.accentRed,
        );
      };

      // LISTEN TO PRICE UPDATES FOR LIQUIDATIONS
      priceProvider.addListener(() {
        if (priceProvider.cryptoData.isNotEmpty) {
          final prices = priceProvider.cryptoData.map((k, v) => MapEntry(k, v.price));
          gameState.checkLiquidations(prices);
        }
      });

      // Attempt 7: SYNC INITIAL TIME SPEED
      priceProvider.setTimeSpeed(gameState.timeSpeed);

      // Attempt 7: SYNC TIME SPEED WITH CRYPTO PRICE PROVIDER
      gameState.addListener(() {
        if (priceProvider.timeSpeed != gameState.timeSpeed) {
           priceProvider.setTimeSpeed(gameState.timeSpeed);
        }
      });
    });
  }

  void _showTradeAnnouncement(String title, String message, IconData icon, Color color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: CyberpunkTheme.backgroundDark,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: color.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Text(title, style: GoogleFonts.orbitron(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pause_circle_filled, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Text('Paused for review', style: GoogleFonts.inter(color: Colors.amber, fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CONTINUE', style: GoogleFonts.orbitron(color: CyberpunkTheme.primaryBlue)),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _onTabTapped(int index) {
    // Check locks
    final gameState = context.read<GameStateProvider>();
    
    // Market Lock (Index 3)
    if (index == 3 && !gameState.isTradingAvailable) {
      CryptoToast.error(context, 'Trading unlocks in July 2010 (Mt Gox Era)!');
      return;
    }
    
    // Pools Lock (Index 8)
    if (index == 8 && !gameState.isPoolMiningAvailable) {
      CryptoToast.error(context, 'Mining Pools unlock in Nov 2010 (Slush Pool)!');
      return;
    }

    // Market Lockout (Index 3) - When returning to present
    if (index == 3 && gameState.isMarketLocked) {
      CryptoToast.warning(context, 'Market nodes syncing... Please wait ${gameState.marketLockoutRemainingSeconds}s');
      return;
    }

    if (index != _currentIndex) {
      setState(() {
        _animationController.reset();
        _currentIndex = index;
        _animationController.forward();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        
        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                // Navigation Rail (Sidebar)
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: CyberpunkTheme.backgroundDark.withOpacity(0.95),
                    border: Border(right: BorderSide(color: CyberpunkTheme.primaryBlue.withOpacity(0.3))),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                 Image.asset('assets/images/logo.png', width: 44, height: 44),
                                 const SizedBox(width: 14),
                                 Expanded(
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       ShaderMask(
                                         shaderCallback: (bounds) => LinearGradient(
                                           colors: [CyberpunkTheme.primaryBlue, CyberpunkTheme.accentPurple, CyberpunkTheme.accentCyan],
                                         ).createShader(bounds),
                                         child: Text('Stupid Rigger', style: GoogleFonts.orbitron(
                                           color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2
                                         )),
                                       ),
                                     ],
                                   ),
                                 ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: CyberpunkTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: CyberpunkTheme.primaryBlue.withOpacity(0.3)),
                              ),
                                child: Text('[ RIGGER-OS v1.0.4-LOCKED ]', style: GoogleFonts.jetBrainsMono(
                                 color: CyberpunkTheme.primaryBlue, fontSize: 9, fontWeight: FontWeight.bold
                               )),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        child: GameDateDisplay(compact: true),
                      ),
                       _buildNavSection('OPERATIONS'),
                      ...List.generate(3, (index) {
                         final labels = ['Dashboard', 'Mining', 'Hardware Shop'];
                         final icons = [Icons.dashboard_rounded, Icons.bolt_rounded, Icons.storefront_rounded];
                         final isSelected = _currentIndex == (index == 2 ? 2 : index); // Dash(0), Mine(1), Shop(2)
                         return _buildSidebarItem(labels[index], icons[index], isSelected, () => setState(() => _currentIndex = (index == 2 ? 2 : index)));
                      }),
                      
                      const SizedBox(height: 16),
                      _buildNavSection('EXCHANGE & WALLET'),
                      ...List.generate(2, (index) {
                         final labels = ['Crypto Market', 'Portfolio'];
                         final icons = [Icons.swap_horiz_rounded, Icons.account_balance_wallet_rounded];
                         final actualIndex = index + 3; // Trade(3), Port(4)
                          final isSelected = _currentIndex == actualIndex;
                          return _buildSidebarItem(
                            labels[index], 
                            icons[index], 
                            isSelected, 
                            () {
                              if (actualIndex == 3 && context.read<GameStateProvider>().isMarketLocked) {
                                CryptoToast.warning(context, 'Market nodes syncing... Please wait ${context.read<GameStateProvider>().marketLockoutRemainingSeconds}s');
                                return;
                              }
                              setState(() => _currentIndex = actualIndex);
                            },
                            color: (actualIndex == 3 && context.read<GameStateProvider>().isMarketLocked) ? Colors.grey.withOpacity(0.5) : null,
                          );
                       }),

                      const SizedBox(height: 16),
                      _buildNavSection('PROGRESSION'),
                      _buildSidebarItem('Story Mode', Icons.auto_stories, _currentIndex == 5, () => _onTabTapped(5), color: Colors.amber),
                      _buildSidebarItem('Upgrades', Icons.upgrade, _currentIndex == 6, () => _onTabTapped(6), color: Colors.cyan),
                      _buildSidebarItem('Achievements', Icons.emoji_events, _currentIndex == 7, () => _onTabTapped(7), color: Colors.amber),
                      
                      const SizedBox(height: 16),
                      _buildNavSection('NETWORK'),
                      _buildSidebarItem('Mining Pools', Icons.groups, _currentIndex == 8, () => _onTabTapped(8), color: Colors.lightBlue),
                      _buildSidebarItem('Prestige', Icons.star, _currentIndex == 9, () => _onTabTapped(9), color: Colors.purple),
                      
                      const SizedBox(height: 16),
                      _buildNavSection('SYSTEM'),
                      _buildSidebarItem('Statistics', Icons.bar_chart, _currentIndex == 10, () => _onTabTapped(10), color: Colors.teal),
                      _buildSidebarItem('Tutorial', Icons.help_outline, false, () => _showTutorial(context), color: CyberpunkTheme.accentGreen),
                      _buildSidebarItem('Credits', Icons.info_outline, false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditsScreen()))),
                      
                      const Divider(color: Colors.white10, height: 32),
                      _buildSidebarItem('Save Game', Icons.save, false, () {
                        context.read<GameStateProvider>().saveGame();
                        CryptoToast.success(context, 'Game Saved!');
                      }, color: Colors.grey),
                      _buildSidebarItem('Time Travel', Icons.history, false, () {
                        final gameState = context.read<GameStateProvider>();
                        if (!gameState.canTimeTravel) {
                          CryptoToast.warning(context, 'Time Travel cooling down... ${gameState.timeTravelCooldownRemaining}s remaining');
                          return;
                        }
                        _showTimeTravelDialog(context);
                      }, color: Colors.blue, isBold: true),
                      _buildSidebarItem('Reset Game', Icons.refresh, false, () {
                        final gameState = context.read<GameStateProvider>();
                        if (!gameState.canTimeTravel) {
                          CryptoToast.warning(context, 'Time Travel cooling down... ${gameState.timeTravelCooldownRemaining}s remaining');
                          return;
                        }
                        _showResetDialog(context);
                      }, color: Colors.red, isBold: true),
                      const SizedBox(height: 32),
                      ListTile(
                        leading: const Icon(Icons.brightness_6, color: Colors.grey),
                        title: const Text('Toggle Theme', style: TextStyle(color: Colors.grey)),
                        onTap: () => context.read<ThemeProvider>().toggleTheme(),
                      ),
                    ],
                  ),
                ),
              ),
                // Main Content
                Expanded(
                  child: Stack(
                    children: [
                       Container(decoration: CyberpunkTheme.serverRoomBackground()),
                       // Special case for Trading on Web
                       _currentIndex == 3 ? const TradingScreenWeb() : _screens[_currentIndex],
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 48,
            title: const GameDateDisplay(compact: true),
            titleSpacing: 8,
            actions: [
              Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
                return IconButton(
                    icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                    onPressed: () {
                      themeProvider.toggleTheme();
                      CryptoToast.info(context, themeProvider.isDarkMode ? '🌙 Dark mode enabled' : '☀️ Light mode enabled');
                    });
              }),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                    if (value == 'reset') {
                      final gameState = context.read<GameStateProvider>();
                      if (!gameState.canTimeTravel) {
                        CryptoToast.warning(context, 'Time Travel cooling down... ${gameState.timeTravelCooldownRemaining}s remaining');
                      } else {
                        _showResetDialog(context);
                      }
                    } else if (value == 'time_travel') {
                      final gameState = context.read<GameStateProvider>();
                      if (!gameState.canTimeTravel) {
                        CryptoToast.warning(context, 'Time Travel cooling down... ${gameState.timeTravelCooldownRemaining}s remaining');
                      } else {
                        _showTimeTravelDialog(context);
                      }
                    } else if (value == 'save') {
                    await context.read<GameStateProvider>().saveGame();
                    if (mounted) CryptoToast.success(context, 'Game saved!', icon: Icons.save);
                  } else if (value == 'achievements') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen()));
                  } else if (value == 'upgrades') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UpgradesScreen()));
                  } else if (value == 'story') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryModeScreen()));
                  } else if (value == 'daily') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyChallengesScreen()));
                  } else if (value == 'stats') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen()));
                  } else if (value == 'prestige') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PrestigeScreen()));
                  } else if (value == 'pools') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PoolMiningScreen()));
                  } else if (value == 'credits') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditsScreen()));
                  } else if (value == 'tutorial') {
                    _showTutorial(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'story', child: Row(children: [Icon(Icons.auto_stories, color: Colors.amber), SizedBox(width: 8), Text('Story Mode')])),
                  const PopupMenuItem(value: 'upgrades', child: Row(children: [Icon(Icons.upgrade, color: Colors.cyan), SizedBox(width: 8), Text('Upgrades')])),
                  const PopupMenuItem(value: 'achievements', child: Row(children: [Icon(Icons.emoji_events, color: Colors.amber), SizedBox(width: 8), Text('Achievements')])),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'pools', child: Row(children: [Icon(Icons.groups, color: Colors.lightBlue), SizedBox(width: 8), Text('Mining Pools')])),
                  const PopupMenuItem(value: 'prestige', child: Row(children: [Icon(Icons.star, color: Colors.purple), SizedBox(width: 8), Text('Prestige')])),
                  const PopupMenuItem(value: 'stats', child: Row(children: [Icon(Icons.bar_chart, color: Colors.teal), SizedBox(width: 8), Text('Statistics')])),
                  const PopupMenuItem(value: 'daily', child: Row(children: [Icon(Icons.calendar_today, color: Colors.green), SizedBox(width: 8), Text('Daily Challenges')])),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'tutorial', child: Row(children: [Icon(Icons.help_outline, color: CyberpunkTheme.accentGreen), SizedBox(width: 8), Text('View Tutorial')])),
                  const PopupMenuItem(value: 'save', child: Row(children: [Icon(Icons.save), SizedBox(width: 8), Text('Save Game')])),
                  const PopupMenuItem(value: 'time_travel', child: Row(children: [Icon(Icons.history, color: Colors.blue), SizedBox(width: 8), Text('Time Travel')])),
                  const PopupMenuItem(value: 'reset', child: Row(children: [Icon(Icons.refresh, color: Colors.red), SizedBox(width: 8), Text('Reset Game')])),
                  const PopupMenuItem(value: 'credits', child: Row(children: [Icon(Icons.info_outline, color: Colors.grey), SizedBox(width: 8), Text('Credits')])),
                ],
              ),
            ],
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _screens[_currentIndex],
            ),
          ),
          bottomNavigationBar: _PremiumBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        );
      },
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
              await gameState.resetGameToGenesis();
              Navigator.pop(context);
              CryptoToast.info(context, 'Game reset to Genesis 2009! Starting fresh...', icon: Icons.refresh);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberpunkTheme.accentOrange,
            ),
            child: Text(
              'RESET',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTimeTravelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CyberpunkTheme.surfaceColor,
        title: Text(
          'Start New Game',
          style: GoogleFonts.inter(
            color: CyberpunkTheme.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your starting point:',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            // Present Day (Reset)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberpunkTheme.accentGreen.withOpacity(0.2),
                  foregroundColor: CyberpunkTheme.accentGreen,
                  side: BorderSide(color: CyberpunkTheme.accentGreen),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  final gameState = context.read<GameStateProvider>();
                  final priceProvider = context.read<CryptoPriceProvider>();
                  
                  // Reset to present with current prices
                  gameState.resetGame(); // No year = defaults to now
                  priceProvider.setDate(DateTime.now());
                  
                  CryptoToast.success(context, 'Started new game in present day!');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Present Day (Standard)', 
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.today, size: 20),
                  ],
                ),
              ),
            ),
            // 2009 Genesis Era
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.withOpacity(0.2),
                  foregroundColor: Colors.amber,
                  side: BorderSide(color: Colors.amber),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  final gameState = context.read<GameStateProvider>();
                  gameState.resetGameToGenesis();
                  CryptoToast.success(context, 'Traveled to 2009 Genesis Era!');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '2009 (Genesis Era)', 
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.fingerprint, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  Widget _buildYearBtn(BuildContext context, int year, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: CyberpunkTheme.primaryBlue.withOpacity(0.2),
          foregroundColor: CyberpunkTheme.primaryBlue,
          side: BorderSide(color: CyberpunkTheme.primaryBlue),
        ),
        onPressed: () {
          Navigator.pop(context);
          final gameState = context.read<GameStateProvider>();
          final priceProvider = context.read<CryptoPriceProvider>();
          
          // Set the game date to January 1st of the selected year
          final newDate = DateTime(year, 1, 1);
          if (year == 2009) {
            gameState.resetGameToGenesis();
          } else {
            gameState.jumpToDate(newDate);
            priceProvider.setDate(newDate);
            gameState.resetGame(year: year);
          }
          
          CryptoToast.success(context, 'Traveled to $year!');
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label, 
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(year.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildNavSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.orbitron(
          color: CyberpunkTheme.primaryBlue,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildSidebarItem(String label, IconData icon, bool isSelected, VoidCallback onTap, {Color? color, bool isBold = false}) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? CyberpunkTheme.primaryBlue : (color ?? Colors.grey), size: 20),
      title: Text(label, style: GoogleFonts.orbitron(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: (isSelected || isBold) ? FontWeight.bold : FontWeight.w500,
        letterSpacing: 1.0,
        fontSize: 13,
      )),
      tileColor: isSelected ? CyberpunkTheme.primaryBlue.withOpacity(0.1) : null,
      dense: true,
      onTap: onTap,
    );
  }

  void _showTutorial(BuildContext context) {
     showDialog(
       context: context,
       barrierDismissible: false,
       builder: (ctx) => TutorialPopup(
         onDismiss: () => Navigator.of(ctx).pop(),
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
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game Time Display (for mobile - desktop has it in sidebar)
          const GameDateDisplay(),
          const SizedBox(height: 16),
          
          // Header Card with Logo - Glassmorphism Style
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: CyberpunkTheme.glassHeader(),
            child: Row(
              children: [
                // Glowing logo container
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CyberpunkTheme.primaryBlue,
                        CyberpunkTheme.accentPurple,
                        CyberpunkTheme.accentCyan,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CyberpunkTheme.primaryBlue.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: CyberpunkTheme.accentPurple.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.currency_bitcoin,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, Miner!',
                        style: GoogleFonts.inter(
                          color: CyberpunkTheme.textSecondary,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            CyberpunkTheme.accentGreen,
                            CyberpunkTheme.accentCyan,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          '\$${netWorth.toStringAsFixed(2)}',
                          style: GoogleFonts.orbitron(
                            color: netWorth < 0 ? CyberpunkTheme.accentRed : Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Total Net Worth',
                        style: GoogleFonts.inter(
                          color: CyberpunkTheme.textTertiary,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        
          // Balance Cards
          Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'Balance',
                  value: '\$${gameState.balance.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                  color: gameState.balance < 0 ? CyberpunkTheme.accentRed : CyberpunkTheme.accentGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HashRateDashboardCard(totalHashRate: gameState.totalHashRate),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Mining Stats
          Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'GPUs',
                  value: '${gameState.gpuCount}',
                  icon: Icons.memory,
                  color: CyberpunkTheme.accentCyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardCard(
                  title: 'Power Cost',
                  value: '\$${gameState.dailyPowerCost.toStringAsFixed(2)}/day',
                  icon: Icons.bolt,
                  color: CyberpunkTheme.accentOrange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Active Mining Display - Smart per-coin hashrate breakdown
          const ActiveMiningDisplay(),
          
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
          
          // Crypto List - filtered by era
          if (priceProvider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Builder(builder: (context) {
              final availableCoins = priceProvider.getAvailableCoins();
              final sortedCoins = availableCoins.values.toList()
                ..sort((a, b) => b.marketCap.compareTo(a.marketCap)); // Market cap for dashboard
              final displayCoins = sortedCoins.take(10).toList();
              
              if (displayCoins.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: CyberpunkTheme.glassmorphismCard(glowColor: Colors.orange),
                    child: Row(
                      children: [
                        const Icon(Icons.currency_bitcoin, color: Colors.orange, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Early Bitcoin Era', style: GoogleFonts.orbitron(color: Colors.orange, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Only Bitcoin exists. Other coins coming soon!', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return Column(
                children: displayCoins.map((crypto) => CryptoListTile(crypto: crypto)).toList(),
              );
            }),
            
          // Bottom padding
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Premium floating bottom navigation bar
class _PremiumBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const _PremiumBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_PremiumBottomNavBar> createState() => _PremiumBottomNavBarState();
}

class _PremiumBottomNavBarState extends State<_PremiumBottomNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  
  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.bolt_rounded, label: 'Mining'),
    _NavItem(icon: Icons.storefront_rounded, label: 'Shop'),
    _NavItem(icon: Icons.swap_horiz_rounded, label: 'Market'),
    _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Portfolio'),
  ];
  
  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: CyberpunkTheme.glassNavBar(),
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                final isSelected = index == widget.currentIndex;
                final item = _items[index];
                final glowIntensity = isSelected ? 0.5 + _glowController.value * 0.3 : 0.0;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CyberpunkTheme.primaryBlue.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: CyberpunkTheme.primaryBlue.withOpacity(glowIntensity * 0.5),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedScale(
                            scale: isSelected ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              item.icon,
                              size: 24,
                              color: isSelected
                                  ? CyberpunkTheme.primaryBlue
                                  : CyberpunkTheme.textTertiary,
                              shadows: isSelected
                                  ? [
                                      Shadow(
                                        color: CyberpunkTheme.primaryBlue.withOpacity(0.6),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? CyberpunkTheme.primaryBlue
                                  : CyberpunkTheme.textTertiary,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  
  const _NavItem({required this.icon, required this.label});
}
