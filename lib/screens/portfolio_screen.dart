import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';
import '../widgets/network_crypto_logo.dart';
import '../widgets/market_lockout_overlay.dart';

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
              
              // Satoshi's Wallet (Genesis coins - unspendable)
              // Only show after first BTC has been mined
              if (gameState.genesisWalletBalance > 0 && (gameState.totalMined['bitcoin'] ?? 0) > 0) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withOpacity(0.15),
                        Colors.orange.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withOpacity(0.4), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.fingerprint, color: Colors.amber, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "SATOSHI'S WALLET",
                                  style: GoogleFonts.orbitron(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  'Genesis Block Coins (Unspendable)',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.amber.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lock, color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'LOCKED',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${gameState.genesisWalletBalance.toStringAsFixed(8)} BTC',
                            style: GoogleFonts.orbitron(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${(gameState.genesisWalletBalance * (priceProvider.getPrice('bitcoin'))).toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'These coins were mined in the Genesis Era and can never be spent. They represent your legacy as Satoshi.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white38,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
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
              Expanded(
                child: Row(
                  children: [
                    NetworkCryptoLogo(
                      logoUrl: crypto.logoUrl,
                      symbol: crypto.symbol,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crypto.symbol,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CyberpunkTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            crypto.name,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: CyberpunkTheme.textTertiary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Max: ${GameStateProvider.maxSupplies[crypto.id]?.toStringAsFixed(0) ?? 'N/A'}',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: CyberpunkTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${value.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CyberpunkTheme.accentGreen,
                    ),
                  ),
                  Text(
                    amount.toStringAsFixed(6),
                    style: GoogleFonts.inter(
                      fontSize: 12,
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
