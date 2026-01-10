import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/cyberpunk_theme.dart';

/// Credits screen with developer and API attributions
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint("Could not launch $url");
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  // ... (keeping _showConfirmationDialog as is) ...

  void _showConfirmationDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CyberpunkTheme.surfaceColor,
        title: Text(
          'Visit External Site?',
          style: GoogleFonts.orbitron(
            color: CyberpunkTheme.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to leave the game to visit:',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              url,
              style: GoogleFonts.jetBrainsMono(
                color: CyberpunkTheme.accentGreen,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchUrl(url);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberpunkTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'VISIT SITE',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberpunkTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Credits',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Developer Credit
            _buildSection(
              'CREATED BY',
              [
                  _buildCreditCard(
                    icon: Icons.person,
                    title: 'Vj (@UnLuckvj)',
                    subtitle: 'Game Design, Development & Vision',
                    color: CyberpunkTheme.primaryBlue,
                    onTap: () => _launchUrl('https://unluckvj.xyz/'),
                  ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Data Sources
            _buildSection(
              'DATA SOURCES',
              [
                _buildCreditCard(
                  icon: Icons.api,
                  title: 'CoinGecko API',
                  subtitle: 'Live cryptocurrency prices & market data',
                  color: CyberpunkTheme.accentGreen,
                  onTap: () => _launchUrl('https://www.coingecko.com/en/api'),
                ),
                _buildCreditCard(
                  icon: Icons.calculate,
                  title: 'CoinWarz',
                  subtitle: 'Mining profitability calculators',
                  color: CyberpunkTheme.accentOrange,
                  onTap: () => _launchUrl('https://www.coinwarz.com'),
                ),
                _buildCreditCard(
                  icon: Icons.image,
                  title: 'CryptoLogos.cc',
                  subtitle: 'High-quality cryptocurrency logos',
                  color: Colors.purple,
                  onTap: () => _launchUrl('https://cryptologos.cc'),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Technologies
            _buildSection(
              'BUILT WITH',
              [
                _buildCreditCard(
                  icon: Icons.flutter_dash,
                  title: 'Flutter',
                  subtitle: 'Cross-platform UI framework by Google',
                  color: Colors.blue,
                  onTap: () => _launchUrl('https://flutter.dev'),
                ),
                _buildCreditCard(
                  icon: Icons.storage,
                  title: 'Hive',
                  subtitle: 'Lightweight local database',
                  color: Colors.amber,
                  onTap: () => _launchUrl('https://docs.hivedb.dev'),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Version info
            Center(
              child: Column(
                children: [
                  Text(
                    'Stupid Rigger',
                    style: GoogleFonts.orbitron(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2025 Vj. All rights reserved.',
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.orbitron(
            color: Colors.white54,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildCreditCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.open_in_new, color: color.withOpacity(0.5), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
