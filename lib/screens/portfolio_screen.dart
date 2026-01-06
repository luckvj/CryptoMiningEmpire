import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';

/// Portfolio screen showing all cryptocurrency holdings
class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    final priceProvider = context.watch<CryptoPriceProvider>();
    
    final prices = priceProvider.cryptoData.map((k, v) => MapEntry(k, v.price));
    final netWorth = gameState.calculateNetWorth(prices);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PORTFOLIO'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Net Worth Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: CyberpunkTheme.modernCard(),
              child: Column(
                children: [
                  Text(
                    'TOTAL NET WORTH',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: CyberpunkTheme.textTertiary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${netWorth.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: CyberpunkTheme.accentGreen,
                      ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickStat(
                        label: 'Cash',
                        value: '\$${gameState.balance.toStringAsFixed(2)}',
                        color: CyberpunkTheme.primaryBlue,
                      ),
                      _QuickStat(
                        label: 'Crypto',
                        value: '\$${(netWorth - gameState.balance).toStringAsFixed(2)}',
                        color: CyberpunkTheme.accentOrange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Holdings Title
            Text(
              'YOUR HOLDINGS',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CyberpunkTheme.primaryBlue,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Holdings List
            ...gameState.holdings.entries.map((entry) {
              final cryptoData = priceProvider.getCrypto(entry.key);
              if (cryptoData == null) return const SizedBox.shrink();
              
              final amount = entry.value;
              final value = amount * cryptoData.price;
              final totalMined = gameState.totalMined[entry.key] ?? 0.0;
              
              return _HoldingCard(
                crypto: cryptoData,
                amount: amount,
                value: value,
                totalMined: totalMined,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  
  const _QuickStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            color: CyberpunkTheme.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _HoldingCard extends StatelessWidget {
  final dynamic crypto;
  final double amount;
  final double value;
  final double totalMined;
  
  const _HoldingCard({
    required this.crypto,
    required this.amount,
    required this.value,
    required this.totalMined,
  });

  @override
  Widget build(BuildContext context) {
    if (amount == 0 && totalMined == 0) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: CyberpunkTheme.modernCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CyberpunkTheme.primaryBlue.withOpacity(0.2),
                      border: Border.all(color: CyberpunkTheme.primaryBlue),
                    ),
                    child: Center(
                      child: Text(
                        crypto.symbol.substring(0, 1),
                        style: GoogleFonts.inter(
                          color: CyberpunkTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crypto.symbol,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CyberpunkTheme.textPrimary,
                        ),
                      ),
                      Text(
                        crypto.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: CyberpunkTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${value.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CyberpunkTheme.accentGreen,
                    ),
                  ),
                  Text(
                    '${amount.toStringAsFixed(8)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: CyberpunkTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (totalMined > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CyberpunkTheme.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: CyberpunkTheme.accentOrange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.settings_input_antenna,
                    size: 16,
                    color: CyberpunkTheme.accentOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mined: ${totalMined.toStringAsFixed(8)} ${crypto.symbol}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: CyberpunkTheme.accentOrange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
