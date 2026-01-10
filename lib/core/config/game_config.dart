/// comprehensive Game Configuration
/// 
/// This file serves as the central control panel for game balance, settings, and constants.
/// Edit values here to tweak economy, difficulty, and progression.
class GameConfig {
  // ===========================================================================
  // ECONOMY SETTINGS
  // ===========================================================================
  
  /// Starting Balance Configuration
  static const double startingBalanceGenesis = 130.0;    // 2009 Era (Enough for HD 5870)
  static const double startingBalanceEarlyGPU = 1000.0;  // 2011+ Era
  static const double startingBalanceASIC = 5000.0;      // 2015+ Era
  static const double startingBalanceModern = 10000.0;   // 2020+ Era

  /// Legacy Migration Fixes
  static const double genesisFixBonusBTC = 50.0; // BTC given back if save was bugged

  /// Power Consumption
  static const double powerCostPerKWh = 0.12; // $0.12 per kWh
  static const double maxPowerDiscount = 0.25; // Max 75% discount (0.25 multiplier)

  /// Mining Revenue Estimates (Proxies when live data missing)
  static const double estimatedRevenuePerMHs = 0.001; // $ per MH/s per day

  // ===========================================================================
  // GAMEPLAY & PROGRESSION
  // ===========================================================================

  /// Clicker / Tapping System
  static const double defaultClickPower = 1.0;
  static const double defaultClickTarget = 100.0;
  static const int defaultClickCooldownDays = 1;

  /// Boost System
  static const double minBoostMultiplier = 2.0;
  static const double maxBoostMultiplier = 10.0; // Effective range: 2x - 10x
  static const int boostDurationSeconds = 30;

  /// Feature Unlocks (Dates)
  static final DateTime tradingUnlockDate = DateTime(2010, 7, 18); // Mt Gox
  static final DateTime poolMiningUnlockDate = DateTime(2010, 11, 27); // Slush Pool

  // ===========================================================================
  // TIME & SIMULATION
  // ===========================================================================
  
  /// Genesis Start Date
  static final DateTime dateGenesisCheck = DateTime(2009, 1, 3);
  
  /// Default Start Date (Present Day Fallback)
  static const int defaultStartYear = 2025;
  static final DateTime dateDefaultStart = DateTime(2025, 1, 1);

  /// Volatility Settings
  static const double volatilityBaseSwing = 0.05; // +/- 5% base volatility
  
  /// Scaling factor for time jumps.
  /// 
  /// Logic: jumpMagnitude = (daysSkipped / 30.0)
  /// swing = (jumpMagnitude * jumpVolatilityScale).clamp(0.0, 0.5)
  /// 
  /// Example: 
  /// - Scaling by 0.1 means skipping 300 days (10 months) results in up to +/- 10% price variation.
  /// - (300 / 30) * 0.1 = 1.0 * 0.1 = 0.1 (10% swing)
  static const double jumpVolatilityScale = 0.1;

  // ===========================================================================
  // CRYPTOCURRENCY DEFINITIONS
  // ===========================================================================
  
  static const String defaultActiveCrypto = 'bitcoin';

  /// Max Supplies (Simulated Caps)
  static const Map<String, double> maxSupplies = {
    'bitcoin': 21000000.0,
    'ethereum': 120000000.0,
    'ethereum-classic': 210700000.0,
    'litecoin': 84000000.0,
    'dogecoin': 140000000000.0,
    'bitcoin-cash': 21000000.0,
    'bitcoin-gold': 21000000.0,
    'zcash': 21000000.0,
    'ravencoin': 21000000000.0,
    'neurai': 21000000000.0,
    'neoxa': 21000000000.0,
    'raptoreum': 21000000000.0,
    'ergo': 97739924.0,
    'flux': 440000000.0,
    'conflux': 5000000000.0,
    'kaspa': 28700000000.0,
    'alephium': 1000000000.0,
    'kadena': 1000000000.0,
    'nexa': 21000000000000.0,
    'dash': 18900000.0,
    'vertcoin': 84000000.0,
    'firo': 21400000.0,
    'beam': 262800000.0,
    'clore-ai': 1300000000.0,
    'monero': 18400000.0,
  };

  // ===========================================================================
  // ASSETS & UI
  // ===========================================================================
  
  /// Fallback Logo Logic
  static String getLogoPath(String symbol) => 'assets/images/coins/${symbol.toLowerCase()}.png';
}
