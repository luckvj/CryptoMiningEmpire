import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/cyberpunk_theme.dart';
import '../core/services/api_service.dart';
import '../providers/game_state_provider.dart';
import '../providers/crypto_price_provider.dart';

/// Trading screen with price charts and buy/sell functionality
class TradingScreen extends StatefulWidget {
  const TradingScreen({super.key});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  String? _selectedCrypto;
  final _amountController = TextEditingController();
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateProvider>();
    final priceProvider = context.watch<CryptoPriceProvider>();
    
    _selectedCrypto ??= priceProvider.cryptoData.keys.first;
    final selectedCryptoData = priceProvider.getCrypto(_selectedCrypto!);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRADING TERMINAL'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crypto Selector
            _buildCryptoSelector(priceProvider),
            
            const SizedBox(height: 24),
            
            // Price Chart
            if (selectedCryptoData != null)
              _buildPriceChart(selectedCryptoData),
            
            const SizedBox(height: 24),
            
            // Trading Panel
            if (selectedCryptoData != null)
              _buildTradingPanel(context, gameState, selectedCryptoData),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCryptoSelector(CryptoPriceProvider priceProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CyberpunkTheme.modernCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT CRYPTOCURRENCY',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: CyberpunkTheme.textTertiary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCrypto,
            decoration: InputDecoration(
              filled: true,
              fillColor: CyberpunkTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: CyberpunkTheme.primaryBlue),
              ),
            ),
            dropdownColor: CyberpunkTheme.surfaceColor,
            style: GoogleFonts.inter(
              color: CyberpunkTheme.textPrimary,
              fontSize: 16,
            ),
            items: priceProvider.cryptoData.values.map((crypto) {
              return DropdownMenuItem(
                value: crypto.id,
                child: Text('${crypto.symbol} - ${crypto.name}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedCrypto = value);
              if (value != null) {
                priceProvider.fetchHistoricalData(value, 7);
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriceChart(CryptoData crypto) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: CyberpunkTheme.modernCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crypto.symbol,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: CyberpunkTheme.primaryBlue,
                    ),
                  ),
                  Text(
                    '\$${crypto.price.toStringAsFixed(crypto.price < 1 ? 6 : 2)}',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      color: CyberpunkTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (crypto.isPriceUp ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentOrange).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: crypto.isPriceUp ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentOrange,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      crypto.isPriceUp ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: crypto.isPriceUp ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${crypto.change24h.toStringAsFixed(2)}%',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: crypto.isPriceUp ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildSimpleChart(crypto),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSimpleChart(CryptoData crypto) {
    // Simple line chart simulation
    final spots = List.generate(20, (index) {
      final variance = (crypto.change24h / 100) * crypto.price;
      final randomChange = (index - 10) * variance / 10;
      return FlSpot(index.toDouble(), crypto.price + randomChange);
    });
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: crypto.price / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: CyberpunkTheme.textPrimary,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                crypto.isPriceUp ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentOrange,
                crypto.isPriceUp ? CyberpunkTheme.primaryBlue : CyberpunkTheme.accentPurple,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  (crypto.isPriceUp ? CyberpunkTheme.accentGreen : CyberpunkTheme.accentOrange).withOpacity(0.3),
                  (crypto.isPriceUp ? CyberpunkTheme.primaryBlue : CyberpunkTheme.accentPurple).withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTradingPanel(
    BuildContext context,
    GameStateProvider gameState,
    CryptoData crypto,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CyberpunkTheme.modernCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRADE ${crypto.symbol}',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CyberpunkTheme.accentPurple,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Balance Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR BALANCE',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: CyberpunkTheme.textTertiary,
                    ),
                  ),
                  Text(
                    '\$${gameState.balance.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CyberpunkTheme.accentGreen,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'YOUR ${crypto.symbol}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: CyberpunkTheme.textTertiary,
                    ),
                  ),
                  Text(
                    '${(gameState.holdings[crypto.id] ?? 0.0).toStringAsFixed(8)}',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CyberpunkTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Amount Input
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(color: CyberpunkTheme.textPrimary),
            decoration: InputDecoration(
              labelText: 'AMOUNT',
              labelStyle: GoogleFonts.inter(
                color: CyberpunkTheme.primaryBlue,
              ),
              suffixText: crypto.symbol,
              suffixStyle: GoogleFonts.inter(
                color: CyberpunkTheme.textTertiary,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Buy/Sell Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleBuy(context, gameState, crypto),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CyberpunkTheme.accentGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'BUY',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleSell(context, gameState, crypto),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CyberpunkTheme.accentOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'SELL',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _handleBuy(BuildContext context, GameStateProvider gameState, CryptoData crypto) {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError(context, 'Please enter a valid amount');
      return;
    }
    
    if (gameState.buyCrypto(crypto.id, amount, crypto.price)) {
      _showSuccess(context, 'Bought ${amount.toStringAsFixed(8)} ${crypto.symbol}');
      _amountController.clear();
    } else {
      _showError(context, 'Insufficient funds!');
    }
  }
  
  void _handleSell(BuildContext context, GameStateProvider gameState, CryptoData crypto) {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError(context, 'Please enter a valid amount');
      return;
    }
    
    if (gameState.sellCrypto(crypto.id, amount, crypto.price)) {
      _showSuccess(context, 'Sold ${amount.toStringAsFixed(8)} ${crypto.symbol}');
      _amountController.clear();
    } else {
      _showError(context, 'Insufficient ${crypto.symbol}!');
    }
  }
  
  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CyberpunkTheme.accentGreen,
      ),
    );
  }
  
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CyberpunkTheme.accentOrange,
      ),
    );
  }
}
