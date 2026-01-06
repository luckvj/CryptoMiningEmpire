import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';

/// Provider for managing cryptocurrency prices and historical data
class CryptoPriceProvider extends ChangeNotifier {
  Map<String, CryptoData> _cryptoData = {};
  Map<String, List<PricePoint>> _historicalData = {};
  bool _isLoading = true;
  String? _error;
  Timer? _priceUpdateTimer;
  
  CryptoPriceProvider() {
    _initializePrices();
  }
  
  // Getters
  Map<String, CryptoData> get cryptoData => Map.unmodifiable(_cryptoData);
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  CryptoData? getCrypto(String id) => _cryptoData[id];
  double getPrice(String id) => _cryptoData[id]?.price ?? 0.0;
  List<PricePoint>? getHistoricalData(String id) => _historicalData[id];
  
  /// Initialize and start fetching prices
  Future<void> _initializePrices() async {
    await fetchAllPrices();
    _startPriceUpdates();
  }
  
  /// Fetch all cryptocurrency prices
  Future<void> fetchAllPrices() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _cryptoData = await ApiService.fetchAllPrices();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch prices: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Fetch historical data for a specific crypto
  Future<void> fetchHistoricalData(String cryptoId, int days) async {
    try {
      final data = await ApiService.fetchHistoricalData(cryptoId, days);
      _historicalData[cryptoId] = data;
      notifyListeners();
    } catch (e) {
      print('Error fetching historical data: $e');
    }
  }
  
  /// Start automatic price updates
  void _startPriceUpdates() {
    _priceUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => fetchAllPrices(),
    );
  }
  
  /// Get top gainers
  List<CryptoData> getTopGainers({int limit = 10}) {
    final sorted = _cryptoData.values.toList()
      ..sort((a, b) => b.change24h.compareTo(a.change24h));
    return sorted.take(limit).toList();
  }
  
  /// Get top losers
  List<CryptoData> getTopLosers({int limit = 10}) {
    final sorted = _cryptoData.values.toList()
      ..sort((a, b) => a.change24h.compareTo(b.change24h));
    return sorted.take(limit).toList();
  }
  
  /// Search cryptocurrencies
  List<CryptoData> searchCrypto(String query) {
    if (query.isEmpty) return _cryptoData.values.toList();
    
    final lowerQuery = query.toLowerCase();
    return _cryptoData.values.where((crypto) {
      return crypto.name.toLowerCase().contains(lowerQuery) ||
             crypto.symbol.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  @override
  void dispose() {
    _priceUpdateTimer?.cancel();
    super.dispose();
  }
}
