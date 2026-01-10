import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../core/models/historical_data.dart';
import '../core/config/game_config.dart';

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

  bool _isSyncing = false;
  bool _pricesLockedUntilDateChange = false; // Attempt 6: Freeze prices after sync

  /// Explicitly sync market data from API (used for time travel / present day sync)
  Future<void> syncMarket() async {
    if (_isSyncing) return;
    
    // Debounce: Don't sync more than once every 10 seconds unless forced
    final now = DateTime.now();
    if (now.difference(_lastApiFetch).inSeconds < 10) {
      return;
    }

    _isSyncing = true;
    try {
      await fetchAllPrices(force: true);
      _pricesLockedUntilDateChange = true; // Lock prices after successful sync
    } finally {
      _isSyncing = false;
    }
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
    await fetchAllPrices(force: true); // Force initial fetch to get metadata and set historical prices
    _startPriceUpdates();
  }
  
  int _year = 2009; // Default to Genesis Era for proper initialization
  DateTime _lastApiFetch = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _currentDate = GameConfig.dateGenesisCheck; // Default to Genesis Era
  Timer? _volatilityTimer;
  final Random _random = Random();
  double _volatilityMultiplier = 1.0;
  double _timeSpeed = 0.0; // Attempt 7: Track time speed for price freezing
  
  // Getter for current simulation date
  DateTime get currentDate => _currentDate;
  int get currentYear => _year;
  double get volatilityMultiplier => _volatilityMultiplier;
  double get timeSpeed => _timeSpeed;

  void setTimeSpeed(double speed) {
    _timeSpeed = speed;
    notifyListeners();
  }

  void setVolatilityMultiplier(double multiplier) {
    _volatilityMultiplier = multiplier;
    notifyListeners();
  }

  void resetVolatility() {
    _volatilityMultiplier = 1.0;
    notifyListeners();
  }

  /// Get only coins that existed at the current game date
  Map<String, CryptoData> getAvailableCoins() {
    return Map.fromEntries(
      _cryptoData.entries.where((entry) => 
        HistoricalPriceData.coinExistsAt(entry.value.id, _currentDate)
      )
    );
  }
  
  /// Check if a specific coin is available at current date
  bool isCoinAvailable(String coinId) {
    return HistoricalPriceData.coinExistsAt(coinId, _currentDate);
  }

  /// Set the simulation year (static mode)
  void setYear(int year) {
    final oldYear = _year;
    _year = year;
    _currentDate = DateTime(year, 1, 1);
    
    // Apply volatility scale based on year gap
    final jumpMagnitude = (year - oldYear).abs().toDouble();
    fetchAllPrices(jumpMagnitude: jumpMagnitude);
  }
  
  /// Set the simulation date (dynamic mode)
  void setDate(DateTime date) {
    // Prevent unnecessary refreshes if the date hasn't progressed
    if (date.year == _currentDate.year && 
        date.month == _currentDate.month && 
        date.day == _currentDate.day) {
      return;
    }

    final oldDate = _currentDate;
    _currentDate = date;
    _year = date.year;
    
    // Unlock prices when the date progresses
    if (date.day != oldDate.day || date.month != oldDate.month || date.year != oldDate.year) {
      _pricesLockedUntilDateChange = false;
    }
    
    // Check for "jump" (e.g. time travel) vs normal progression
    final dayGap = (date.difference(oldDate).inDays).abs();
    
    // If it's a reset (same date or returning to present from far away),
    // or if it's just normal 1-day step, keep jumpMagnitude regulated.
    final jumpMagnitude = dayGap > 1 ? (dayGap / 30.0) : 0.0;

    // If in present/future era, fetch real prices
    if (_year >= GameConfig.defaultStartYear) {
      // Force a full fetch if we just arrived at the present from history
      final bool justArrivedAtPresent = oldDate != null && oldDate.year < GameConfig.defaultStartYear;
      fetchAllPrices(jumpMagnitude: 0.0, force: justArrivedAtPresent); 
    } else {
      _updatePricesForDate(jumpMagnitude: jumpMagnitude, oldDate: oldDate);
    }
  }
  
  /// Apply a market event's price impact
  void applyMarketEvent(MarketEvent event) {
    _cryptoData = _cryptoData.map((key, value) {
      final impact = event.priceImpact[value.id] ?? 0.0;
      if (impact == 0.0) return MapEntry(key, value);
      
      final newPrice = value.price * (1 + impact);
      return MapEntry(key, CryptoData(
        id: value.id,
        name: value.name,
        symbol: value.symbol,
        price: newPrice > 0 ? newPrice : 0.000001,
        change24h: impact * 100, // Show impact as % change
        logoUrl: value.logoUrl,
        marketCap: value.marketCap * (1 + impact),
      ));
    });
    _enforcePegs();
    notifyListeners();
  }
  
  /// Apply random volatility to all prices (±5%)
  void _applyVolatility({double scale = 1.0}) {
    // Attempt 7: Strictly freeze prices if the game is paused or speed is 0
    if (_timeSpeed <= 0) return;

    // Only apply random volatility in the present/future era
    if (_year < GameConfig.defaultStartYear) return;
    
    // Attempt 6: Block background volatility if prices are locked after a sync
    if (_pricesLockedUntilDateChange) return;

    _cryptoData = _cryptoData.map((key, value) {
      // Base volatility is 5%. Scaled by volatilityMultiplier and jump scale.
      final effectiveScale = _volatilityMultiplier * scale;
      final maxSwing = GameConfig.volatilityBaseSwing * effectiveScale;
      final volatility = (value.symbol.toUpperCase() == 'USDT' || value.id == 'tether') 
          ? 1.0 
          : (1.0 - maxSwing) + _random.nextDouble() * (maxSwing * 2);
      final change = (volatility - 1.0) * 100;
      
      return MapEntry(key, CryptoData(
        id: value.id,
        name: value.name,
        symbol: value.symbol,
        price: (value.symbol.toUpperCase() == 'USDT' || value.id == 'tether') ? 1.0 : value.price * volatility,
        change24h: (value.symbol.toUpperCase() == 'USDT' || value.id == 'tether') ? 0.0 : change,
        logoUrl: _getLocalOrRemoteLogo(value.id, value.symbol, value.logoUrl),
        marketCap: value.marketCap * volatility,
      ));
    });
    _enforcePegs();
    notifyListeners();
  }
  
  String _getLocalOrRemoteLogo(String id, String symbol, String? remoteUrl) {
    // Currently local assets are failing to decode on Web. 
    // We will prioritize the remote URL until local assets are verified/fixed.
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return remoteUrl;
    }
    return GameConfig.getLogoPath(symbol);
  }
  
  /// Start volatility updates (every 30 seconds)
  void startVolatilityUpdates() {
    _volatilityTimer?.cancel();
    _volatilityTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _applyVolatility(),
    );
  }
  
  /// Update prices based on current date using historical data
  void _updatePricesForDate({double jumpMagnitude = 0.0, DateTime? oldDate}) {
    _cryptoData = _cryptoData.map((key, value) {
      final historicalPrice = HistoricalPriceData.getPrice(value.id, _currentDate);
      
      double finalPrice;
      
      // Attempt 9: Use existing price for 2025+ (Future/Present) instead of looking up non-existent historical data
      if (_year >= GameConfig.defaultStartYear) {
         // Start from current price logic
         finalPrice = value.price;
         
         // 2. Add daily "noise"
         final dateSeed = _currentDate.year * 1000 + _currentDate.month * 50 + _currentDate.day;
         final seededRandom = Random(dateSeed + value.id.hashCode);
         final dailyNoise = 0.98 + (seededRandom.nextDouble() * 0.04); // +/- 2%
         finalPrice *= dailyNoise;

         // 3. Apply extra volatility for larger jumps
         if (jumpMagnitude > 0) {
           final swing = (jumpMagnitude * GameConfig.jumpVolatilityScale).clamp(0.0, 0.5); 
           final jumpMultiplier = (1.0 - swing) + _random.nextDouble() * (swing * 2);
           finalPrice *= jumpMultiplier;
         }
      } else {
         // Historical Mode: Use strict historical data
         finalPrice = historicalPrice;
      }
      
      // 4. Calculate change percentage
      double changePct = 0.0;
      if (oldDate != null && jumpMagnitude > 0) {
        // For jumps, show the change relative to the price BEFORE the jump
        final oldPrice = value.price;
        if (oldPrice > 0) {
          changePct = ((finalPrice - oldPrice) / oldPrice) * 100;
        }
      } else {
        // Normal day-by-day: calculate relative to "yesterday"
        final yesterday = _currentDate.subtract(const Duration(days: 1));
        final yesterdayPrice = HistoricalPriceData.getPrice(value.id, yesterday);
        if (yesterdayPrice > 0) {
           changePct = ((finalPrice - yesterdayPrice) / yesterdayPrice) * 100;
        }
      }
      
      return MapEntry(key, CryptoData(
        id: value.id,
        name: value.name,
        symbol: value.symbol,
        price: finalPrice > 0 ? finalPrice : 0.000001,
        change24h: changePct,
        logoUrl: _getLocalOrRemoteLogo(value.id, value.symbol, value.logoUrl),
        marketCap: finalPrice * 1000000,
      ));
    });
    _enforcePegs();
    notifyListeners();
  }

  /// Ensure Pegged tokens (like WBTC) match their underlying asset (BTC)
  void _enforcePegs() {
    if (_cryptoData.containsKey('bitcoin') && _cryptoData.containsKey('wrapped-bitcoin')) {
      final btc = _cryptoData['bitcoin']!;
      final wbtc = _cryptoData['wrapped-bitcoin']!;
      
      // Update WBTC to match BTC exactly
      _cryptoData['wrapped-bitcoin'] = CryptoData(
        id: wbtc.id,
        name: wbtc.name,
        symbol: wbtc.symbol,
        price: btc.price,
        change24h: btc.change24h,
        marketCap: wbtc.marketCap, 
        logoUrl: wbtc.logoUrl,
      );
    }
  }
  
  /// Fetch all cryptocurrency prices
  Future<void> fetchAllPrices({double jumpMagnitude = 0.0, bool force = false}) async {
    final now = DateTime.now();
    final timeSinceLastFetch = now.difference(_lastApiFetch);
    
    // DISABLE LIVE FETCH IN HISTORICAL ERAS (Pre-2025) OR FUTURE
    // Only allow if it's a forced fetch (e.g. initial load or time travel jump)
    final bool isFuture = _currentDate.isAfter(DateTime.now());
    if (!force && (_year < GameConfig.defaultStartYear || isFuture)) {
      // In historical or future mode, we just ensure interpolation/simulation is applied
      _updatePricesForDate(jumpMagnitude: jumpMagnitude);
      return;
    }

    // ONLY FETCH FROM API IF:
    // 1. It's a FORCED fetch (e.g. initial load or explicit Time Travel)
    // 2. It's a significant "jump" (one-way time travel)
    // Regular 30s volatility updates or day-by-day progression will use _applyVolatility or _updatePricesForDate
    // ONLY FETCH FROM API IF:
    // 1. It's a FORCED fetch (e.g. syncMarket or initial load)
    // 2. It's a significant "jump" (one-way time travel)
    // We REMOVED the automatic volatility update here for force: false
    // to prevent prices jumping when the user pauses/plays or date changes.
    if (!force && jumpMagnitude == 0.0) {
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      var rawData = await ApiService.fetchAllPrices();
      _lastApiFetch = now;
      
      // Apply historical simulation if NOT in current era
      if (_year < GameConfig.defaultStartYear) {
        _cryptoData = rawData.map((key, value) {
          final historicalPrice = HistoricalPriceData.getPrice(value.id, _currentDate);
          
          // STRICT HISTORY: No random volatility or jump noise for pre-2025
          double price = historicalPrice;
          
          return MapEntry(key, CryptoData(
            id: value.id,
            name: value.name,
            symbol: value.symbol,
            price: price > 0 ? price : 0.000001,
            change24h: value.change24h,
            logoUrl: _getLocalOrRemoteLogo(value.id, value.symbol, value.logoUrl),
            marketCap: price * 1000000,
          ));
        });
      } else {
        // 2025+ real prices, but maybe with jump volatility
        _cryptoData = rawData.map((key, value) {
           double price = value.price;
           if (jumpMagnitude > 0) {
             final swing = (jumpMagnitude * GameConfig.jumpVolatilityScale).clamp(0.0, 1.0);
             price *= ((1.0 - swing) + _random.nextDouble() * (swing * 2));
           }
           
           // Calculate game-time 24h change (compared to real 24h change as base)
           // In 2025+, we use the API's change24h, but if jumpMagnitude > 0, 
           // we should ideally compute it. For now, we adjust the API change
           // to reflect the new price.
           final adjustedChange = value.change24h * (price / (value.price > 0 ? value.price : 1.0));
           
           return MapEntry(key, CryptoData(
             id: value.id,
             name: value.name,
             symbol: value.symbol,
             price: price > 0 ? price : 0.000001,
             change24h: adjustedChange,
             logoUrl: _getLocalOrRemoteLogo(value.id, value.symbol, value.logoUrl),
             marketCap: value.marketCap,
           ));
        });
      }
      
      _enforcePegs();
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
      (_) => _applyVolatility(), // Use volatility for background updates, not full API fetches
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
