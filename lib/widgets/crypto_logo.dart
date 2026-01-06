import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/cyberpunk_theme.dart';

/// Beautiful cryptocurrency logos with real colors and designs
class CryptoLogo extends StatelessWidget {
  final String symbol;
  final double size;
  
  const CryptoLogo({
    super.key,
    required this.symbol,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _getGradient(symbol),
        boxShadow: [
          BoxShadow(
            color: _getGradient(symbol).colors.first.withOpacity(0.6),
            blurRadius: size / 4,
            spreadRadius: size / 12,
          ),
        ],
        border: Border.all(
          color: CyberpunkTheme.textPrimary.withOpacity(0.3),
          width: size / 20,
        ),
      ),
      child: Center(
        child: _buildLogo(symbol, size),
      ),
    );
  }
  
  Widget _buildLogo(String symbol, double size) {
    final iconSize = size * 0.6;
    
    switch (symbol.toLowerCase()) {
      case 'bitcoin':
      case 'btc':
        return Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '₿',
              style: TextStyle(
                fontSize: iconSize,
                fontWeight: FontWeight.bold,
                color: CyberpunkTheme.textPrimary,
                shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
              ),
            ),
          ],
        );
        
      case 'ethereum':
      case 'eth':
        return CustomPaint(
          size: Size(iconSize, iconSize),
          painter: EthereumLogoPainter(),
        );
        
      case 'litecoin':
      case 'ltc':
        return Text(
          'Ł',
          style: TextStyle(
            fontSize: iconSize,
            fontWeight: FontWeight.bold,
            color: CyberpunkTheme.textPrimary,
            shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
          ),
        );
        
      case 'dogecoin':
      case 'doge':
        return Text(
          'Ð',
          style: TextStyle(
            fontSize: iconSize,
            fontWeight: FontWeight.bold,
            color: CyberpunkTheme.textPrimary,
            shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
          ),
        );
        
      case 'cardano':
      case 'ada':
        return CustomPaint(
          size: Size(iconSize, iconSize),
          painter: CardanoLogoPainter(),
        );
        
      case 'solana':
      case 'sol':
        return CustomPaint(
          size: Size(iconSize, iconSize),
          painter: SolanaLogoPainter(),
        );
        
      case 'polkadot':
      case 'dot':
        return CustomPaint(
          size: Size(iconSize, iconSize),
          painter: PolkadotLogoPainter(),
        );
        
      case 'polygon':
      case 'matic':
        return CustomPaint(
          size: Size(iconSize, iconSize),
          painter: PolygonLogoPainter(),
        );
        
      case 'ripple':
      case 'xrp':
        return Text(
          '✕',
          style: TextStyle(
            fontSize: iconSize,
            fontWeight: FontWeight.bold,
            color: CyberpunkTheme.textPrimary,
            shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
          ),
        );
        
      case 'binancecoin':
      case 'bnb':
        return CustomPaint(
          size: Size(iconSize, iconSize),
          painter: BinanceLogoPainter(),
        );
        
      default:
        return Text(
          symbol.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontSize: iconSize * 0.8,
            fontWeight: FontWeight.bold,
            color: CyberpunkTheme.textPrimary,
            shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
          ),
        );
    }
  }
  
  LinearGradient _getGradient(String symbol) {
    switch (symbol.toLowerCase()) {
      case 'bitcoin':
      case 'btc':
        return const LinearGradient(
          colors: [Color(0xFFF7931A), Color(0xFFFFB900)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        
      case 'ethereum':
      case 'eth':
        return const LinearGradient(
          colors: [Color(0xFF627EEA), Color(0xFF8FA6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        
      case 'litecoin':
      case 'ltc':
        return const LinearGradient(
          colors: [Color(0xFF345D9D), Color(0xFF5A8FD8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        
      case 'dogecoin':
      case 'doge':
        return const LinearGradient(
          colors: [Color(0xFFC2A633), Color(0xFFE5D85C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        
      case 'cardano':
      case 'ada':
        return const LinearGradient(
          colors: [Color(0xFF0033AD), Color(0xFF3468DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        
      case 'solana':
      case 'sol':
        return const LinearGradient(
          colors: [Color(0xFF00FFA3), Color(0xFF9945FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        
      case 'polkadot':
      case 'dot':
        return const LinearGradient(
          colors: [Color(0xFFE6007A), Color(0xFFFF4DA6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        
      case 'polygon':
      case 'matic':
        return const LinearGradient(
          colors: [Color(0xFF8247E5), Color(0xFFA374FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        
      case 'ripple':
      case 'xrp':
        return const LinearGradient(
          colors: [Color(0xFF23292F), Color(0xFF4B5563)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        
      case 'binancecoin':
      case 'bnb':
        return const LinearGradient(
          colors: [Color(0xFFF3BA2F), Color(0xFFFFD54F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        
      default:
        return LinearGradient(
          colors: [CyberpunkTheme.primaryBlue, CyberpunkTheme.accentPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}

// Custom painters for crypto logos

class EthereumLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Simplified Ethereum diamond shape
    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width * 0.85, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.7);
    path.lineTo(size.width * 0.15, size.height * 0.5);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Bottom half
    final path2 = Path();
    path2.moveTo(size.width * 0.5, size.height * 0.7);
    path2.lineTo(size.width * 0.85, size.height * 0.5);
    path2.lineTo(size.width * 0.5, size.height);
    path2.close();
    
    paint.color = Colors.white.withOpacity(0.8);
    canvas.drawPath(path2, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CardanoLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Central circle
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.2,
      paint,
    );
    
    // Orbiting circles
    final smallRadius = size.width * 0.08;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15), smallRadius, paint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.5), smallRadius, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.85), smallRadius, paint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.5), smallRadius, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SolanaLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;
    
    // Three parallel lines creating gradient effect
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.3),
      paint,
    );
    
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.5),
      paint,
    );
    
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.7),
      Offset(size.width * 0.8, size.height * 0.7),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PolkadotLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;
    final radius = size.width * 0.12;
    
    // 7 circles in hexagonal pattern
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
    canvas.drawCircle(Offset(centerX, centerY - radius * 2), radius * 0.8, paint);
    canvas.drawCircle(Offset(centerX + radius * 1.7, centerY - radius), radius * 0.8, paint);
    canvas.drawCircle(Offset(centerX + radius * 1.7, centerY + radius), radius * 0.8, paint);
    canvas.drawCircle(Offset(centerX, centerY + radius * 2), radius * 0.8, paint);
    canvas.drawCircle(Offset(centerX - radius * 1.7, centerY + radius), radius * 0.8, paint);
    canvas.drawCircle(Offset(centerX - radius * 1.7, centerY - radius), radius * 0.8, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PolygonLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Simplified polygon hexagon
    final path = Path();
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;
    final radius = size.width * 0.4;
    
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * 3.14159 / 180;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BinanceLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final squareSize = size.width * 0.15;
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;
    
    // 5 squares in diamond pattern (Binance logo simplified)
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: squareSize,
        height: squareSize,
      ),
      paint,
    );
    
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY - squareSize * 1.5),
        width: squareSize,
        height: squareSize,
      ),
      paint,
    );
    
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX + squareSize * 1.5, centerY),
        width: squareSize,
        height: squareSize,
      ),
      paint,
    );
    
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY + squareSize * 1.5),
        width: squareSize,
        height: squareSize,
      ),
      paint,
    );
    
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX - squareSize * 1.5, centerY),
        width: squareSize,
        height: squareSize,
      ),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Import dart:math at top of file for cos/sin
