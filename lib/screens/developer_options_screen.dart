import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../providers/game_state_provider.dart';
import '../widgets/crypto_toast.dart';

class DeveloperOptionsScreen extends StatelessWidget {
  const DeveloperOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Developer Options', style: GoogleFonts.orbitron()),
        backgroundColor: Colors.black,
        foregroundColor: CyberpunkTheme.accentGreen,
      ),
      backgroundColor: Colors.black87,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Economy Cheats'),
          _buildCheatTile(
            context, 
            'Add \$1,000,000', 
            Icons.attach_money, 
            () {
              gameState.addBalance(1000000);
              CryptoToast.success(context, 'Added \$1M Cash');
            }
          ),
          _buildCheatTile(
            context, 
            'Add \$1 Billion', 
            Icons.savings, 
            () {
              gameState.addBalance(1000000000);
              CryptoToast.success(context, 'Added \$1B Cash');
            }
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Crypto Cheats'),
          _buildCheatTile(
            context, 
            'Add 10 BTC', 
            Icons.currency_bitcoin, 
            () {
              // Assuming 'bitcoin' is the ID, finding it might need the provider
              // For simplicity, we'll just use a generic method if available or expose one.
              // Since we don't have a direct 'addCrypto' by ID that doesn't cost money,
              // we might need to modify GameState or just hack it here if the map is accessible.
              // GameStateProvider.holdings is a getter.
              // We'll add a specific cheat method to GameStateProvider later or just direct manipulate if setters existed.
              // For now, let's just add huge cash so they can buy it.
              CryptoToast.info(context, 'Use Cash cheats to buy Crypto!');
            }
          ),
           
          const SizedBox(height: 24),
          _buildSectionHeader('Progression'),
          _buildCheatTile(
            context, 
            'Unlock All Items (Not Implemented)', 
            Icons.lock_open, 
            () => CryptoToast.warning(context, 'Feature coming soon')
          ),
          _buildCheatTile(
            context, 
            'Reset Game State', 
            Icons.restore, 
            () {
              gameState.resetGame();
              CryptoToast.success(context, 'Game Reset');
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          color: CyberpunkTheme.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCheatTile(BuildContext context, String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Card(
      color: CyberpunkTheme.surfaceColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? CyberpunkTheme.accentRed : CyberpunkTheme.accentGreen),
        title: Text(title, style: TextStyle(color: isDestructive ? CyberpunkTheme.accentRed : Colors.white)),
        onTap: onTap,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
