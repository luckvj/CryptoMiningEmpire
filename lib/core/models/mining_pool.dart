// Mining pool system for Crypto Mining Empire

class MiningPool {
  final String id;
  final String name;
  final String description;
  final double feePercent; // 0-3%
  final double varianceReduction; // Lower = steadier payouts (0.1-1.0)
  final double minPayoutCoins; // Minimum payout threshold in COINS
  final String difficulty; // 'solo', 'vardiff', 'fixed'
  
  const MiningPool({
    required this.id,
    required this.name,
    required this.description,
    required this.feePercent,
    required this.varianceReduction,
    required this.minPayoutCoins,
    required this.difficulty,
  });
  
  /// Calculate actual payout after fees
  double calculatePayout(double rawReward) {
    return rawReward * (1 - feePercent / 100);
  }
  
  /// Apply variance to payout (simulates pool luck)
  double applyVariance(double basePayout, double randomValue) {
    // randomValue should be 0.0 to 1.0
    // With high variance (1.0), payouts swing wildly
    // With low variance (0.1), payouts are very steady
    final swing = (randomValue - 0.5) * 2 * varianceReduction; // -1 to 1 * variance
    return basePayout * (1 + swing);
  }
}

class MiningPoolDatabase {
  static const List<MiningPool> pools = [
    MiningPool(
      id: 'solo',
      name: 'Solo Mining',
      description: 'Mine alone. High risk, high reward. You keep 100% but payouts are rare.',
      feePercent: 0.0,
      varianceReduction: 1.0, // Maximum variance
      minPayoutCoins: 0.0,
      difficulty: 'solo',
    ),
    MiningPool(
      id: 'small_pool',
      name: 'Small Pool',
      description: 'Community pool. 1% fee. Moderate variance.',
      feePercent: 1.0,
      varianceReduction: 0.5, // Medium variance
      minPayoutCoins: 0.0001, // 0.0001 coins
      difficulty: 'vardiff',
    ),
    MiningPool(
      id: 'large_pool',
      name: 'Large Pool',
      description: 'Major pool operator. 2% fee. Steady payouts.',
      feePercent: 2.0,
      varianceReduction: 0.2, // Low variance
      minPayoutCoins: 0.001, // 0.001 coins
      difficulty: 'vardiff',
    ),
    MiningPool(
      id: 'mega_pool',
      name: 'Mega Pool',
      description: 'Industrial scale. 3% fee. Very predictable income.',
      feePercent: 3.0,
      varianceReduction: 0.1, // Minimal variance
      minPayoutCoins: 0.01, // 0.01 coins
      difficulty: 'fixed',
    ),
  ];
  
  static MiningPool? getById(String id) {
    try {
      return pools.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  static MiningPool get solo => pools.first;
}
