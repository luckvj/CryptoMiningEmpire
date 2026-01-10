import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';
import '../core/services/api_service.dart';
import '../widgets/network_crypto_logo.dart';
import '../widgets/crypto_toast.dart';
import '../widgets/market_lockout_overlay.dart';
import 'trading_screen_mobile.dart';

// Import local mobile trading logic to reuse specific widgets if needed, 
// or preferably duplicate/refactor shared logic. 
// For speed, we will reimplement the layout 
// but use a side-by-side design for Desktop.

class TradingScreenWeb extends StatefulWidget {
  const TradingScreenWeb({super.key});

  @override
  State<TradingScreenWeb> createState() => _TradingScreenWebState();
}

class _TradingScreenWebState extends State<TradingScreenWeb> with SingleTickerProviderStateMixin {
  String? _selectedCrypto;
  final _amountController = TextEditingController();
  bool _isBuyMode = true;
  bool _isMarginMode = false;
  bool _isShort = false;
  double _leverage = 2.0; // Default 2x leverage
  double? _capturedEntryPrice; // Frozen price for margin planning

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    final priceProvider = context.watch<CryptoPriceProvider>();

    // Trading lockout until Mt. Gox (July 18, 2010)
    if (!gameState.isTradingAvailable) {
      return Scaffold(
        backgroundColor: CyberpunkTheme.backgroundDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 80, color: Colors.orange.withOpacity(0.6)),
                const SizedBox(height: 24),
                Text(
                  '📈 TRADING NOT YET AVAILABLE',
                  style: GoogleFonts.orbitron(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Mt. Gox launches on July 18, 2010.\nAdvance time to unlock trading!',
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: CyberpunkTheme.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Current: ${gameState.gameDate.toIso8601String().substring(0, 10)}',
                    style: GoogleFonts.jetBrainsMono(color: CyberpunkTheme.primaryBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (priceProvider.cryptoData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    _selectedCrypto ??= priceProvider.cryptoData.keys.first;
    final selectedCryptoData = priceProvider.getCrypto(_selectedCrypto!);
    
    if (selectedCryptoData == null) return const Center(child: Text('Error'));

    return MarketLockoutOverlay(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let global background show
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN: Market List
              Expanded(
                flex: 4, 
                child: Container(
                  decoration: CyberpunkTheme.glassmorphismCard(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('MARKET', 
                          style: GoogleFonts.inter(
                            fontSize: 24, fontWeight: FontWeight.bold, color: CyberpunkTheme.primaryBlue
                          )
                        ),
                      ),
                      Expanded(
                        child: Builder(builder: (context) {
                          // Filter coins that exist at current date
                          final availableCoins = priceProvider.getAvailableCoins();
                          final cryptoList = availableCoins.values.toList()
                            ..sort((a, b) => a.name.compareTo(b.name)); // Alphabetical to prevent jumping during fast-forward
                          
                          if (cryptoList.isEmpty) {
                            return Center(
                              child: Text('Only Bitcoin exists in this era',
                                style: GoogleFonts.inter(color: Colors.white54)),
                            );
                          }
                          
                          return ListView.builder(
                            itemCount: cryptoList.length,
                            itemBuilder: (context, index) {
                              final crypto = cryptoList[index];
                              final isSelected = crypto.id == _selectedCrypto;
                              // Always use 2 decimal places to prevent overflow
                              final priceStr = crypto.price.toStringAsFixed(2);
                              return Container(
                                color: isSelected ? CyberpunkTheme.primaryBlue.withOpacity(0.1) : null,
                                child: ListTile(
                                  leading: NetworkCryptoLogo(logoUrl: crypto.logoUrl, symbol: crypto.symbol, size: 32),
                                  title: Text(crypto.symbol, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  subtitle: Text(
                                    'Owned: ${(gameState.holdings[crypto.id] ?? 0).toStringAsFixed(4)}',
                                    style: TextStyle(color: CyberpunkTheme.textTertiary, fontSize: 12),
                                  ),
                                  trailing: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 100),
                                    child: Text('\$$priceStr', 
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  onTap: () => setState(() {
                                  _selectedCrypto = crypto.id;
                                  // Capture price for margin planning
                                  if (_isMarginMode) {
                                    _capturedEntryPrice = crypto.price;
                                  }
                                }),
                                ),
                              );
                            }
                          );
                        })
                      )
                    ]
                  )
                )
              ),
              
              const SizedBox(width: 32),
              
              // RIGHT COLUMN: Trading Panel
              Expanded(
                flex: 6,
                child: Container(
                   padding: const EdgeInsets.all(32),
                   decoration: CyberpunkTheme.glassmorphismCard(
                     glowColor: _isBuyMode ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed,
                     glowIntensity: 0.1
                   ),
                   child: SingleChildScrollView(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.start,
                       crossAxisAlignment: CrossAxisAlignment.stretch,
                       children: [
                         // Header
                         Row(
                          children: [
                            NetworkCryptoLogo(logoUrl: selectedCryptoData.logoUrl, symbol: selectedCryptoData.symbol, size: 64),
                            const SizedBox(width: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(selectedCryptoData.name, style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text('\$${selectedCryptoData.price.toString()}', style: GoogleFonts.inter(fontSize: 24, color: CyberpunkTheme.primaryBlue)),
                              ],
                            )
                          ],
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // Balance Info
                         Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildBalanceInfo('CASH', '\$${gameState.balance.toStringAsFixed(2)}', Icons.wallet),
                              _buildBalanceInfo(
                                _isMarginMode ? 'USDT WALLET' : 'OWNED', 
                                _isMarginMode 
                                  ? '\$${(gameState.holdings['tether'] ?? 0).toStringAsFixed(2)} USDT'
                                  : '${(gameState.holdings[selectedCryptoData.id] ?? 0).toStringAsFixed(6)} ${selectedCryptoData.symbol}', 
                                Icons.token
                              ),
                            ]
                         ),
                        
                        const SizedBox(height: 32),
                        
                        // Mode Toggle
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: _buildModeBtn('SPOT', !_isMarginMode)),
                              Expanded(child: _buildModeBtn('MARGIN', _isMarginMode)),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Trade Toggle (Buy/Sell or Long/Short)
                        Row(
                          children: [
                            Expanded(child: _buildToggleBtn(_isMarginMode ? 'LONG' : 'BUY', true)),
                            Expanded(child: _buildToggleBtn(_isMarginMode ? 'SHORT' : 'SELL', false)),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Input
                        TextField(
                          controller: _amountController,
                          style: const TextStyle(fontSize: 24, color: Colors.white),
                          decoration: InputDecoration(
                            labelText: _isMarginMode ? 'Collateral (USDT)' : 'Amount (${selectedCryptoData.symbol})',
                            filled: true,
                            fillColor: Colors.black26, 
                            border: const OutlineInputBorder(),
                            suffixText: _isMarginMode ? 'USDT' : selectedCryptoData.symbol,
                          ),
                        ),
                        
                        // Leverage Slider (Margin Mode Only)
                        if (_isMarginMode) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(8),
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
                                      child: Text('${_leverage.toInt()}x', 
                                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: CyberpunkTheme.primaryBlue, fontSize: 16)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: CyberpunkTheme.primaryBlue,
                                    inactiveTrackColor: Colors.grey.shade800,
                                    thumbColor: CyberpunkTheme.primaryBlue,
                                    overlayColor: CyberpunkTheme.primaryBlue.withOpacity(0.2),
                                    valueIndicatorColor: CyberpunkTheme.primaryBlue,
                                  ),
                                  child: Slider(
                                    value: _leverage,
                                    min: 1,
                                    max: 1000,
                                    divisions: 999,
                                    label: '${_leverage.toInt()}x',
                                    onChanged: (value) => setState(() => _leverage = value),
                                  ),
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
                                  final entryPrice = _capturedEntryPrice ?? selectedCryptoData.price;
                                  
                                  // Liquidation: lose 95% of collateral
                                  final liqPrice = _isBuyMode
                                      ? entryPrice * (1 - 0.95 / _leverage)
                                      : entryPrice * (1 + 0.95 / _leverage);
                                  return Column(
                                    children: [
                                      _buildPositionDetail('Position Size', '\$${positionSize.toStringAsFixed(2)}'),
                                      _buildPositionDetail('Market Price', '\$${entryPrice.toStringAsFixed(2)}'),
                                      _buildPositionDetail('Est. Liq. Price', '\$${liqPrice.toStringAsFixed(2)}', 
                                        color: CyberpunkTheme.accentRed),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // Quick Amount Buttons
                        Row(
                          children: [
                            _buildQuickAmountButton('25%', 0.25, gameState, selectedCryptoData),
                            const SizedBox(width: 8),
                            _buildQuickAmountButton('50%', 0.50, gameState, selectedCryptoData),
                            const SizedBox(width: 8),
                            _buildQuickAmountButton('75%', 0.75, gameState, selectedCryptoData),
                            const SizedBox(width: 8),
                            _buildQuickAmountButton('MAX', 1.0, gameState, selectedCryptoData),
                          ],
                        ),
  
                        const SizedBox(height: 24),
                        
                         // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () => _executeTrade(context, gameState, selectedCryptoData),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getActionColor(),
                            ),
                            child: Text(_getActionLabel(), style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        
                        if (_isMarginMode && gameState.activePositions.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 16),
                          Text('ACTIVE POSITIONS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: CyberpunkTheme.primaryBlue)),
                          const SizedBox(height: 16),
                          ...gameState.activePositions.map((p) => _buildPositionItem(context, p, priceProvider, gameState)),
                        ],
                       ]
                     ),
                   ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(String label, double percentage, GameStateProvider gameState, CryptoData crypto) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
           double amount;
          // Use 99.99% for MAX to avoid floating-point precision errors causing "insufficient funds"
          final safePercentage = percentage == 1.0 ? 0.9999 : percentage;
          
          if (_isMarginMode) {
            // Margin Mode: Collateral is always USDT
            final usdtHoldings = gameState.holdings['tether'] ?? 0.0;
            amount = usdtHoldings * safePercentage;
          } else if (_isBuyMode) {
             // Spot Buy Mode
             final maxAmount = gameState.balance / crypto.price;
             amount = maxAmount * safePercentage;
          } else {
            // Spot Sell Mode
            final holdings = gameState.holdings[crypto.id] ?? 0.0;
            amount = holdings * safePercentage;
          }
          _amountController.text = _isMarginMode 
              ? amount.toStringAsFixed(2) 
              : amount.toStringAsFixed(8);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: _isBuyMode ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed,
          side: BorderSide(color: (_isBuyMode ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed).withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
  
  Widget _buildBalanceInfo(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, color: Colors.grey, size: 16), const SizedBox(width: 8), Text(label, style: const TextStyle(color: Colors.grey))]),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildToggleBtn(String label, bool isPrimary) {
    // isPrimary means Buy or Long
    final isActive = _isBuyMode == isPrimary;
    final color = isPrimary ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed;
    return GestureDetector(
      onTap: () => setState(() {
         _isBuyMode = isPrimary;
         _isShort = !isPrimary;
         _amountController.clear();
      }),
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: isActive ? color : Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: TextStyle(
          color: isActive ? color : Colors.grey,
          fontWeight: FontWeight.bold, fontSize: 18
        )),
      ),
    );
  }

  Widget _buildModeBtn(String label, bool isActive) {
    final gameState = context.read<GameStateProvider>();
    final usdtLaunchDate = DateTime(2014, 10, 6);
    final isMarginAvailable = gameState.gameDate.isAfter(usdtLaunchDate) || 
                               gameState.gameDate.isAtSameMomentAs(usdtLaunchDate);
    
    return GestureDetector(
      onTap: () {
        if (label == 'MARGIN' && !isMarginAvailable) {
          CryptoToast.error(context, 'MARGIN LOCKED! Requires USDT (Oct 6, 2014)');
          return;
        }
        setState(() {
           _isMarginMode = label == 'MARGIN';
           _amountController.clear();
           // Capture price when entering margin mode
           if (_isMarginMode) {
             final priceProvider = context.read<CryptoPriceProvider>();
             final crypto = priceProvider.getCrypto(_selectedCrypto!);
             if (crypto != null) {
               _capturedEntryPrice = crypto.price;
             }
           }
        });
      },
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Colors.white10 : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: TextStyle(
          color: isActive ? Colors.white : Colors.grey,
          fontWeight: FontWeight.bold, fontSize: 14
        )),
      ),
    );
  }

  Color _getActionColor() {
     if (_isMarginMode) {
       return _isBuyMode ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed;
     }
     return _isBuyMode ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed;
  }

  String _getActionLabel() {
    if (_isMarginMode) {
      return _isBuyMode ? 'OPEN LONG' : 'OPEN SHORT';
    }
    return _isBuyMode ? 'CONFIRM BUY' : 'CONFIRM SELL';
  }

  Widget _buildPositionItem(BuildContext context, MarginPosition p, CryptoPriceProvider prices, GameStateProvider gameState) {
    final currentPrice = prices.getPrice(p.cryptoId);
    final pnl = p.calculatePnL(currentPrice);
    final pnlColor = pnl >= 0 ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentRed;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border.all(color: pnlColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (p.type == PositionType.short) ? CyberpunkTheme.accentRed.withOpacity(0.2) : CyberpunkTheme.accentGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: (p.type == PositionType.short) ? CyberpunkTheme.accentRed : CyberpunkTheme.accentGreen),
            ),
            child: Text((p.type == PositionType.short) ? 'SHORT' : 'LONG', style: TextStyle(fontSize: 10, color: (p.type == PositionType.short) ? CyberpunkTheme.accentRed : CyberpunkTheme.accentGreen, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.cryptoId.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                Text('Market Price: \$${p.entryPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 11, color: CyberpunkTheme.textTertiary)),
                Text('Current Price: \$${currentPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 11, color: CyberpunkTheme.primaryBlue.withOpacity(0.8))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${pnl >= 0 ? "+" : ""}\$${pnl.toStringAsFixed(2)} USDT', style: TextStyle(fontWeight: FontWeight.bold, color: pnlColor)),
              Text('${(pnl / p.amount * 100).toStringAsFixed(2)}% (x${p.leverage.toInt()})', style: TextStyle(fontSize: 10, color: pnlColor)),
            ],
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54, size: 20),
            onPressed: () => gameState.closeMarginPosition(p.id, currentPrice),
          )
        ],
      ),
    );
  }
  
  void _executeTrade(BuildContext context, GameStateProvider gameState, CryptoData crypto) {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;
    
    bool success = false;
    
    if (_isMarginMode) {
      // Block USDT from margin trading entirely
      if (crypto.id == 'tether' || crypto.symbol.toUpperCase() == 'USDT') {
        CryptoToast.error(context, 'USDT cannot be traded on margin!');
        return;
      }
      // For Margin, "amount" is the USDT collateral
      success = gameState.openMarginPosition(
        coinId: crypto.id,
        amount: amount,
        entryPrice: _capturedEntryPrice ?? crypto.price,
        leverage: _leverage,
        isShort: !_isBuyMode,
      );
    } else {
      if (_isBuyMode) {
         success = gameState.buyCrypto(crypto.id, amount, crypto.price);
      } else {
         success = gameState.sellCrypto(crypto.id, amount, crypto.price);
      }
    }
    
    if (success) {
      String msg = '';
      if (_isMarginMode) {
        msg = '🚀 Opened ${_leverage.toInt()}x ${_isBuyMode ? "LONG" : "SHORT"} on ${crypto.symbol} with \$${amount.toStringAsFixed(2)} collateral';
      } else {
        final usdValue = amount * crypto.price;
        if (_isBuyMode) {
          msg = '💰 Bought ${amount.toStringAsFixed(6)} ${crypto.symbol} for \$${usdValue.toStringAsFixed(2)}';
        } else {
          msg = '💸 Sold ${amount.toStringAsFixed(6)} ${crypto.symbol} for \$${usdValue.toStringAsFixed(2)}';
        }
      }
      CryptoToast.success(context, msg);
      _amountController.clear();
    } else {
      CryptoToast.error(context, 'Transaction failed! Check balance.');
    }
  }
  
  Widget _buildPositionDetail(String label, String value, {Color? color}) {
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
}
