# Quick Test Guide - Mining Calculations Fix

## How to Test the Fixed Mining Calculations

### 1. Run the Application

```bash
cd CryptoMiningEmpire
flutter run -d windows
```

### 2. What to Look For

#### ✅ On App Startup
Watch the console for WhatToMine API loading:
```
📡 Fetching data from WhatToMine API...
✅ Loaded 50+ mineable coins from WhatToMine
```

#### ✅ On Home Screen
- Check that cryptocurrency prices are loading
- Verify the initial balance and hashrate display

#### ✅ Navigate to Mining Screen
1. Click on "Mining" tab
2. You should see:
   - **Currently Mining Card** showing Bitcoin (default)
   - **Daily Mining Rate** with coins per day
   - **Revenue in USD** per day
   - **Click Mining Button** (large animated button)
   - **Mining Profitability List** showing all mineable coins

#### ✅ Check Console Debug Output
Every 10 seconds you should see detailed mining stats:
```
⛏️  Mining BTC:
   Algorithm: SHA-256
   Network Hash: 580000000.0
   Block Reward: 6.25
   Block Time: 600s
   Your Hashrate: 10.0 MH/s
   💰 Coins/day: 0.00000002
   💵 Exchange Rate: $50000.00
   💸 Daily Revenue: $0.001
```

#### ✅ Switch Mining Coins
1. Scroll down to the profitability list
2. Click on a different coin (e.g., Ravencoin, Monero, Litecoin)
3. Watch the console output change
4. Verify the daily mining rate updates on the card

#### ✅ Buy GPUs to Increase Hashrate
1. Navigate to "Shop" screen
2. Buy a GPU (e.g., RTX 3080 - 100 MH/s)
3. Go back to Mining screen
4. Verify hashrate increased
5. Check that daily coins/revenue scaled proportionally

### 3. Expected Results

#### Low Hashrate (10-100 MH/s):
- **Bitcoin**: ~0.00000002 BTC/day ($0.001/day)
- **Monero**: ~0.02-0.7 XMR/day ($0.50-$100/day) - Note: Real CPUs mine at 0.005 MH/s
- **Ravencoin**: ~5-55 RVN/day ($0.10-$1.10/day)
- **Litecoin**: ~0.00001 LTC/day ($0.001/day)

#### High Hashrate (1000+ MH/s with multiple GPUs):
- Revenue should scale linearly with hashrate
- Example: 10x hashrate = 10x coins per day

### 4. Verify Algorithm-Specific Conversions

Switch between coins with different algorithms and verify correct calculations:

| Coin | Algorithm | Network Unit | Your 100 MH/s Converts To |
|------|-----------|--------------|---------------------------|
| Bitcoin | SHA-256 | TH/s | 0.0001 TH/s |
| Monero | RandomX | KH/s | 100,000 KH/s |
| Ravencoin | KAWPOW | MH/s | 100 MH/s |
| Zcash | Equihash | Sol/s | 100,000,000 Sol/s |
| Kaspa | kHeavyHash | PH/s | 0.0000001 PH/s |

### 5. Common Issues to Check

❌ **If you see very high unrealistic earnings:**
- Check console for calculation errors
- Verify unit conversion is working

❌ **If you see zero earnings:**
- Check if WhatToMine API loaded successfully
- Verify the coin is marked as mineable
- Check network hashrate is not zero

❌ **If profitability sorting seems wrong:**
- Remember it's based on YOUR hashrate and current prices
- Some coins may not be profitable with low hashrate

### 6. Testing Checklist

- [ ] App loads without errors
- [ ] WhatToMine data loads successfully
- [ ] Daily mining rate shows on current mining card
- [ ] Console shows detailed debug output every 10s
- [ ] Can switch between different mining coins
- [ ] Hashrate changes affect earnings proportionally
- [ ] All mineable coins show Coins/Day in profitability list
- [ ] USD revenue calculations are reasonable
- [ ] Exchange rates are current (from CoinGecko)

### 7. Performance Testing

1. **Real-time mining**: Leave app running for 1 minute
2. Check that your holdings increase
3. Verify amount matches the "per second" rate × 60
4. Example: If showing 0.01 coins/sec, after 60s you should have ~0.6 coins

## Quick Formula Reference

```
Your Share = Your Hashrate (converted) / Network Hashrate
Blocks Per Day = 86400 seconds / Block Time
Daily Coins = Blocks Per Day × Block Reward × Your Share
Daily Revenue = Daily Coins × Exchange Rate
Daily Profit = Daily Revenue - Power Cost
```

## Need Help?

Check `MINING-CALCULATIONS-FIXED.md` for detailed technical documentation on all changes made.
