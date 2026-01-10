import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/services/storage_service.dart';

/// First-time tutorial popup for new players
class TutorialPopup extends StatelessWidget {
  final VoidCallback onDismiss;
  
  const TutorialPopup({super.key, required this.onDismiss});
  
  static const String _hasSeenTutorialKey = 'hasSeenTutorial';
  
  /// Check if user has seen tutorial
  static bool hasSeenTutorial() {
    final settings = StorageService.loadSettings();
    return settings[_hasSeenTutorialKey] ?? false;
  }
  
  /// Mark tutorial as seen
  static Future<void> markAsSeen() async {
    final settings = StorageService.loadSettings();
    settings[_hasSeenTutorialKey] = true;
    await StorageService.saveSettings(settings);
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CyberpunkTheme.backgroundDark,
              CyberpunkTheme.backgroundDark.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CyberpunkTheme.primaryBlue, width: 2),
          boxShadow: [
            BoxShadow(
              color: CyberpunkTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school, color: CyberpunkTheme.accentGreen, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Welcome, Miner! ⛏️',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              
              // Tutorial Steps
              _buildStep('1', '⛏️ TAP & EARN', 'Click the central rig to mine manually.'),
              _buildStep('2', '🖥️ BUILD YOUR RIG', 'Install GPUs & CPUs for auto-mining.'),
              _buildStep('3', '📉 CRYPTO EXCHANGE', 'Trade 50+ coins. Buy Low, Sell High!'),
              _buildStep('4', '🏢 EXPAND EMPIRE', 'Buy real estate to boost power & efficiency.'),
              _buildStep('5', '🕒 MARKET CYCLES', 'Survive historical crashes and bull runs!'),
              
              const SizedBox(height: 24),
              
              // Pro tip
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CyberpunkTheme.accentOrange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: CyberpunkTheme.accentOrange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'TIP: Follow Story Mode for guided progression!',
                        style: GoogleFonts.inter(
                          color: CyberpunkTheme.accentOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Start Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await markAsSeen();
                    onDismiss();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CyberpunkTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'START MINING! 🚀',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
  
  Widget _buildStep(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: CyberpunkTheme.primaryBlue.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: CyberpunkTheme.primaryBlue),
            ),
            child: Center(
              child: Text(
                num,
                style: GoogleFonts.orbitron(
                  color: CyberpunkTheme.primaryBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
