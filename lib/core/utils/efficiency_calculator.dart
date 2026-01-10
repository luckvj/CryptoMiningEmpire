/// Efficiency Calculator for Mining Equipment
/// Calculates hash/watt ratios and profitability metrics
class EfficiencyCalculator {
  /// Calculate efficiency (hash rate per watt)
  /// Returns MH/s per watt
  static double calculateEfficiency(double hashRate, double powerWatts) {
    if (powerWatts == 0) return 0.0;
    return hashRate / powerWatts;
  }
  
  /// Calculate efficiency score (0-100)
  /// Higher is better
  static int calculateEfficiencyScore(double hashRate, double powerWatts) {
    final efficiency = calculateEfficiency(hashRate, powerWatts);
    
    // Benchmarks for scoring
    // Poor: < 0.15 MH/W
    // Fair: 0.15 - 0.25 MH/W
    // Good: 0.25 - 0.35 MH/W
    // Great: 0.35 - 0.50 MH/W
    // Excellent: > 0.50 MH/W
    
    if (efficiency < 0.15) return (efficiency / 0.15 * 40).round();
    if (efficiency < 0.25) return 40 + ((efficiency - 0.15) / 0.10 * 20).round();
    if (efficiency < 0.35) return 60 + ((efficiency - 0.25) / 0.10 * 15).round();
    if (efficiency < 0.50) return 75 + ((efficiency - 0.35) / 0.15 * 15).round();
    return 90 + ((efficiency - 0.50) / 0.50 * 10).round().clamp(0, 10);
  }
  
  /// Get efficiency rating text
  static String getEfficiencyRating(double hashRate, double powerWatts) {
    final efficiency = calculateEfficiency(hashRate, powerWatts);
    
    if (efficiency < 0.15) return 'Poor';
    if (efficiency < 0.25) return 'Fair';
    if (efficiency < 0.35) return 'Good';
    if (efficiency < 0.50) return 'Great';
    return 'Excellent';
  }
  
  /// Get efficiency rating color
  static String getEfficiencyColor(double hashRate, double powerWatts) {
    final efficiency = calculateEfficiency(hashRate, powerWatts);
    
    if (efficiency < 0.15) return '#ef4444'; // Red
    if (efficiency < 0.25) return '#f59e0b'; // Orange
    if (efficiency < 0.35) return '#eab308'; // Yellow
    if (efficiency < 0.50) return '#22c55e'; // Green
    return '#10b981'; // Bright Green
  }
  
  /// Calculate daily power cost in USD
  static double calculateDailyPowerCost(double powerWatts, double electricityRate) {
    // powerWatts * 24 hours / 1000 (to kW) * rate
    return (powerWatts * 24 / 1000) * electricityRate;
  }
  
  /// Calculate daily revenue in USD (based on hashrate and coin price)
  static double calculateDailyRevenue(
    double hashRate,
    double coinPrice,
    double networkHashrate,
    double blockReward,
    double blockTime,
  ) {
    if (networkHashrate == 0 || blockTime == 0) return 0.0;
    
    // Your share of network
    final yourShare = hashRate / networkHashrate;
    
    // Blocks per day
    final blocksPerDay = 86400 / blockTime;
    
    // Expected coins per day
    final coinsPerDay = blocksPerDay * blockReward * yourShare;
    
    // Revenue in USD
    return coinsPerDay * coinPrice;
  }
  
  /// Calculate daily profit (revenue - power cost)
  static double calculateDailyProfit(
    double hashRate,
    double powerWatts,
    double coinPrice,
    double networkHashrate,
    double blockReward,
    double blockTime,
    double electricityRate,
  ) {
    final revenue = calculateDailyRevenue(
      hashRate,
      coinPrice,
      networkHashrate,
      blockReward,
      blockTime,
    );
    
    final powerCost = calculateDailyPowerCost(powerWatts, electricityRate);
    
    return revenue - powerCost;
  }
  
  /// Calculate break-even time in days
  static double calculateBreakEvenDays(
    double hardwareCost,
    double dailyProfit,
  ) {
    if (dailyProfit <= 0) return double.infinity;
    return hardwareCost / dailyProfit;
  }
  
  /// Calculate ROI (Return on Investment) percentage after given days
  static double calculateROI(
    double hardwareCost,
    double dailyProfit,
    int days,
  ) {
    if (hardwareCost == 0) return 0.0;
    final totalProfit = dailyProfit * days;
    return (totalProfit / hardwareCost) * 100;
  }
  
  /// Format efficiency for display
  static String formatEfficiency(double hashRate, double powerWatts) {
    final efficiency = calculateEfficiency(hashRate, powerWatts);
    return '${efficiency.toStringAsFixed(2)} MH/W';
  }
  
  /// Compare two GPUs and return which is more efficient
  static Map<String, dynamic> compareGPUs(
    Map<String, dynamic> gpu1,
    Map<String, dynamic> gpu2,
  ) {
    final eff1 = calculateEfficiency(
      gpu1['hashRate'].toDouble(),
      gpu1['power'].toDouble(),
    );
    final eff2 = calculateEfficiency(
      gpu2['hashRate'].toDouble(),
      gpu2['power'].toDouble(),
    );
    
    final costPerHash1 = gpu1['cost'] / gpu1['hashRate'];
    final costPerHash2 = gpu2['cost'] / gpu2['hashRate'];
    
    return {
      'moreEfficient': eff1 > eff2 ? gpu1['name'] : gpu2['name'],
      'efficiencyDiff': ((eff1 - eff2).abs() / eff2 * 100).toStringAsFixed(1),
      'betterValue': costPerHash1 < costPerHash2 ? gpu1['name'] : gpu2['name'],
      'valueDiff': ((costPerHash1 - costPerHash2).abs() / costPerHash2 * 100).toStringAsFixed(1),
    };
  }
  
  /// Get recommended GPUs based on budget and efficiency preference
  static List<Map<String, dynamic>> getRecommendedGPUs(
    List<Map<String, dynamic>> allGPUs,
    double budget,
    String priority, // 'efficiency', 'performance', 'value'
  ) {
    // Filter by budget
    final affordable = allGPUs.where((gpu) => gpu['cost'] <= budget).toList();
    
    // Sort based on priority
    switch (priority) {
      case 'efficiency':
        affordable.sort((a, b) {
          final effA = calculateEfficiency(a['hashRate'].toDouble(), a['power'].toDouble());
          final effB = calculateEfficiency(b['hashRate'].toDouble(), b['power'].toDouble());
          return effB.compareTo(effA); // Descending
        });
        break;
      case 'performance':
        affordable.sort((a, b) => b['hashRate'].compareTo(a['hashRate'])); // Descending
        break;
      case 'value':
        affordable.sort((a, b) {
          final valueA = a['hashRate'] / a['cost'];
          final valueB = b['hashRate'] / b['cost'];
          return valueB.compareTo(valueA); // Descending
        });
        break;
    }
    
    return affordable.take(3).toList();
  }
}
