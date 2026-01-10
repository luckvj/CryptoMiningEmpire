import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';
import '../widgets/crypto_toast.dart';
/// Story Mode - Guided tutorial with goals and narrative
class StoryModeScreen extends StatefulWidget {
  const StoryModeScreen({super.key});

  @override
  State<StoryModeScreen> createState() => _StoryModeScreenState();
}

class _StoryModeScreenState extends State<StoryModeScreen> {
  int _currentChapter = 0;
  
  static const List<StoryChapter> chapters = [
    StoryChapter(
      id: 0,
      title: 'The Genesis',
      subtitle: 'Jan 3, 2009',
      description: 'You are Satoshi Nakamoto. The traditional banking system is collapsing. It\'s time to launch the solution. Mine the Genesis Block.',
      year: 2009,
      goals: [
        StoryGoal('Mine the Genesis Block (50 BTC)', 'mine_btc', 50.0),
        StoryGoal('Keep the network alive', 'hash_rate', 1.0), // minimal hash rate
      ],
      reward: 0.0, // Reward is the 50 BTC itself (which is worth nothing initially)
      icon: Icons.fingerprint,
    ),
    StoryChapter(
      id: 1,
      title: 'The Beginning',
      subtitle: 'Welcome to 2010',
      description: 'You\'ve birthed Bitcoin. Now the world is starting to notice. A mysterious currency that could change the world.',
      year: 2010,
      goals: [
        StoryGoal('Mine your first 100 BTC', 'mine_btc', 100.0),
        StoryGoal('Buy your first GPU', 'buy_gpu', 1),
      ],
      reward: 100.0,
      icon: Icons.rocket_launch,
    ),
    StoryChapter(
      id: 2,
      title: 'The Pizza Day',
      subtitle: 'May 22, 2010',
      description: 'Someone just paid 10,000 BTC for two pizzas. Is Bitcoin actually worth something? Time to accumulate more.',
      year: 2010,
      goals: [
        StoryGoal('Accumulate 10,000 BTC', 'hold_btc', 10000.0),
        StoryGoal('Reach \$100 balance', 'balance', 100),
      ],
      reward: 500.0,
      icon: Icons.local_pizza,
    ),
    StoryChapter(
      id: 3,
      title: 'The First Boom',
      subtitle: '2011 - The \$30 Rally',
      description: 'Bitcoin just hit \$30! Early adopters are becoming wealthy. But dark clouds are forming...',
      year: 2011,
      goals: [
        StoryGoal('Reach \$1,000 net worth', 'networth', 1000),
        StoryGoal('Own 5 GPUs', 'gpus', 5),
      ],
      reward: 1000.0,
      icon: Icons.trending_up,
    ),
    StoryChapter(
      id: 4,
      title: 'Mt. Gox Era',
      subtitle: '2013 - The Exchange',
      description: 'Mt. Gox handles 70% of all Bitcoin trades. The ecosystem is growing but security is a concern.',
      year: 2013,
      goals: [
        StoryGoal('Complete 10 trades', 'trades', 10),
        StoryGoal('Reach \$10,000 balance', 'balance', 10000),
      ],
      reward: 5000.0,
      icon: Icons.account_balance,
    ),
    StoryChapter(
      id: 5,
      title: 'The Ethereum ICO',
      subtitle: '2015 - Smart Contracts Arrive',
      description: 'Vitalik Buterin launches Ethereum. The world\'s first programmable blockchain promises to change everything. Time to buy ETH!',
      year: 2015,
      goals: [
        StoryGoal('Buy 10 ETH', 'hold_eth', 10),
        StoryGoal('Reach \$50,000 net worth', 'networth', 50000),
      ],
      reward: 10000.0,
      icon: Icons.diamond,
    ),
    StoryChapter(
      id: 6,
      title: 'The ICO Bubble',
      subtitle: '2017 - To the Moon!',
      description: 'Everyone is getting rich. Bitcoin is at \$20,000. Ethereum ICOs everywhere. But how long can this last?',
      year: 2017,
      goals: [
        StoryGoal('Become a millionaire', 'networth', 1000000),
        StoryGoal('Hold 10 different coins', 'coins', 10),
      ],
      reward: 50000.0,
      icon: Icons.rocket,
    ),
    StoryChapter(
      id: 7,
      title: 'Crypto Winter',
      subtitle: '2018 - The Crash',
      description: 'The bubble has burst. Prices down 80%. Only the true believers remain. Will you HODL?',
      year: 2018,
      goals: [
        StoryGoal('Survive the crash', 'survive', 1),
        StoryGoal('Buy the dip', 'buy_dip', 1),
      ],
      reward: 10000.0,
      icon: Icons.ac_unit,
    ),
    StoryChapter(
      id: 8,
      title: 'Institutional Era',
      subtitle: '2021 - The Giants Arrive',
      description: 'Tesla, MicroStrategy, and nations are buying Bitcoin. ETFs are coming. The future is here.',
      year: 2021,
      goals: [
        StoryGoal('Reach \$100M net worth', 'networth', 100000000),
        StoryGoal('Max prestige', 'prestige', 10),
      ],
      reward: 1000000.0,
      icon: Icons.business,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Story Mode is temporarily disabled - Coming Soon
    return Scaffold(
      backgroundColor: CyberpunkTheme.backgroundDark,
      appBar: AppBar(
        title: Text('Story Mode', style: GoogleFonts.orbitron()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: const Icon(Icons.auto_stories, size: 100, color: Colors.amber),
              ),
              const SizedBox(height: 32),
              Text(
                'COMING SOON',
                style: GoogleFonts.orbitron(
                  color: Colors.amber,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Coming in v2.0',
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Experience the history of crypto through immersive gameplay.\nFollow Satoshi\'s journey from 2009 to the present day.',
                style: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Use Sandbox Mode for now!',
                  style: GoogleFonts.inter(color: CyberpunkTheme.primaryBlue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildChapterCard(StoryChapter chapter, bool isUnlocked, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUnlocked ? () => _showChapterDetail(chapter) : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isCurrent 
                ? Colors.amber.withOpacity(0.1)
                : isUnlocked 
                  ? CyberpunkTheme.surfaceColor 
                  : CyberpunkTheme.surfaceColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent ? Colors.amber : isUnlocked ? Colors.white10 : Colors.white.withAlpha(13),
                width: isCurrent ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Chapter icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isUnlocked ? Colors.amber.withOpacity(0.2) : Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isUnlocked
                      ? Icon(chapter.icon, color: Colors.amber, size: 32)
                      : const Icon(Icons.lock, color: Colors.white24, size: 24),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Chapter info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isUnlocked ? chapter.title : '???',
                            style: GoogleFonts.orbitron(
                              color: isUnlocked ? Colors.white : Colors.white38,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'CURRENT',
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isUnlocked ? chapter.subtitle : 'Complete previous chapter',
                        style: GoogleFonts.inter(
                          color: isUnlocked ? Colors.white54 : Colors.white24,
                          fontSize: 12,
                        ),
                      ),
                      if (isUnlocked && chapter.goals.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: chapter.goals.take(2).map((goal) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              goal.name,
                              style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                            ),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: isUnlocked ? Colors.white54 : Colors.white10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showChapterDetail(StoryChapter chapter) {
    final gameState = context.read<GameStateProvider>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: CyberpunkTheme.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(chapter.icon, color: Colors.amber, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chapter.title,
                                style: GoogleFonts.orbitron(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                chapter.subtitle,
                                style: GoogleFonts.inter(color: Colors.amber),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Description
                    Text(
                      chapter.description,
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 16, height: 1.5),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Goals
                    Text(
                      'OBJECTIVES',
                      style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...chapter.goals.map((goal) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.circle_outlined, color: Colors.white38, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(goal.name, style: GoogleFonts.inter(color: Colors.white)),
                          ),
                        ],
                      ),
                    )),
                    
                    const SizedBox(height: 24),
                    
                    // Reward
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('REWARD', style: GoogleFonts.inter(color: Colors.amber, fontSize: 11)),
                                Text(
                                  '\$${chapter.reward.toStringAsFixed(0)}',
                                  style: GoogleFonts.orbitron(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Start button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final priceProvider = context.read<CryptoPriceProvider>();
                          final targetDate = DateTime(chapter.year, 1, 1);
                          
                          // Mitigate Arbitrage: If traveling to 2010 with a lot of money, scale it down.
                          // logic modified to support 2009 Genesis Start
                          if (chapter.year == 2009) {
                             // Genesis Start: Reset fully with Genesis Mode enabled
                             gameState.resetGameToGenesis();
                             CryptoToast.info(context, 'Objective: Buy a GPU and Mine the Genesis Block (50 BTC)', icon: Icons.fingerprint);
                          } else if (chapter.year <= 2010 && gameState.balance > 1000) {
                             // Legacy Time Travel Logic for 2010+ chapters (if revisited)
                             final bonus = (gameState.balance * 0.001).clamp(0.0, 500.0);
                             gameState.resetGame(year: chapter.year, initialBalance: 100.0 + bonus);
                          } else {
                             gameState.jumpToDate(targetDate);
                          }
                          
                          Navigator.pop(context);
                          priceProvider.setDate(targetDate); // Sync prices!
                          HapticFeedback.heavyImpact();
                          CryptoToast.info(context, 'Time traveled to ${chapter.year}! Balance scaled for era alignment.', icon: Icons.auto_stories);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'START CHAPTER',
                          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                        ),
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

class StoryChapter {
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final int year;
  final List<StoryGoal> goals;
  final double reward;
  final IconData icon;
  
  const StoryChapter({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.year,
    required this.goals,
    required this.reward,
    required this.icon,
  });
}

class StoryGoal {
  final String name;
  final String type;
  final double target;
  
  const StoryGoal(this.name, this.type, this.target);
}
