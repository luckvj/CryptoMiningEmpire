import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme/cyberpunk_theme.dart';
import 'crypto_logo.dart';

/// Network image loader for real cryptocurrency logos from APIs
class NetworkCryptoLogo extends StatelessWidget {
  final String? logoUrl;
  final String symbol;
  final double size;
  
  const NetworkCryptoLogo({
    super.key,
    this.logoUrl,
    required this.symbol,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    // If no logo URL, use custom painted logo
    if (logoUrl == null || logoUrl!.isEmpty) {
      return CryptoLogo(symbol: symbol, size: size);
    }
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: CyberpunkTheme.primaryBlue.withOpacity(0.4),
            blurRadius: size / 4,
            spreadRadius: size / 12,
          ),
        ],
      ),
      child: ClipOval(
        child: Container(
          color: CyberpunkTheme.textPrimary,
          padding: EdgeInsets.all(size * 0.1),
          child: Image.network(
            logoUrl!,
            width: size,
            height: size,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: CyberpunkTheme.primaryBlue,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              // Fallback to custom logo if network image fails
              return CryptoLogo(symbol: symbol, size: size);
            },
          ),
        ),
      ),
    );
  }
}
