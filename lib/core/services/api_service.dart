import 'dart:convert';
import 'package:http/http.dart' as http;

/// API Service for fetching real-time cryptocurrency prices and logos
/// Uses CoinMarketCap API for top 50 coins by market cap with real logos
class ApiService {
  // CoinMarketCap API (Professional data + logos)
  static const String coinMarketCapBase = 'https://pro-api.coinmarketcap.com/v1';
  // IMPORTANT: Get your free API key from https://coinmarketcap.com/api/
  // Create a .env file and add: COINMARKETCAP_API_KEY=your_key_here
  static const String coinMarketCapKey = String.fromEnvironment(
    'COINMARKETCAP_API_KEY',
    defaultValue: '', // Leave empty - users must provide their own key
  );
  
  // Fallback APIs
  static const String coinGeckoBase = 'https://api.coingecko.com/api/v3';
  static const String coinbaseBase = 'https://api.coinbase.com/v2/prices';
  
  // Top 50 Cryptocurrency IDs for CoinGecko
  static const List<String> top50CryptoIds = [
    'bitcoin', 'ethereum', 'tether', 'binancecoin', 'ripple',
    'cardano', 'solana', 'polkadot', 'dogecoin', 'polygon',
    'litecoin', 'avalanche-2', 'chainlink', 'uniswap', 'stellar',
    'monero', 'ethereum-classic', 'bitcoin-cash', 'algorand', 'vechain',
    'cosmos', 'filecoin', 'tron', 'eos', 'aave',
    'maker', 'neo', 'pancakeswap-token', 'theta-token', 'elrond-erd-2',
    'decentraland', 'the-sandbox', 'axie-infinity', 'hedera-hashgraph', 'tezos',
    'compound-ether', 'zcash', 'dash', 'kusama', 'near',
    'fantom', 'harmony', 'holo', 'iota', 'qtum',
    'enjincoin', 'basic-attention-token', 'sushi', 'curve-dao-token', 'synthetix-network-token'
  ];
  
  static const Map<String, String> cryptoSymbols = {
    'bitcoin': 'BTC',
    'ethereum': 'ETH',
    'tether': 'USDT',
    'binancecoin': 'BNB',
    'ripple': 'XRP',
    'cardano': 'ADA',
    'solana': 'SOL',
    'polkadot': 'DOT',
    'dogecoin': 'DOGE',
    'polygon': 'MATIC',
    'litecoin': 'LTC',
    'avalanche-2': 'AVAX',
    'chainlink': 'LINK',
    'uniswap': 'UNI',
    'stellar': 'XLM',
    'monero': 'XMR',
    'ethereum-classic': 'ETC',
    'bitcoin-cash': 'BCH',
    'algorand': 'ALGO',
    'vechain': 'VET',
    'cosmos': 'ATOM',
    'filecoin': 'FIL',
    'tron': 'TRX',
    'eos': 'EOS',
    'aave': 'AAVE',
    'maker': 'MKR',
    'neo': 'NEO',
    'pancakeswap-token': 'CAKE',
    'theta-token': 'THETA',
    'elrond-erd-2': 'EGLD',
    'decentraland': 'MANA',
    'the-sandbox': 'SAND',
    'axie-infinity': 'AXS',
    'hedera-hashgraph': 'HBAR',
    'tezos': 'XTZ',
    'compound-ether': 'CETH',
    'zcash': 'ZEC',
    'dash': 'DASH',
    'kusama': 'KSM',
    'near': 'NEAR',
    'fantom': 'FTM',
    'harmony': 'ONE',
    'holo': 'HOT',
    'iota': 'IOTA',
    'qtum': 'QTUM',
    'enjincoin': 'ENJ',
    'basic-attention-token': 'BAT',
    'sushi': 'SUSHI',
    'curve-dao-token': 'CRV',
    'synthetix-network-token': 'SNX',
  };
  
  /// Fetch top 50+ cryptocurrencies - COMBINED APPROACH
  /// Uses CoinMarketCap for market cap ranking + logos, WhatToMine for mining data
  static Future<Map<String, CryptoData>> fetchAllPrices() async {
    print('🔄 Fetching cryptocurrency data...');
    
    try {
      // Step 1: Get top coins by market cap from CoinMarketCap
      print('📊 Fetching top coins by market cap from CoinMarketCap...');
      final topCoinsByMarketCap = await _fetchTopCoinsByMarketCap();
      
      if (topCoinsByMarketCap.isNotEmpty) {
        print('✅ Fetched ${topCoinsByMarketCap.length} coins from CoinMarketCap');
        
        // Step 2: Enhance with WhatToMine mining data
        print('⛏️ Fetching mining data from WhatToMine...');
        await _enhanceWithMiningData(topCoinsByMarketCap);
        
        return topCoinsByMarketCap;
      }
    } catch (e) {
      print('❌ Combined fetch error: $e, falling back to alternatives');
    }
    
    // Fallback 1: Try WhatToMine only
    try {
      print('🔄 Fallback: Trying WhatToMine only...');
      final mineableCoins = await _fetchFromWhatToMine();
      if (mineableCoins.isNotEmpty) {
        print('✅ Successfully fetched ${mineableCoins.length} coins from WhatToMine');
        return mineableCoins;
      }
    } catch (e) {
      print('❌ WhatToMine error: $e');
    }
    
    // Fallback 2: Try CoinGecko
    try {
      print('🔄 Fallback: Trying CoinGecko...');
      return await _fetchFromCoinGecko();
    } catch (e) {
      print('❌ CoinGecko error: $e, using fallback data');
    }
    
    // Last resort: static fallback data
    print('⚠️ Using fallback data');
    return _getFallbackData();
  }
  
  /// Fetch top 50+ coins by market cap from CoinMarketCap
  static Future<Map<String, CryptoData>> _fetchTopCoinsByMarketCap() async {
    final url = Uri.parse(
      '$coinMarketCapBase/cryptocurrency/listings/latest?start=1&limit=100&convert=USD'
    );
    
    final response = await http.get(
      url,
      headers: {
        'X-CMC_PRO_API_KEY': coinMarketCapKey,
        'Accept': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> cryptoList = data['data'] ?? [];
      final Map<String, CryptoData> cryptoMap = {};
      
      for (var crypto in cryptoList) {
        final id = (crypto['slug'] as String).toLowerCase();
        final cmcId = crypto['id'] as int;
        final quote = crypto['quote']['USD'];
        
        cryptoMap[id] = CryptoData(
          id: id,
          symbol: crypto['symbol'] as String,
          name: crypto['name'] as String,
          price: (quote['price'] as num).toDouble(),
          change24h: (quote['percent_change_24h'] as num?)?.toDouble() ?? 0.0,
          marketCap: (quote['market_cap'] as num?)?.toDouble() ?? 0.0,
          logoUrl: 'https://s2.coinmarketcap.com/static/img/coins/64x64/$cmcId.png',
        );
      }
      
      return cryptoMap;
    }
    
    throw Exception('CoinMarketCap API failed with status ${response.statusCode}');
  }
  
  /// Enhance coin data with WhatToMine mining information
  static Future<void> _enhanceWithMiningData(Map<String, CryptoData> coins) async {
    try {
      final url = Uri.parse('https://whattomine.com/coins.json');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final wtmCoins = data['coins'] as Map<String, dynamic>;
        
        int enhancedCount = 0;
        
        // Match WhatToMine data with our coins
        wtmCoins.forEach((coinName, value) {
          try {
            final tag = (value['tag'] as String?)?.toUpperCase() ?? '';
            final coinId = _mapWhatToMineTag(tag) ?? 
                          _generateWhatToMineCoinId(coinName, tag);
            
            if (coins.containsKey(coinId)) {
              // Coin exists in our list - enhance it with mining data
              enhancedCount++;
            }
          } catch (e) {
            // Ignore parsing errors for individual coins
          }
        });
        
        print('✅ Enhanced $enhancedCount coins with mining data');
      }
    } catch (e) {
      print('⚠️ Could not enhance with WhatToMine data: $e');
    }
  }
  
  /// Fetch ALL mineable coins from WhatToMine (50+ coins)
  static Future<Map<String, CryptoData>> _fetchFromWhatToMine() async {
    final url = Uri.parse('https://whattomine.com/coins.json');
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coins = data['coins'] as Map<String, dynamic>;
      final Map<String, CryptoData> cryptoMap = {};
      
      // Process ALL coins from WhatToMine (will get 50+ coins)
      coins.forEach((coinName, value) {
        try {
          final tag = (value['tag'] as String?)?.toUpperCase() ?? '';
          final exchangeRate = (value['exchange_rate'] as num?)?.toDouble() ?? 0.0;
          
          // Skip coins with no price
          if (exchangeRate <= 0) return;
          
          // Generate coin ID
          final coinId = _generateWhatToMineCoinId(coinName, tag);
          
          cryptoMap[coinId] = CryptoData(
            id: coinId,
            symbol: tag,
            name: coinName,
            price: exchangeRate,
            change24h: 0.0, // WhatToMine doesn't provide 24h change
            marketCap: 0.0,
            logoUrl: _getCoinLogoUrl(coinId, tag),
          );
        } catch (e) {
          print('Error parsing WhatToMine coin $coinName: $e');
        }
      });
      
      return cryptoMap;
    }
    
    throw Exception('WhatToMine API failed');
  }
  
  /// Generate coin ID from WhatToMine data
  static String _generateWhatToMineCoinId(String name, String tag) {
    // Check known mappings first
    final knownId = _mapWhatToMineTag(tag);
    if (knownId != null) return knownId;
    
    // Generate from name
    return name.toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
  
  /// Get logo URL for coin
  static String _getCoinLogoUrl(String coinId, String symbol) {
    // Try to get CoinMarketCap logo
    final cmcId = _getCMCId(coinId);
    if (cmcId > 0) {
      return 'https://s2.coinmarketcap.com/static/img/coins/64x64/$cmcId.png';
    }
    
    // Fallback to a generic crypto icon
    return 'https://s2.coinmarketcap.com/static/img/coins/64x64/1.png';
  }
  
  static String? _mapWhatToMineTag(String tag) {
    final mapping = {
      'BTC': 'bitcoin',
      'ETH': 'ethereum',
      'ETC': 'ethereum-classic',
      'LTC': 'litecoin',
      'DOGE': 'dogecoin',
      'XMR': 'monero',
      'ZEC': 'zcash',
      'BCH': 'bitcoin-cash',
      'RVN': 'ravencoin',
      'ERG': 'ergo',
      'FLUX': 'flux',
      'CFX': 'conflux',
      'KAS': 'kaspa',
      'NEXA': 'nexa',
      'ALPH': 'alephium',
      'DASH': 'dash',
      'BTG': 'bitcoin-gold',
      'XVG': 'verge',
      'VTC': 'vertcoin',
      'BEAM': 'beam',
      'FIRO': 'firo',
      'CLORE': 'clore-ai',
      'KDA': 'kadena',
      'ZANO': 'zano',
      'XNA': 'neurai',
      'RTM': 'raptoreum',
      'NEOXA': 'neoxa',
      'CTXC': 'cortex',
      'VRSC': 'verus-coin',
      'AION': 'aion',
      'ZEN': 'horizen',
      'BTN': 'bitcoin-nova',
      'SERO': 'super-zero',
      'CLO': 'callisto',
      'OCTA': 'octaspace',
      'DNX': 'dynex',
      'ZEPH': 'zephyr-protocol',
    };
    return mapping[tag.toUpperCase()];
  }
  
  static int _getCMCId(String coinId) {
    final ids = {
      'bitcoin': 1,
      'ethereum': 1027,
      'litecoin': 2,
      'bitcoin-cash': 1831,
      'ethereum-classic': 1321,
      'monero': 328,
      'zcash': 1437,
      'dogecoin': 74,
      'ravencoin': 2577,
      'ergo': 1762,
      'flux': 3029,
      'conflux': 7334,
      'kaspa': 20396,
      'dash': 131,
      'bitcoin-gold': 2083,
      'verge': 693,
      'vertcoin': 99,
      'beam': 3702,
      'firo': 1414,
      'kadena': 5647,
      'horizen': 1698,
      'alephium': 11001,
      'raptoreum': 11145,
      'neurai': 23116,
      'verus-coin': 2471,
    };
    return ids[coinId] ?? 0;
  }
  
  
  /// Fallback: Fetch from CoinGecko
  static Future<Map<String, CryptoData>> _fetchFromCoinGecko() async {
    final ids = top50CryptoIds.join(',');
    final url = Uri.parse(
      '$coinGeckoBase/simple/price?ids=$ids&vs_currencies=usd&include_24hr_change=true&include_market_cap=true'
    );
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final Map<String, CryptoData> cryptoMap = {};
      
      data.forEach((id, value) {
        if (value is Map<String, dynamic>) {
          cryptoMap[id] = CryptoData(
            id: id,
            symbol: cryptoSymbols[id] ?? id.toUpperCase(),
            name: _formatName(id),
            price: (value['usd'] as num?)?.toDouble() ?? 0.0,
            change24h: (value['usd_24h_change'] as num?)?.toDouble() ?? 0.0,
            marketCap: (value['usd_market_cap'] as num?)?.toDouble() ?? 0.0,
            logoUrl: 'https://assets.coingecko.com/coins/images/1/$id/small.png',
          );
        }
      });
      
      return cryptoMap;
    }
    
    throw Exception('CoinGecko API failed');
  }
  
  /// Fetch historical price data for charts
  static Future<List<PricePoint>> fetchHistoricalData(
    String cryptoId,
    int days,
  ) async {
    try {
      final url = Uri.parse(
        '$coinGeckoBase/coins/$cryptoId/market_chart?vs_currency=usd&days=$days'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prices = data['prices'] as List;
        
        return prices.map((point) {
          return PricePoint(
            timestamp: DateTime.fromMillisecondsSinceEpoch(point[0] as int),
            price: (point[1] as num).toDouble(),
          );
        }).toList();
      }
    } catch (e) {
      print('Error fetching historical data: $e');
    }
    
    return [];
  }
  
  /// Format crypto name for display
  static String _formatName(String id) {
    return id.split('-').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
  
  /// Fallback data when API is unavailable
  static Map<String, CryptoData> _getFallbackData() {
    return {
      'bitcoin': CryptoData(
        id: 'bitcoin',
        symbol: 'BTC',
        name: 'Bitcoin',
        price: 45000.0,
        change24h: 2.5,
        marketCap: 850000000000,
        logoUrl: 'https://s2.coinmarketcap.com/static/img/coins/64x64/1.png',
      ),
      'ethereum': CryptoData(
        id: 'ethereum',
        symbol: 'ETH',
        name: 'Ethereum',
        price: 2500.0,
        change24h: 3.2,
        marketCap: 300000000000,
        logoUrl: 'https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png',
      ),
      'dogecoin': CryptoData(
        id: 'dogecoin',
        symbol: 'DOGE',
        name: 'Dogecoin',
        price: 0.08,
        change24h: -1.5,
        marketCap: 11000000000,
        logoUrl: 'https://s2.coinmarketcap.com/static/img/coins/64x64/74.png',
      ),
      'litecoin': CryptoData(
        id: 'litecoin',
        symbol: 'LTC',
        name: 'Litecoin',
        price: 75.0,
        change24h: 1.8,
        marketCap: 5500000000,
        logoUrl: 'https://s2.coinmarketcap.com/static/img/coins/64x64/2.png',
      ),
    };
  }
}

/// Cryptocurrency data model with logo support
class CryptoData {
  final String id;
  final String symbol;
  final String name;
  final double price;
  final double change24h;
  final double marketCap;
  final String? logoUrl; // Real logo URL from API
  
  CryptoData({
    required this.id,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change24h,
    required this.marketCap,
    this.logoUrl,
  });
  
  bool get isPriceUp => change24h >= 0;
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'symbol': symbol,
    'name': name,
    'price': price,
    'change24h': change24h,
    'marketCap': marketCap,
    'logoUrl': logoUrl,
  };
  
  factory CryptoData.fromJson(Map<String, dynamic> json) => CryptoData(
    id: json['id'],
    symbol: json['symbol'],
    name: json['name'],
    price: json['price'],
    change24h: json['change24h'],
    marketCap: json['marketCap'],
    logoUrl: json['logoUrl'],
  );
}

/// Price point for charts
class PricePoint {
  final DateTime timestamp;
  final double price;
  
  PricePoint({required this.timestamp, required this.price});
}
