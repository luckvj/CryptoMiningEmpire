import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/services/api_service.dart';
import '../core/theme/cyberpunk_theme.dart';
import 'network_crypto_logo.dart';

/// List tile for displaying cryptocurrency information
class CryptoListTile extends StatelessWidget {
  final CryptoData crypto;
  
  const CryptoListTile({super.key, required this.crypto});

  @override
  Widget build(BuildContext context) {
    final isPositive = crypto.isPriceUp;
    final changeColor = isPositive ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentOrange;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: CyberpunkTheme.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: changeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: NetworkCryptoLogo(
          logoUrl: crypto.logoUrl,
          symbol: crypto.symbol,
          size: 50,
        ),
        title: Text(
          crypto.symbol,
          style: GoogleFonts.inter(
            color: CyberpunkTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          crypto.name,
          style: GoogleFonts.inter(
            color: CyberpunkTheme.textTertiary,
            fontSize: 14,
          ),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${crypto.price.toStringAsFixed(crypto.price < 1 ? 6 : 2)}',
              style: GoogleFonts.inter(
                color: CyberpunkTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: changeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: changeColor.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: changeColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${crypto.change24h.abs().toStringAsFixed(2)}%',
                    style: GoogleFonts.inter(
                      color: changeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
