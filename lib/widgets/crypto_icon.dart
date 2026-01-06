import 'package:flutter/material.dart';
import '../core/theme/cyberpunk_theme.dart';

/// Beautiful gradient icons for cryptocurrencies
class CryptoIcon extends StatelessWidget {
  final String symbol;
  final double size;
  
  const CryptoIcon({
    super.key,
    required this.symbol,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getCryptoColors(symbol);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.6),
            blurRadius: size / 4,
            spreadRadius: size / 8,
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getCryptoSymbol(symbol),
          style: TextStyle(
            fontSize: size / 2,
            fontWeight: FontWeight.bold,
            color: CyberpunkTheme.textPrimary,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getCryptoSymbol(String symbol) {
    final symbols = {
      'BTC': '₿',
      'ETH': 'Ξ',
      'LTC': 'Ł',
      'DOGE': 'Ð',
      'ADA': '₳',
      'SOL': '◎',
      'DOT': '●',
      'MATIC': '▲',
      'XRP': '✕',
      'BNB': '▼',
    };
    return symbols[symbol.toUpperCase()] ?? symbol[0].toUpperCase();
  }
  
  List<Color> _getCryptoColors(String symbol) {
    switch (symbol.toLowerCase()) {
      case 'bitcoin':
      case 'btc':
        return [Color(0xFFF7931A), Color(0xFFFFB900)];
      case 'ethereum':
      case 'eth':
        return [Color(0xFF627EEA), Color(0xFF8FA6FF)];
      case 'litecoin':
      case 'ltc':
        return [Color(0xFF345D9D), Color(0xFF4A7BBD)];
      case 'dogecoin':
      case 'doge':
        return [Color(0xFFC2A633), Color(0xFFE5C858)];
      case 'cardano':
      case 'ada':
        return [Color(0xFF0033AD), Color(0xFF2A6FDB)];
      case 'solana':
      case 'sol':
        return [Color(0xFF14F195), Color(0xFF9945FF)];
      case 'polkadot':
      case 'dot':
        return [Color(0xFFE6007A), Color(0xFFFF6BB4)];
      case 'polygon':
      case 'matic':
        return [Color(0xFF8247E5), Color(0xFF9F5FFF)];
      case 'ripple':
      case 'xrp':
        return [Color(0xFF23292F), Color(0xFF4B5563)];
      case 'binancecoin':
      case 'bnb':
        return [Color(0xFFF3BA2F), Color(0xFFFFD24A)];
      default:
        return [CyberpunkTheme.primaryBlue, CyberpunkTheme.accentPurple];
    }
  }
}
