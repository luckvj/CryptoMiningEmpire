import 'dart:convert';
import 'package:http/http.dart' as http;

/// API Service for fetching real-time cryptocurrency prices and logos
/// Uses CoinGecko API (free, no API key required)
class ApiService {
  // CoinGecko API - Primary source (free and reliable)
  static const String coinGeckoBase = 'https://api.coingecko.com/api/v3';
  
  // Top 50+ Cryptocurrency IDs for CoinGecko (only coins with verified logos)
  static const List<String> top50CryptoIds = [
    'bitcoin', 'ethereum', 'tether', 'binancecoin', 'ripple',
    'cardano', 'solana', 'polkadot', 'dogecoin', 'polygon',
    'litecoin', 'avalanche-2', 'chainlink', 'uniswap', 'stellar',
    'monero', 'ethereum-classic', 'bitcoin-cash', 'algorand', 'vechain',
    'cosmos', 'filecoin', 'tron', 'eos', 'aave',
    'maker', 'neo', 'pancakeswap-token', 'theta-token', 'multiversx-elrond-egld',
    'decentraland', 'the-sandbox', 'axie-infinity', 'hedera-hashgraph', 'tezos',
    'wrapped-bitcoin', 'zcash', 'dash', 'kusama', 'near',
    'fantom', 'harmony', 'qtum', 'immutable-x', 'gala',
    'enjincoin', 'basic-attention-token', 'sushi', 'curve-dao-token', 'synthetix-network-token',
    'ergo', 'ravencoin', 'kaspa', 'flux', 'conflux-token', 'bitcoin-gold'
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
    'multiversx-elrond-egld': 'EGLD',
    'decentraland': 'MANA',
    'the-sandbox': 'SAND',
    'axie-infinity': 'AXS',
    'hedera-hashgraph': 'HBAR',
    'tezos': 'XTZ',
    'wrapped-bitcoin': 'WBTC',
    'zcash': 'ZEC',
    'dash': 'DASH',
    'kusama': 'KSM',
    'near': 'NEAR',
    'fantom': 'FTM',
    'harmony': 'ONE',
    'qtum': 'QTUM',
    'immutable-x': 'IMX',
    'gala': 'GALA',
    'enjincoin': 'ENJ',
    'basic-attention-token': 'BAT',
    'sushi': 'SUSHI',
    'curve-dao-token': 'CRV',
    'synthetix-network-token': 'SNX',
    'ergo': 'ERG',
    'ravencoin': 'RVN',
    'kaspa': 'KAS',
    'flux': 'FLUX',
    'conflux-token': 'CFX',
    'bitcoin-gold': 'BTG',
  };
  
  /// Fetch top 50+ cryptocurrencies from CoinGecko (free, no API key)
  static Future<Map<String, CryptoData>> fetchAllPrices() async {
    // PRIMARY: Try CoinGecko (free and reliable)
    try {
      final coinsFromGecko = await _fetchFromCoinGecko();
      if (coinsFromGecko.isNotEmpty) {
        return coinsFromGecko;
      }
    } catch (e) {
      // Silently fall through to fallback
    }
    
    // Last resort: static fallback data
    return _getFallbackData();
  }
  
  /// Fetch from CoinGecko with cryptologos.cc image URLs
  static Future<Map<String, CryptoData>> _fetchFromCoinGecko() async {
    // Use the coins/markets endpoint which includes images
    final url = Uri.parse(
      '$coinGeckoBase/coins/markets?vs_currency=usd&ids=${top50CryptoIds.join(',')}&order=market_cap_desc&per_page=50&page=1&sparkline=false&price_change_percentage=24h'
    );
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final Map<String, CryptoData> cryptoMap = {};
      
      for (var coin in data) {
        final id = coin['id'] as String;
        final symbol = (coin['symbol'] as String).toUpperCase();
        cryptoMap[id] = CryptoData(
          id: id,
          symbol: symbol,
          name: coin['name'] as String,
          price: (coin['current_price'] as num?)?.toDouble() ?? 0.0,
          change24h: (coin['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
          marketCap: (coin['market_cap'] as num?)?.toDouble() ?? 0.0,
          logoUrl: _getLogoUrl(symbol),
        );
      }
      
      return cryptoMap;
    }
    
    throw Exception('CoinGecko API failed with status ${response.statusCode}');
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
  
  /// Get logo URL from cryptologos.cc - high quality crypto logos
  static String _getLogoUrl(String symbol) {
    final symbolLower = symbol.toLowerCase();
    // Use cryptologos.cc - high quality, reliable crypto logo source
    // Format: https://cryptologos.cc/logos/{coin-name}-{symbol}-logo.png
    return _getCryptoLogosUrl(symbolLower);
  }
  
  /// Map crypto symbols to cryptologos.cc URLs
  static String _getCryptoLogosUrl(String symbol) {
    // Cryptologos.cc URL format: https://cryptologos.cc/logos/{name}-{symbol}-logo.png
    final symbolLower = symbol.toLowerCase();
    
    // Map of symbols to their full names for cryptologos.cc
    final nameMap = {
      'btc': 'bitcoin-btc',
      'eth': 'ethereum-eth',
      'usdt': 'tether-usdt',
      'bnb': 'bnb-bnb',
      'xrp': 'xrp-xrp',
      'ada': 'cardano-ada',
      'sol': 'solana-sol',
      'doge': 'dogecoin-doge',
      'dot': 'polkadot-new-dot',
      'matic': 'polygon-matic',
      'ltc': 'litecoin-ltc',
      'avax': 'avalanche-avax',
      'link': 'chainlink-link',
      'uni': 'uniswap-uni',
      'xlm': 'stellar-xlm',
      'xmr': 'monero-xmr',
      'etc': 'ethereum-classic-etc',
      'bch': 'bitcoin-cash-bch',
      'algo': 'algorand-algo',
      'vet': 'vechain-vet',
      'atom': 'cosmos-atom',
      'fil': 'filecoin-fil',
      'trx': 'tron-trx',
      'eos': 'eos-eos',
      'aave': 'aave-aave',
      'mkr': 'maker-mkr',
      'neo': 'neo-neo',
      'cake': 'pancakeswap-cake',
      'theta': 'theta-network-theta',
      'egld': 'multiversx-egld',
      'mana': 'decentraland-mana',
      'sand': 'the-sandbox-sand',
      'axs': 'axie-infinity-axs',
      'hbar': 'hedera-hashgraph-hbar',
      'xtz': 'tezos-xtz',
      'wbtc': 'wrapped-bitcoin-wbtc',
      'zec': 'zcash-zec',
      'dash': 'dash-dash',
      'ksm': 'kusama-ksm',
      'near': 'near-protocol-near',
      'ftm': 'fantom-ftm',
      'one': 'harmony-one',
      // 'ape' removed - cryptologos.cc has a 404 for ApeCoin
      'imx': 'immutable-x-imx',
      'gala': 'gala-gala',
      'qtum': 'qtum-qtum',
      'enj': 'enjin-coin-enj',
      'bat': 'basic-attention-token-bat',
      'sushi': 'sushiswap-sushi',
      'crv': 'curve-dao-token-crv',
      'snx': 'synthetix-network-token-snx',
      'erg': 'ergo-erg',
      'rvn': 'ravencoin-rvn',
      'kas': 'kaspa-kas',
      'flux': 'flux-flux',
      'cfx': 'conflux-network-cfx',
      'btg': 'bitcoin-gold-btg',
    };
    
    final logoName = nameMap[symbolLower] ?? '$symbolLower-$symbolLower';
    return 'https://cryptologos.cc/logos/$logoName-logo.png';
  }
  
  /// Fallback data when API is unavailable - Only cryptos with verified logos on cryptologos.cc
  static Map<String, CryptoData> _getFallbackData() {
    return {
      'bitcoin': CryptoData(
        id: 'bitcoin',
        symbol: 'BTC',
        name: 'Bitcoin',
        price: 95000.0,
        change24h: 2.5,
        marketCap: 1850000000000,
        logoUrl: _getCryptoLogosUrl('btc'),
      ),
      'ethereum': CryptoData(
        id: 'ethereum',
        symbol: 'ETH',
        name: 'Ethereum',
        price: 3500.0,
        change24h: 3.2,
        marketCap: 420000000000,
        logoUrl: _getCryptoLogosUrl('eth'),
      ),
      'tether': CryptoData(
        id: 'tether',
        symbol: 'USDT',
        name: 'Tether',
        price: 1.0,
        change24h: 0.0,
        marketCap: 120000000000,
        logoUrl: _getCryptoLogosUrl('usdt'),
      ),
      'binancecoin': CryptoData(
        id: 'binancecoin',
        symbol: 'BNB',
        name: 'BNB',
        price: 620.0,
        change24h: 1.8,
        marketCap: 90000000000,
        logoUrl: _getCryptoLogosUrl('bnb'),
      ),
      'solana': CryptoData(
        id: 'solana',
        symbol: 'SOL',
        name: 'Solana',
        price: 190.0,
        change24h: 5.2,
        marketCap: 85000000000,
        logoUrl: _getCryptoLogosUrl('sol'),
      ),
      'ripple': CryptoData(
        id: 'ripple',
        symbol: 'XRP',
        name: 'XRP',
        price: 2.3,
        change24h: 4.5,
        marketCap: 130000000000,
        logoUrl: _getCryptoLogosUrl('xrp'),
      ),
      'cardano': CryptoData(
        id: 'cardano',
        symbol: 'ADA',
        name: 'Cardano',
        price: 0.95,
        change24h: -1.2,
        marketCap: 33000000000,
        logoUrl: _getCryptoLogosUrl('ada'),
      ),
      'dogecoin': CryptoData(
        id: 'dogecoin',
        symbol: 'DOGE',
        name: 'Dogecoin',
        price: 0.35,
        change24h: 2.8,
        marketCap: 51000000000,
        logoUrl: _getCryptoLogosUrl('doge'),
      ),
      'avalanche': CryptoData(
        id: 'avalanche',
        symbol: 'AVAX',
        name: 'Avalanche',
        price: 42.0,
        change24h: 3.5,
        marketCap: 16000000000,
        logoUrl: _getCryptoLogosUrl('avax'),
      ),
      'polkadot': CryptoData(
        id: 'polkadot',
        symbol: 'DOT',
        name: 'Polkadot',
        price: 7.2,
        change24h: -0.8,
        marketCap: 10000000000,
        logoUrl: _getCryptoLogosUrl('dot'),
      ),
      'polygon': CryptoData(
        id: 'polygon',
        symbol: 'MATIC',
        name: 'Polygon',
        price: 0.48,
        change24h: 1.5,
        marketCap: 5000000000,
        logoUrl: _getCryptoLogosUrl('matic'),
      ),
      'litecoin': CryptoData(
        id: 'litecoin',
        symbol: 'LTC',
        name: 'Litecoin',
        price: 105.0,
        change24h: 1.8,
        marketCap: 7800000000,
        logoUrl: _getCryptoLogosUrl('ltc'),
      ),
      'chainlink': CryptoData(
        id: 'chainlink',
        symbol: 'LINK',
        name: 'Chainlink',
        price: 22.5,
        change24h: 2.1,
        marketCap: 14000000000,
        logoUrl: _getCryptoLogosUrl('link'),
      ),
      'uniswap': CryptoData(
        id: 'uniswap',
        symbol: 'UNI',
        name: 'Uniswap',
        price: 13.8,
        change24h: 0.9,
        marketCap: 8300000000,
        logoUrl: _getCryptoLogosUrl('uni'),
      ),
      'stellar': CryptoData(
        id: 'stellar',
        symbol: 'XLM',
        name: 'Stellar',
        price: 0.38,
        change24h: 1.2,
        marketCap: 11000000000,
        logoUrl: _getCryptoLogosUrl('xlm'),
      ),
      'monero': CryptoData(
        id: 'monero',
        symbol: 'XMR',
        name: 'Monero',
        price: 165.0,
        change24h: 1.5,
        marketCap: 3000000000,
        logoUrl: _getCryptoLogosUrl('xmr'),
      ),
      'tron': CryptoData(
        id: 'tron',
        symbol: 'TRX',
        name: 'TRON',
        price: 0.25,
        change24h: 2.1,
        marketCap: 22000000000,
        logoUrl: _getCryptoLogosUrl('trx'),
      ),
      'cosmos': CryptoData(
        id: 'cosmos',
        symbol: 'ATOM',
        name: 'Cosmos',
        price: 9.8,
        change24h: 3.2,
        marketCap: 2800000000,
        logoUrl: _getCryptoLogosUrl('atom'),
      ),
      'ethereum-classic': CryptoData(
        id: 'ethereum-classic',
        symbol: 'ETC',
        name: 'Ethereum Classic',
        price: 28.5,
        change24h: 0.8,
        marketCap: 4100000000,
        logoUrl: _getCryptoLogosUrl('etc'),
      ),
      'bitcoin-cash': CryptoData(
        id: 'bitcoin-cash',
        symbol: 'BCH',
        name: 'Bitcoin Cash',
        price: 485.0,
        change24h: 1.2,
        marketCap: 9600000000,
        logoUrl: _getCryptoLogosUrl('bch'),
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
