# CryptoMiningEmpire

A cryptocurrency mining idle game built with Flutter. Mine various cryptocurrencies, buy GPUs, upgrade your mining operation, and watch your crypto portfolio grow!

## 🎮 Features

- **Real Mining Calculations**: Uses actual block rewards, network hashrate, and difficulty from WhatToMine API
- **25+ Mineable Coins**: Bitcoin, Ethereum Classic, Litecoin, Monero, Ravencoin, and many more
- **Live Price Data**: Real-time cryptocurrency prices from CoinGecko API
- **GPU Mining**: Buy and upgrade GPUs to increase your hashrate
- **Click Mining**: Manual mining with upgradeable click power
- **Profitability Analysis**: Compare daily earnings across different cryptocurrencies
- **Modern UI**: Cyberpunk-themed design with smooth animations

## 📸 Screenshots

*(Add screenshots here)*

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (3.0 or higher): https://flutter.dev/docs/get-started/install
- **Windows development environment** (for Windows builds)
- Git (optional, for cloning)

### Installation

1. **Clone or download** this repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/CryptoMiningEmpire.git
   cd CryptoMiningEmpire
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the game**:
   ```bash
   flutter run -d windows
   ```

### Optional: CoinMarketCap API Key

The game uses CoinGecko API by default and works perfectly fine without additional setup. If you want to use CoinMarketCap features (optional):

1. Get a free API key: https://coinmarketcap.com/api/
2. Run with your key:
   ```bash
   flutter run -d windows --dart-define=COINMARKETCAP_API_KEY=your_key_here
   ```

## 🎯 How to Play

1. **Start Mining**: The game begins with Bitcoin mining at a low hashrate
2. **Click to Mine**: Click the big mining button to manually mine coins
3. **Buy GPUs**: Visit the Shop screen to purchase GPUs and increase hashrate
4. **Switch Coins**: Navigate to Mining screen to switch between different cryptocurrencies
5. **Check Profitability**: See which coins are most profitable with your current setup
6. **Grow Your Portfolio**: Watch your cryptocurrency holdings grow over time

## 🏗️ Build for Release

### Windows

```bash
flutter build windows --release
```

The executable will be in: `build/windows/x64/runner/Release/crypto_mining_empire.exe`

### Web (Coming Soon)

```bash
flutter build web --release
```

## 📊 Mining Calculations

All mining calculations use real-world formulas:

```
Daily Coins = (86400 / Block Time) × Block Reward × (Your Hashrate / Network Hashrate)
Daily Revenue = Daily Coins × Exchange Rate
Daily Profit = Daily Revenue - Power Costs
```

Data is fetched from:
- **WhatToMine API**: Network hashrate, block rewards, block times
- **CoinGecko API**: Real-time cryptocurrency prices

## 🛠️ Tech Stack

- **Flutter/Dart**: Cross-platform framework
- **Provider**: State management
- **HTTP**: API requests
- **Shared Preferences**: Local data persistence
- **Google Fonts**: Typography
- **Flutter Animate**: UI animations

## 📁 Project Structure

```
lib/
├── core/
│   ├── models/        # Data models (mining data, locations)
│   ├── services/      # API services (WhatToMine, CoinGecko)
│   ├── theme/         # App theme and styling
│   └── utils/         # Utility functions
├── providers/         # State management
├── screens/           # App screens (home, mining, shop, etc.)
├── widgets/           # Reusable UI components
└── main.dart          # App entry point
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- **WhatToMine.com**: For providing free mining profitability data
- **CoinGecko**: For free cryptocurrency price API
- **Flutter Community**: For the amazing framework and packages

## 📧 Contact

Your Name - [@yourhandle](https://twitter.com/yourhandle) - email@example.com

Project Link: [https://github.com/YOUR_USERNAME/CryptoMiningEmpire](https://github.com/YOUR_USERNAME/CryptoMiningEmpire)

## 🎮 Future Features

- [ ] Mobile support (Android/iOS)
- [ ] More cryptocurrencies
- [ ] Mining pools
- [ ] Achievements system
- [ ] Cloud save/sync
- [ ] Multiplayer features

---

Made with ❤️ and Flutter
