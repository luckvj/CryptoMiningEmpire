// Price alerts system
import 'package:flutter/foundation.dart';

enum PriceAlertType { above, below }

class PriceAlert {
  final String id;
  final String coinId;
  final String coinName;
  final double targetPrice;
  final PriceAlertType type;
  final DateTime createdAt;
  bool triggered;
  bool notified;
  
  PriceAlert({
    required this.id,
    required this.coinId,
    required this.coinName,
    required this.targetPrice,
    required this.type,
    required this.createdAt,
    this.triggered = false,
    this.notified = false,
  });
  
  /// Check if alert should trigger based on current price
  bool shouldTrigger(double currentPrice) {
    if (triggered) return false;
    
    switch (type) {
      case PriceAlertType.above:
        return currentPrice >= targetPrice;
      case PriceAlertType.below:
        return currentPrice <= targetPrice;
    }
  }
  
  String get typeLabel => type == PriceAlertType.above ? 'above' : 'below';
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'coinId': coinId,
    'coinName': coinName,
    'targetPrice': targetPrice,
    'type': type.index,
    'createdAt': createdAt.toIso8601String(),
    'triggered': triggered,
    'notified': notified,
  };
  
  factory PriceAlert.fromJson(Map<String, dynamic> json) {
    return PriceAlert(
      id: json['id'],
      coinId: json['coinId'],
      coinName: json['coinName'] ?? '',
      targetPrice: (json['targetPrice'] ?? 0).toDouble(),
      type: PriceAlertType.values[json['type'] ?? 0],
      createdAt: DateTime.parse(json['createdAt']),
      triggered: json['triggered'] ?? false,
      notified: json['notified'] ?? false,
    );
  }
}

/// Manages price alerts
class PriceAlertManager extends ChangeNotifier {
  final List<PriceAlert> _alerts = [];
  
  List<PriceAlert> get alerts => List.unmodifiable(_alerts);
  List<PriceAlert> get activeAlerts => _alerts.where((a) => !a.triggered).toList();
  List<PriceAlert> get triggeredAlerts => _alerts.where((a) => a.triggered).toList();
  
  /// Add a new price alert
  void addAlert(PriceAlert alert) {
    _alerts.add(alert);
    notifyListeners();
  }
  
  /// Remove an alert
  void removeAlert(String alertId) {
    _alerts.removeWhere((a) => a.id == alertId);
    notifyListeners();
  }
  
  /// Check all alerts against current prices
  List<PriceAlert> checkAlerts(Map<String, double> currentPrices) {
    final triggered = <PriceAlert>[];
    
    for (final alert in _alerts) {
      if (alert.triggered) continue;
      
      final price = currentPrices[alert.coinId];
      if (price != null && alert.shouldTrigger(price)) {
        alert.triggered = true;
        triggered.add(alert);
      }
    }
    
    if (triggered.isNotEmpty) {
      notifyListeners();
    }
    
    return triggered;
  }
  
  /// Mark alert as notified
  void markNotified(String alertId) {
    final alert = _alerts.firstWhere((a) => a.id == alertId, orElse: () => throw Exception('Alert not found'));
    alert.notified = true;
    notifyListeners();
  }
  
  /// Clear all triggered alerts
  void clearTriggered() {
    _alerts.removeWhere((a) => a.triggered);
    notifyListeners();
  }
  
  /// Load alerts from JSON
  void loadFromJson(List<dynamic> json) {
    _alerts.clear();
    for (final item in json) {
      _alerts.add(PriceAlert.fromJson(item));
    }
    notifyListeners();
  }
  
  /// Convert to JSON for saving
  List<Map<String, dynamic>> toJson() {
    return _alerts.map((a) => a.toJson()).toList();
  }
}
