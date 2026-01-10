import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/services/api_service.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';
import '../widgets/network_crypto_logo.dart';
import '../widgets/crypto_toast.dart';
import '../widgets/market_lockout_overlay.dart';

/// Mobile-optimized trading screen for Android
class TradingScreenMobile extends StatefulWidget {
  const TradingScreenMobile({super.key});

  @override
  State<TradingScreenMobile> createState() => _TradingScreenMobileState();
}

class _TradingScreenMobileState extends State<TradingScreenMobile> with SingleTickerProviderStateMixin {
  String? _selectedCrypto;
  final _amountController = TextEditingController();
  late TabController _tabController;
  bool _isBuyMode = true; // Toggle state for Buy/Sell or Long/Short
  bool _isShort = false; // For margin trading (long/short)
  double _leverage = 2.0; // Margin leverage (1x-10x)
  double? _capturedEntryPrice; // Frozen price for margin planning
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
        // Capture price when entering margin tab (index 2)
        if (_tabController.index == 2) {
          final priceProvider = context.read<CryptoPriceProvider>();
          final crypto = priceProvider.getCrypto(_selectedCrypto!);
          if (crypto != null) {
            _capturedEntryPrice = crypto.price;
          }
        }
      }
    });
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ... (Build method remains similar until _buildTradeCard)

  @override
  Widget build(BuildContext context) {
    // ... (Keep existing build logic until _buildTradeCard call)
    final gameState = context.watch<GameStateProvider>();
    final priceProvider = context.watch<CryptoPriceProvider>();
    
    if (priceProvider.cryptoData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('TRADING'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    _selectedCrypto ??= priceProvider.cryptoData.keys.first;
    final selectedCryptoData = priceProvider.getCrypto(_selectedCrypto!);
    
    if (selectedCryptoData == null) return const Scaffold(body: Center(child: Text('Error')));
    
    return MarketLockoutOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TRADING'),
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 44,
        ),
        body: Column(
          children: [
            _buildCryptoSelectorCard(priceProvider, selectedCryptoData),
            Container(
              color: CyberpunkTheme.surfaceColor,
              child: TabBar(
                controller: _tabController,
                labelColor: CyberpunkTheme.primaryBlue,
                unselectedLabelColor: CyberpunkTheme.textTertiary,
                indicatorColor: CyberpunkTheme.primaryBlue,
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [Tab(text: 'MARKET'), Tab(text: 'SPOT'), Tab(text: 'MARGIN')],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMarketTab(priceProvider),
                  _buildTradeTab(gameState, selectedCryptoData),
                  _buildMarginTab(gameState, priceProvider, selectedCryptoData),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Keep _buildCryptoSelectorCard, _buildMarketTab, _buildCryptoListItem)
  Widget _buildCryptoSelectorCard(CryptoPriceProvider priceProvider, CryptoData crypto) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CyberpunkTheme.surfaceColor,
            CyberpunkTheme.surfaceColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CyberpunkTheme.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: CyberpunkTheme.backgroundDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CyberpunkTheme.primaryBlue.withOpacity(0.3),
              ),
            ),
            child: DropdownButton<String>(
              value: _selectedCrypto,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: CyberpunkTheme.surfaceColor,
              icon: Icon(Icons.keyboard_arrow_down, color: CyberpunkTheme.primaryBlue),
              style: GoogleFonts.inter(
                color: CyberpunkTheme.textPrimary,
                fontSize: 16,
              ),
              items: priceProvider.cryptoData.values.map((crypto) {
                return DropdownMenuItem(
                  value: crypto.id,
                  child: Row(
                    children: [
                      NetworkCryptoLogo(
                        logoUrl: crypto.logoUrl,
                        symbol: crypto.symbol,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              crypto.symbol,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: CyberpunkTheme.textPrimary,
                              ),
                            ),
                            Text(
                              crypto.name,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: CyberpunkTheme.textTertiary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCrypto = value;
                  // Update captured price for margin planning
                  if (_tabController.index == 2) {
                    final crypto = priceProvider.getCrypto(_selectedCrypto!);
                    if (crypto != null) {
                      _capturedEntryPrice = crypto.price;
                    }
                  }
                });
              },
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Price Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Price',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: CyberpunkTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      crypto.symbol == 'BTC' 
                          ? '\$${crypto.price.toStringAsFixed(2)}'
                          : '\$${crypto.price.toStringAsFixed(crypto.price < 1 ? 6 : 2)}',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CyberpunkTheme.primaryBlue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: (crypto.isPriceUp 
                    ? CyberpunkTheme.accentGreen 
                    : CyberpunkTheme.accentOrange).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: crypto.isPriceUp 
                      ? CyberpunkTheme.accentGreen 
                      : CyberpunkTheme.accentOrange,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      crypto.isPriceUp ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
                      color: crypto.isPriceUp 
                        ? CyberpunkTheme.accentGreen 
                        : CyberpunkTheme.accentOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${crypto.change24h.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: crypto.isPriceUp 
                          ? CyberpunkTheme.accentGreen 
                          : CyberpunkTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketTab(CryptoPriceProvider priceProvider) {
    // Filter coins that exist at the current game date
    final availableCoins = priceProvider.getAvailableCoins();
    final sortedCryptos = availableCoins.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name)); // Alphabetical to prevent jumping
    
    if (sortedCryptos.isEmpty) {
      return Container(
        color: CyberpunkTheme.backgroundDark,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.currency_bitcoin, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Only Bitcoin exists in this era', 
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 16)),
            ],
          ),
        ),
      );
    }
    
    return Container(
      color: CyberpunkTheme.backgroundDark,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: sortedCryptos.length,
        itemBuilder: (context, index) {
          final crypto = sortedCryptos[index];
          return _buildCryptoListItem(crypto);
        },
      ),
    );
  }

  Widget _buildCryptoListItem(CryptoData crypto) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: CyberpunkTheme.surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: CyberpunkTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() => _selectedCrypto = crypto.id);
          _tabController.animateTo(1); // Switch to trade tab
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              NetworkCryptoLogo(
                logoUrl: crypto.logoUrl,
                symbol: crypto.symbol,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crypto.symbol,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CyberpunkTheme.textPrimary,
                      ),
                    ),
                    Text(
                      crypto.name,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: CyberpunkTheme.textTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${crypto.price.toStringAsFixed(crypto.price < 1 ? 6 : 2)}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CyberpunkTheme.textPrimary,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (crypto.isPriceUp 
                        ? CyberpunkTheme.accentGreen 
                        : CyberpunkTheme.accentOrange).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${crypto.change24h >= 0 ? '+' : ''}${crypto.change24h.toStringAsFixed(2)}%',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: crypto.isPriceUp 
                          ? CyberpunkTheme.accentGreen 
                          : CyberpunkTheme.accentOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTradeTab(GameStateProvider gameState, CryptoData crypto) {
    return Container(
      color: CyberpunkTheme.backgroundDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBalanceCard(gameState, crypto),
            const SizedBox(height: 16),
            _buildTradeCard(gameState, crypto),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBalanceCard(GameStateProvider gameState, CryptoData crypto) {
    final holdings = gameState.holdings[crypto.id] ?? 0.0;
    final holdingsValue = holdings * crypto.price;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CyberpunkTheme.surfaceColor,
            CyberpunkTheme.surfaceColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CyberpunkTheme.accentGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'YOUR BALANCE',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: CyberpunkTheme.textTertiary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildBalanceItem(
                  'Cash',
                  '\$${gameState.balance.toStringAsFixed(2)}',
                  CyberpunkTheme.accentGreen,
                  Icons.account_balance_wallet,
                ),
              ),
              Container(width: 1, height: 50, color: CyberpunkTheme.primaryBlue.withOpacity(0.3)),
              Expanded(
                child: _buildBalanceItem(
                  crypto.symbol,
                  holdings.toStringAsFixed(8),
                  CyberpunkTheme.primaryBlue,
                  Icons.currency_bitcoin,
                ),
              ),
            ],
          ),
          if (holdings > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CyberpunkTheme.backgroundDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Holdings Value:',
                    style: GoogleFonts.inter(fontSize: 14, color: CyberpunkTheme.textSecondary),
                  ),
                  Text(
                    '\$${holdingsValue.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CyberpunkTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: CyberpunkTheme.textTertiary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTradeCard(GameStateProvider gameState, CryptoData crypto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CyberpunkTheme.surfaceColor,
            CyberpunkTheme.surfaceColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isBuyMode ? CyberpunkTheme.accentGreen.withOpacity(0.5) : CyberpunkTheme.accentOrange.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buy / Sell Toggle
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                     _isBuyMode = true;
                     _amountController.clear();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isBuyMode ? CyberpunkTheme.accentGreen.withOpacity(0.2) : Colors.transparent,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                      border: Border.all(
                        color: _isBuyMode ? CyberpunkTheme.accentGreen : CyberpunkTheme.textTertiary.withOpacity(0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'BUY',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: _isBuyMode ? CyberpunkTheme.accentGreen : CyberpunkTheme.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isBuyMode = false;
                    _amountController.clear();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isBuyMode ? CyberpunkTheme.accentRed.withOpacity(0.2) : Colors.transparent,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                      border: Border.all(
                        color: !_isBuyMode ? CyberpunkTheme.accentRed : CyberpunkTheme.textTertiary.withOpacity(0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'SELL',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: !_isBuyMode ? CyberpunkTheme.accentRed : CyberpunkTheme.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            _isBuyMode ? 'Buy Amount (${crypto.symbol})' : 'Sell Amount (${crypto.symbol})',
            style: GoogleFonts.inter(
              color: CyberpunkTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 8),

          // Amount Input
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.inter(
              color: CyberpunkTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              suffixText: crypto.symbol,
              suffixStyle: GoogleFonts.inter(
                color: CyberpunkTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor: CyberpunkTheme.backgroundDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _isBuyMode ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: (_isBuyMode ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed).withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _isBuyMode ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed,
                  width: 2,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Quick Amount Buttons (Context Aware)
          Row(
            children: [
              _buildQuickAmountButton('25%', 0.25, gameState, crypto),
              const SizedBox(width: 8),
              _buildQuickAmountButton('50%', 0.50, gameState, crypto),
              const SizedBox(width: 8),
              _buildQuickAmountButton('75%', 0.75, gameState, crypto),
              const SizedBox(width: 8),
              _buildQuickAmountButton('MAX', 1.0, gameState, crypto),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _isBuyMode 
                ? _handleBuy(context, gameState, crypto) 
                : _handleSell(context, gameState, crypto),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isBuyMode ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: (_isBuyMode ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed).withOpacity(0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_isBuyMode ? Icons.arrow_upward : Icons.arrow_downward, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isBuyMode ? 'BUY ${crypto.symbol}' : 'SELL ${crypto.symbol}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickAmountButton(String label, double percentage, GameStateProvider gameState, CryptoData crypto) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          double amount;
          // Use 99.99% for MAX to avoid floating point precision errors (0.0000001 difference causing "insufficient funds")
          final safePercentage = percentage == 1.0 ? 0.9999 : percentage; 

          if (_tabController.index == 2) {
            // Margin Mode: Collateral is always USDT
            final usdtHoldings = gameState.holdings['tether'] ?? 0.0;
            amount = usdtHoldings * safePercentage;
          } else if (_isBuyMode) {
            // Buy Mode: Calculate max amount based on balance
             final maxAmount = gameState.balance / crypto.price;
             amount = maxAmount * safePercentage;
          } else {
            // Sell Mode: Calculate max amount based on holdings
            final holdings = gameState.holdings[crypto.id] ?? 0.0;
            amount = holdings * safePercentage;
          }
          _amountController.text = (_tabController.index == 2) 
              ? amount.toStringAsFixed(2) 
              : amount.toStringAsFixed(8);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: _isBuyMode ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed,
          side: BorderSide(
            color: (_isBuyMode ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed).withOpacity(0.5)
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleBuy(BuildContext context, GameStateProvider gameState, CryptoData crypto) {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError(context, 'Please enter a valid amount');
      return;
    }
    
    final cost = amount * crypto.price;
    if (gameState.balance < cost) {
      _showError(context, 'Insufficient funds! Need \$${cost.toStringAsFixed(2)}');
      return;
    }
    
    if (gameState.buyCrypto(crypto.id, amount, crypto.price)) {
      _showSuccess(context, 'Bought ${amount.toStringAsFixed(8)} ${crypto.symbol}');
      _amountController.clear();
      // Dismiss keyboard
      FocusScope.of(context).unfocus();
    } else {
      _showError(context, 'Transaction failed!');
    }
  }
  
  void _handleSell(BuildContext context, GameStateProvider gameState, CryptoData crypto) {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError(context, 'Please enter a valid amount');
      return;
    }
    
    final holdings = gameState.holdings[crypto.id] ?? 0.0;
    if (holdings < amount) {
      _showError(context, 'Insufficient ${crypto.symbol}! You have ${holdings.toStringAsFixed(8)}');
      return;
    }
    
    if (gameState.sellCrypto(crypto.id, amount, crypto.price)) {
      _showSuccess(context, 'Sold ${amount.toStringAsFixed(8)} ${crypto.symbol}');
      _amountController.clear();
      // Dismiss keyboard
      FocusScope.of(context).unfocus();
    } else {
      _showError(context, 'Transaction failed!');
    }
  }
  
  void _showSuccess(BuildContext context, String message) {
    CryptoToast.success(context, message);
  }
  
  void _showError(BuildContext context, String message) {
    CryptoToast.error(context, message);
  }
  
  Widget _buildMarginTab(GameStateProvider gameState, CryptoPriceProvider priceProvider, CryptoData crypto) {
    // Check for USDT Era (Oct 6, 2014)
    final usdtLaunchDate = DateTime(2014, 10, 6);
    if (gameState.gameDate.isBefore(usdtLaunchDate)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_clock, size: 64, color: CyberpunkTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              'MARGIN TRADING LOCKED',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CyberpunkTheme.accentRed,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Requires Stablecoins (USDT)\nAvailable from: Oct 6, 2014',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: CyberpunkTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Current Date: ${gameState.gameDate.year}-${gameState.gameDate.month}-${gameState.gameDate.day}',
              style: GoogleFonts.inter(
                 color: CyberpunkTheme.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: CyberpunkTheme.backgroundDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Long/Short Toggle
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isBuyMode = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _isBuyMode ? CyberpunkTheme.accentGreen.withOpacity(0.2) : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                        border: Border.all(color: _isBuyMode ? CyberpunkTheme.accentGreen : Colors.grey.shade700),
                      ),
                      alignment: Alignment.center,
                      child: Text('LONG', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _isBuyMode ? CyberpunkTheme.accentGreen : Colors.grey)),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isBuyMode = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: !_isBuyMode ? CyberpunkTheme.accentRed.withOpacity(0.2) : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                        border: Border.all(color: !_isBuyMode ? CyberpunkTheme.accentRed : Colors.grey.shade700),
                      ),
                      alignment: Alignment.center,
                      child: Text('SHORT', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: !_isBuyMode ? CyberpunkTheme.accentRed : Colors.grey)),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Collateral Input
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Collateral (USDT)',
                suffixText: 'USDT',
                filled: true,
                fillColor: CyberpunkTheme.backgroundDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Quick Amount Buttons (USDT)
            Row(
              children: [
                _buildQuickAmountButton('25%', 0.25, gameState, crypto),
                const SizedBox(width: 8),
                _buildQuickAmountButton('50%', 0.50, gameState, crypto),
                const SizedBox(width: 8),
                _buildQuickAmountButton('75%', 0.75, gameState, crypto),
                const SizedBox(width: 8),
                _buildQuickAmountButton('MAX', 1.0, gameState, crypto),
              ],
            ),

            const SizedBox(height: 12),
            
            // USDT Balance Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: CyberpunkTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text('Available USDT:', style: GoogleFonts.inter(color: CyberpunkTheme.textSecondary, fontSize: 12)),
                   Text('\$${(gameState.holdings['tether'] ?? 0.0).toStringAsFixed(2)}', style: GoogleFonts.inter(color: CyberpunkTheme.accentGreen, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            
            // Leverage Slider
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CyberpunkTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CyberpunkTheme.primaryBlue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('LEVERAGE', style: GoogleFonts.inter(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: CyberpunkTheme.primaryBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: CyberpunkTheme.primaryBlue),
                        ),
                        child: Text('${_leverage.toInt()}x', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: CyberpunkTheme.primaryBlue, fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _leverage,
                    min: 1,
                    max: 1000,
                    divisions: 999,
                    activeColor: CyberpunkTheme.primaryBlue,
                    onChanged: (v) => setState(() => _leverage = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1x', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                      Text('100x', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                      Text('500x', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                      Text('1000x', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Position Details
                  Builder(builder: (context) {
                    final collateral = double.tryParse(_amountController.text) ?? 0.0;
                    final positionSize = collateral * _leverage;
                    
                    // Use captured price if available, otherwise fallback to current
                    final entryPrice = _capturedEntryPrice ?? crypto.price;
                    
                    final liqPrice = _isBuyMode
                        ? entryPrice * (1 - 0.95 / _leverage)
                        : entryPrice * (1 + 0.95 / _leverage);
                    return Column(
                      children: [
                        _buildMarginDetail('Position Size', '\$${positionSize.toStringAsFixed(2)}'),
                        _buildMarginDetail('Market Price', '\$${entryPrice.toStringAsFixed(2)}'),
                        _buildMarginDetail('Est. Liq. Price', '\$${liqPrice.toStringAsFixed(2)}', color: CyberpunkTheme.accentRed),
                      ],
                    );
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Open Position Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () => _openMarginPosition(context, gameState, crypto),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isBuyMode ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_isBuyMode ? 'OPEN LONG' : 'OPEN SHORT', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            
            // Active Positions
            if (gameState.activePositions.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              Text('ACTIVE POSITIONS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: CyberpunkTheme.primaryBlue)),
              const SizedBox(height: 12),
              ...gameState.activePositions.map((p) {
                final currentPrice = priceProvider.getPrice(p.cryptoId);
                final pnl = p.calculatePnL(currentPrice);
                final isShort = p.type == PositionType.short;
                final pnlColor = pnl >= 0 ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CyberpunkTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: pnlColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isShort ? CyberpunkTheme.accentRed.withOpacity(0.2) : CyberpunkTheme.accentGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(isShort ? 'SHORT' : 'LONG', style: TextStyle(fontSize: 10, color: isShort ? CyberpunkTheme.accentRed : CyberpunkTheme.accentGreen, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.cryptoId.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('Market Price: \$${p.entryPrice.toStringAsFixed(2)} • ${p.leverage.toInt()}x', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text('Current Price: \$${currentPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 11, color: CyberpunkTheme.primaryBlue.withOpacity(0.8))),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${pnl >= 0 ? "+" : ""}\$${pnl.toStringAsFixed(2)} USDT', style: TextStyle(fontWeight: FontWeight.bold, color: pnlColor)),
                          Text('${(pnl / p.amount * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: pnlColor)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.white54),
                        onPressed: () => gameState.closeMarginPosition(p.id, currentPrice),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildMarginDetail(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          Text(value, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
  
  void _openMarginPosition(BuildContext context, GameStateProvider gameState, CryptoData crypto) {
    // Block USDT from margin trading entirely
    if (crypto.id == 'tether' || crypto.symbol.toUpperCase() == 'USDT') {
      _showError(context, 'USDT cannot be traded on margin!');
      return;
    }
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError(context, 'Enter a valid collateral amount');
      return;
    }
    
    // Callnamed parameter version
      // For Margin, "amount" is the USDT collateral
      final success = gameState.openMarginPosition(
        coinId: crypto.id,
        amount: amount,
        entryPrice: _capturedEntryPrice ?? crypto.price,
        leverage: _leverage,
        isShort: !_isBuyMode,
      );
    
    if (success) {
      _showSuccess(context, 'Opened ${_isBuyMode ? "Long" : "Short"} ${_leverage.toInt()}x position');
      _amountController.clear();
      FocusScope.of(context).unfocus();
    } else {
      _showError(context, 'Insufficient balance!');
    }
  }
}
