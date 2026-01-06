import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/models/location_data.dart';
import '../core/utils/animations.dart';

/// Widget to display current mining location with visual
class LocationDisplay extends StatelessWidget {
  final LocationData location;
  final LocationData? nextLocation;
  final double progress;
  
  const LocationDisplay({
    super.key,
    required this.location,
    this.nextLocation,
    required this.progress,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: CyberpunkTheme.modernCard(withGlow: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CyberpunkTheme.backgroundDark,
                    CyberpunkTheme.backgroundLight,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  // Location illustration
                  Center(
                    child: _buildLocationIllustration(location.id),
                  ),
                  // Location badge
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: CyberpunkTheme.primaryBlue.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: CyberpunkTheme.primaryLight,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'CURRENT LOCATION',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Location Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Name
                Text(
                  location.name,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CyberpunkTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Description
                Text(
                  location.description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: CyberpunkTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Bonuses
                Row(
                  children: [
                    _buildBonus(
                      icon: Icons.speed,
                      label: 'Hashrate',
                      value: '+${((location.hashRateBonus - 1) * 100).toStringAsFixed(0)}%',
                      color: CyberpunkTheme.accentGreen,
                    ),
                    const SizedBox(width: 16),
                    _buildBonus(
                      icon: Icons.bolt,
                      label: 'Power Cost',
                      value: '-${((1 - location.powerCostMultiplier) * 100).toStringAsFixed(0)}%',
                      color: CyberpunkTheme.accentOrange,
                    ),
                  ],
                ),
                
                // Next location progress
                if (nextLocation != null) ...[
                  const SizedBox(height: 24),
                  const Divider(color: CyberpunkTheme.dividerColor),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Next: ${nextLocation!.name}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CyberpunkTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: CyberpunkTheme.surfaceColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        CyberpunkTheme.primaryBlue,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Requirements: \$${_formatNumber(nextLocation!.requiredNetWorth)} net worth, ${nextLocation!.requiredGPUs} GPUs',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: CyberpunkTheme.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBonus({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CyberpunkTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: CyberpunkTheme.textTertiary,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
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
  
  Widget _buildLocationIllustration(String locationId) {
    // Create SVG-like illustrations using Flutter widgets
    switch (locationId) {
      case 'bedroom':
        return _BedroomIllustration();
      case 'garage':
        return _GarageIllustration();
      case 'basement':
        return _BasementIllustration();
      case 'warehouse':
        return _WarehouseIllustration();
      case 'data_center':
        return _DataCenterIllustration();
      case 'mega_facility':
        return _MegaFacilityIllustration();
      default:
        return _BedroomIllustration();
    }
  }
  
  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

// Simple illustrations using Flutter widgets
class _BedroomIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.bed, size: 80, color: CyberpunkTheme.primaryBlue.withOpacity(0.6)),
        const SizedBox(height: 8),
        Icon(Icons.computer, size: 40, color: CyberpunkTheme.accentGreen.withOpacity(0.6)),
      ],
    );
  }
}

class _GarageIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.garage, size: 80, color: CyberpunkTheme.primaryBlue.withOpacity(0.6)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.memory, size: 30, color: CyberpunkTheme.accentGreen.withOpacity(0.6)),
            const SizedBox(width: 8),
            Icon(Icons.memory, size: 30, color: CyberpunkTheme.accentGreen.withOpacity(0.6)),
            const SizedBox(width: 8),
            Icon(Icons.memory, size: 30, color: CyberpunkTheme.accentGreen.withOpacity(0.6)),
          ],
        ),
      ],
    );
  }
}

class _BasementIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.home, size: 80, color: CyberpunkTheme.primaryBlue.withOpacity(0.6)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.developer_board, size: 24, color: CyberpunkTheme.accentGreen.withOpacity(0.6)),
            ),
          ),
        ),
      ],
    );
  }
}

class _WarehouseIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.warehouse, size: 80, color: CyberpunkTheme.primaryBlue.withOpacity(0.6)),
        const SizedBox(height: 8),
        Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  6,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: CyberpunkTheme.accentGreen.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DataCenterIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.business, size: 80, color: CyberpunkTheme.primaryBlue.withOpacity(0.6)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dns, size: 40, color: CyberpunkTheme.accentGreen.withOpacity(0.6)),
            const SizedBox(width: 8),
            Icon(Icons.dns, size: 40, color: CyberpunkTheme.accentGreen.withOpacity(0.6)),
            const SizedBox(width: 8),
            Icon(Icons.dns, size: 40, color: CyberpunkTheme.accentGreen.withOpacity(0.6)),
          ],
        ),
      ],
    );
  }
}

class _MegaFacilityIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.factory, size: 80, color: CyberpunkTheme.accentOrange.withOpacity(0.8)),
        const SizedBox(height: 8),
        Column(
          children: List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  8,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: CyberpunkTheme.accentGreen.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
