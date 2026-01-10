/// Random market events - whale buys, exchange hacks, etc.
import 'dart:math';

class RandomEvent {
  final String id;
  final String title;
  final String description;
  final String severity; // 'positive', 'negative', 'neutral'
  final String icon;
  final double probability; // 0.0 to 1.0 chance per day
  final Map<String, double> priceImpact;
  final Duration duration;
  
  const RandomEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.icon,
    required this.probability,
    required this.priceImpact,
    required this.duration,
  });
}

class RandomEventsDatabase {
  static final Random _random = Random();
  
  static const List<RandomEvent> all = [
    // Positive events
    RandomEvent(
      id: 'whale_buy',
      title: '🐋 Whale Alert!',
      description: 'A whale just bought \$100M worth of Bitcoin!',
      severity: 'positive',
      icon: '🐋',
      probability: 0.03,
      priceImpact: {'bitcoin': 0.08, 'ethereum': 0.05},
      duration: Duration(days: 3),
    ),
    RandomEvent(
      id: 'institution_buy',
      title: '🏦 Institutional Buy',
      description: 'Major institution announces crypto investment.',
      severity: 'positive',
      icon: '🏦',
      probability: 0.02,
      priceImpact: {'bitcoin': 0.12, 'ethereum': 0.10},
      duration: Duration(days: 7),
    ),
    RandomEvent(
      id: 'country_adoption',
      title: '🌍 Country Adoption',
      description: 'A country announces Bitcoin as legal tender!',
      severity: 'positive',
      icon: '🌍',
      probability: 0.01,
      priceImpact: {'bitcoin': 0.20},
      duration: Duration(days: 14),
    ),
    RandomEvent(
      id: 'etf_approval',
      title: '📈 ETF Approved',
      description: 'New crypto ETF gets regulatory approval!',
      severity: 'positive',
      icon: '📈',
      probability: 0.01,
      priceImpact: {'bitcoin': 0.15, 'ethereum': 0.12},
      duration: Duration(days: 7),
    ),
    RandomEvent(
      id: 'celebrity_tweet',
      title: '🐦 Viral Tweet',
      description: 'Celebrity tweets about crypto. Price pumps!',
      severity: 'positive',
      icon: '🐦',
      probability: 0.05,
      priceImpact: {'dogecoin': 0.30, 'shiba-inu': 0.25},
      duration: Duration(days: 2),
    ),
    
    // Negative events
    RandomEvent(
      id: 'exchange_hack',
      title: '🔓 Exchange Hacked!',
      description: 'Major exchange reports security breach.',
      severity: 'negative',
      icon: '🔓',
      probability: 0.02,
      priceImpact: {'bitcoin': -0.10, 'ethereum': -0.12},
      duration: Duration(days: 5),
    ),
    RandomEvent(
      id: 'whale_dump',
      title: '🐋 Whale Dump!',
      description: 'Large wallet dumping coins on the market.',
      severity: 'negative',
      icon: '🐋',
      probability: 0.03,
      priceImpact: {'bitcoin': -0.08, 'ethereum': -0.06},
      duration: Duration(days: 2),
    ),
    RandomEvent(
      id: 'regulation_fud',
      title: '⚖️ Regulation FUD',
      description: 'Government announces new crypto restrictions.',
      severity: 'negative',
      icon: '⚖️',
      probability: 0.03,
      priceImpact: {'bitcoin': -0.12, 'ethereum': -0.15},
      duration: Duration(days: 7),
    ),
    RandomEvent(
      id: 'exchange_insolvency',
      title: '💸 Exchange Insolvency',
      description: 'Exchange pauses withdrawals...',
      severity: 'negative',
      icon: '💸',
      probability: 0.01,
      priceImpact: {'bitcoin': -0.15, 'ethereum': -0.18},
      duration: Duration(days: 14),
    ),
    RandomEvent(
      id: 'network_attack',
      title: '⚠️ Network Attack',
      description: '51% attack attempt detected on a coin.',
      severity: 'negative',
      icon: '⚠️',
      probability: 0.01,
      priceImpact: {'ethereum-classic': -0.30, 'litecoin': -0.05},
      duration: Duration(days: 3),
    ),
    
    // Neutral events
    RandomEvent(
      id: 'fork_announcement',
      title: '🍴 Fork Incoming',
      description: 'Major fork announced. Volatility expected.',
      severity: 'neutral',
      icon: '🍴',
      probability: 0.02,
      priceImpact: {'bitcoin': 0.05, 'ethereum': 0.03},
      duration: Duration(days: 7),
    ),
    RandomEvent(
      id: 'conference',
      title: '🎤 Crypto Conference',
      description: 'Major announcements expected this week.',
      severity: 'neutral',
      icon: '🎤',
      probability: 0.03,
      priceImpact: {},
      duration: Duration(days: 3),
    ),
  ];
  
  /// Check if a random event should trigger (called daily)
  static RandomEvent? rollForEvent() {
    for (final event in all) {
      if (_random.nextDouble() < event.probability) {
        return event;
      }
    }
    return null;
  }
  
  /// Get a specific event by ID
  static RandomEvent? getById(String id) {
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
