import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/cyberpunk_theme.dart';
import 'crypto_logo.dart';

/// Network image loader for real cryptocurrency logos with cool animations
class NetworkCryptoLogo extends StatelessWidget {
  final String? logoUrl;
  final String symbol;
  final double size;
  final bool animate;
  
  const NetworkCryptoLogo({
    super.key,
    this.logoUrl,
    required this.symbol,
    this.size = 40,
    this.animate = true,
  });

  Color _getSymbolColor(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return const Color(0xFFF7931A);
      case 'ETH':
        return const Color(0xFF627EEA);
      case 'BNB':
        return const Color(0xFFF3BA2F);
      case 'XRP':
        return const Color(0xFF23292F);
      case 'ADA':
        return const Color(0xFF0033AD);
      case 'SOL':
        return const Color(0xFF14F195);
      case 'DOGE':
        return const Color(0xFFC2A633);
      case 'MATIC':
        return const Color(0xFF8247E5);
      case 'DOT':
        return const Color(0xFFE6007A);
      case 'LTC':
        return const Color(0xFF345D9D);
      default:
        return CyberpunkTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no logo URL, use custom painted logo
    if (logoUrl == null || logoUrl!.isEmpty) {
      return CryptoLogo(symbol: symbol, size: size);
    }
    
    final symbolColor = _getSymbolColor(symbol);
    
    Widget logoWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: symbolColor.withOpacity(0.4),
            blurRadius: size / 3,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: symbolColor.withOpacity(0.2),
            blurRadius: size / 2,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.95),
              ],
            ),
          ),
          padding: EdgeInsets.all(size * 0.08),
          child: CachedNetworkImage(
            imageUrl: logoUrl!,
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 200),
            maxHeightDiskCache: 200,
            maxWidthDiskCache: 200,
            memCacheHeight: (size * 2).toInt(),
            memCacheWidth: (size * 2).toInt(),
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    symbolColor.withOpacity(0.3),
                    symbolColor.withOpacity(0.1),
                  ],
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: size * 0.4,
                  height: size * 0.4,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: symbolColor,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) {
              // Fallback to custom logo if network image fails
              print('Failed to load logo for $symbol from $url: $error');
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      symbolColor.withOpacity(0.2),
                      CyberpunkTheme.backgroundDark,
                    ],
                  ),
                ),
                child: CryptoLogo(symbol: symbol, size: size * 0.8),
              );
            },
            httpHeaders: const {
              'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
              'Accept': 'image/*',
            },
            errorListener: (error) {
              print('Image error for $symbol: $error');
            },
          ),
        ),
      ),
    );
    
    // Add cool animations if enabled
    if (animate) {
      return logoWidget
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(
          duration: 2000.ms,
          color: symbolColor.withOpacity(0.3),
        )
        .then()
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: 1500.ms,
          curve: Curves.easeInOut,
        );
    }
    
    return logoWidget;
  }
}
