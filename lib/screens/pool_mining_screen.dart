import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/models/mining_pool.dart';
import '../providers/game_state_provider.dart';
import '../widgets/crypto_toast.dart';
/// Pool Mining UI Screen - Visual pool selection
class PoolMiningScreen extends StatelessWidget {
  const PoolMiningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    
    // Pool mining lockout
    if (!gameState.isPoolMiningAvailable) {
      return Scaffold(
        backgroundColor: CyberpunkTheme.backgroundDark,
        appBar: AppBar(
          title: Text('Mining Pools', style: GoogleFonts.orbitron()),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 80, color: Colors.orange.withOpacity(0.6)),
                const SizedBox(height: 24),
                Text(
                  '⛏️ MINING POOLS NOT YET INVENTED',
                  style: GoogleFonts.orbitron(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Slush Pool launches on November 27, 2010.\nAdvance time to unlock pool mining!',
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: CyberpunkTheme.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Current: ${gameState.gameDate.toIso8601String().substring(0, 10)}',
                    style: GoogleFonts.jetBrainsMono(color: CyberpunkTheme.primaryBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: CyberpunkTheme.backgroundDark,
      appBar: AppBar(
        title: Text('Mining Pools', style: GoogleFonts.orbitron()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current pool status
            _buildCurrentPoolCard(gameState),
            const SizedBox(height: 24),
            
            // Pool selection
            Text(
              'Available Pools',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ...MiningPoolDatabase.pools.map((pool) => 
              _buildPoolCard(context, pool, gameState.currentPool.id == pool.id)
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCurrentPoolCard(GameStateProvider gameState) {
    final pool = gameState.currentPool;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CyberpunkTheme.glassmorphismCard(glowColor: CyberpunkTheme.primaryBlue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.groups, color: CyberpunkTheme.primaryBlue, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Pool',
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      pool.name,
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${pool.feePercent.toStringAsFixed(1)}% fee',
                    style: GoogleFonts.inter(color: Colors.orange, fontSize: 14),
                  ),
                  Text(
                    '${(pool.varianceReduction * 100).toInt()}% variance',
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Pending payout
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pending Payout', style: GoogleFonts.inter(color: Colors.white54)),
                Text(
                  '\$${gameState.pendingPoolPayout.toStringAsFixed(4)}',
                  style: GoogleFonts.inter(
                    color: CyberpunkTheme.accentGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPoolCard(BuildContext context, MiningPool pool, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSelected ? null : () {
            context.read<GameStateProvider>().joinPool(pool.id);
            HapticFeedback.mediumImpact();
            CryptoToast.success(context, 'Joined ${pool.name}!', icon: Icons.groups);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                ? CyberpunkTheme.primaryBlue.withOpacity(0.2)
                : CyberpunkTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? CyberpunkTheme.primaryBlue : Colors.white10,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(_getPoolIcon(pool.id), color: _getPoolColor(pool.id), size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            pool.name,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: CyberpunkTheme.accentGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ACTIVE',
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
                        pool.description,
                        style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${pool.feePercent.toStringAsFixed(1)}%',
                      style: GoogleFonts.orbitron(
                        color: pool.feePercent > 0.02 ? Colors.orange : CyberpunkTheme.accentGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('fee', style: GoogleFonts.inter(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  IconData _getPoolIcon(String poolId) {
    switch (poolId) {
      case 'solo': return Icons.person;
      case 'small_pool': return Icons.group;
      case 'large_pool': return Icons.groups;
      case 'mega_pool': return Icons.factory;
      default: return Icons.pool;
    }
  }
  
  Color _getPoolColor(String poolId) {
    switch (poolId) {
      case 'solo': return Colors.orange;
      case 'small_pool': return Colors.blue;
      case 'large_pool': return Colors.green;
      case 'mega_pool': return Colors.purple;
      default: return Colors.grey;
    }
  }
}
