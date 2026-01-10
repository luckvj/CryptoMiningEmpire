import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/models/daily_challenges.dart';
import '../providers/game_state_provider.dart';
import '../widgets/crypto_toast.dart';
/// Daily Challenges Screen
class DailyChallengesScreen extends StatefulWidget {
  const DailyChallengesScreen({super.key});

  @override
  State<DailyChallengesScreen> createState() => _DailyChallengesScreenState();
}

class _DailyChallengesScreenState extends State<DailyChallengesScreen> {
  late List<DailyChallenge> _todaysChallenges;
  int _consecutiveDays = 1;
  bool _claimedToday = false;
  
  @override
  void initState() {
    super.initState();
    _todaysChallenges = DailyChallengesDatabase.generateDailyChallenges();
    // Simulate some progress for demo
    _todaysChallenges[0].progress = 50;
    _todaysChallenges[1].progress = 100;
    _todaysChallenges[1].completed = true;
  }

  @override
  Widget build(BuildContext context) {
    final loginReward = DailyLoginRewards.getRewardForDay(_consecutiveDays);
    
    return Scaffold(
      backgroundColor: CyberpunkTheme.backgroundDark,
      appBar: AppBar(
        title: Text('Daily Challenges', style: GoogleFonts.orbitron()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily login reward
            _buildLoginRewardCard(loginReward),
            const SizedBox(height: 24),
            
            // Today's challenges
            Text(
              'TODAY\'S CHALLENGES',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ..._todaysChallenges.map((challenge) => _buildChallengeCard(challenge)),
            
            const SizedBox(height: 24),
            
            // Weekly streak
            _buildWeeklyStreak(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoginRewardCard(DailyLoginReward reward) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CyberpunkTheme.glassmorphismCard(
        glowColor: _claimedToday ? Colors.grey : CyberpunkTheme.accentGreen,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _claimedToday ? Icons.check_circle : Icons.card_giftcard,
                color: _claimedToday ? Colors.grey : CyberpunkTheme.accentGreen,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                _claimedToday ? 'CLAIMED!' : 'DAILY REWARD',
                style: GoogleFonts.orbitron(
                  color: _claimedToday ? Colors.grey : CyberpunkTheme.accentGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (!_claimedToday) ...[
            Text(
              'Day $_consecutiveDays Streak',
              style: GoogleFonts.inter(color: Colors.white54),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${reward.cashReward.toStringAsFixed(0)}',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (reward.bonusType != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+ ${reward.bonusType == 'boost' ? '2x Boost' : '10% GPU Discount'}',
                  style: GoogleFonts.inter(color: Colors.amber, fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _claimedToday = true);
                  context.read<GameStateProvider>().addBalance(reward.cashReward);
                  HapticFeedback.heavyImpact();
                  CryptoToast.success(context, 'Claimed \$${reward.cashReward.toStringAsFixed(0)}!', icon: Icons.card_giftcard);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberpunkTheme.accentGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('CLAIM REWARD', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
              ),
            ),
          ] else ...[
            Text(
              'Come back tomorrow!',
              style: GoogleFonts.inter(color: Colors.white54),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildChallengeCard(DailyChallenge challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: challenge.completed 
          ? CyberpunkTheme.accentGreen.withAlpha(30)
          : CyberpunkTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: challenge.completed ? CyberpunkTheme.accentGreen : Colors.white10,
          width: challenge.completed ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: challenge.completed 
                    ? CyberpunkTheme.accentGreen.withAlpha(50)
                    : CyberpunkTheme.primaryBlue.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  challenge.completed ? Icons.check : _getChallengeIcon(challenge.type),
                  color: challenge.completed ? CyberpunkTheme.accentGreen : CyberpunkTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      challenge.description,
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${challenge.reward.toStringAsFixed(0)}',
                    style: GoogleFonts.orbitron(
                      color: CyberpunkTheme.accentGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('reward', style: GoogleFonts.inter(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: challenge.progressPercent,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation(
                      challenge.completed ? CyberpunkTheme.accentGreen : CyberpunkTheme.primaryBlue,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${challenge.progress.toInt()}/${challenge.target.toInt()}',
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          
          if (challenge.completed && !challenge.completed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Claim reward
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberpunkTheme.accentGreen,
                  foregroundColor: Colors.black,
                ),
                child: const Text('CLAIM'),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildWeeklyStreak() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberpunkTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY STREAK',
            style: GoogleFonts.orbitron(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final isCompleted = index < _consecutiveDays;
              final isToday = index == _consecutiveDays - 1;
              final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted 
                        ? CyberpunkTheme.accentGreen.withAlpha(isToday ? 200 : 100)
                        : Colors.white10,
                      shape: BoxShape.circle,
                      border: isToday ? Border.all(color: CyberpunkTheme.accentGreen, width: 2) : null,
                    ),
                    child: Center(
                      child: isCompleted
                        ? const Icon(Icons.check, color: Colors.black, size: 18)
                        : Text(dayNames[index], style: GoogleFonts.inter(color: Colors.white38)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Day ${index + 1}',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
  
  IconData _getChallengeIcon(String type) {
    switch (type) {
      case 'mine_btc':
      case 'mine_value':
        return Icons.hardware;
      case 'trades':
      case 'trade_profit':
        return Icons.swap_horiz;
      case 'clicks':
        return Icons.touch_app;
      case 'daily_earnings':
        return Icons.attach_money;
      case 'buy_gpu':
        return Icons.memory;
      default:
        return Icons.star;
    }
  }
}
