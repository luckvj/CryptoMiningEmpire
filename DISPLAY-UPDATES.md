# Display Updates - Coins Instead of Dollars

## Changes Made

### 1. Mining Screen - Current Mining Card
**Changed**: Daily profit display now shows **coins per day** instead of dollar value

**Before**:
- Header showed dollar profit: "$X.XX/day"

**After**:
- Main display: Coin amount in full decimal format (e.g., "0.00000123 BTC per day")
- Secondary display: Dollar equivalent below (e.g., "$0.06/day")
- **No scientific notation** - shows full decimal places

### 2. Profitability Card List
**Changed**: The prominent value now shows **daily coins** instead of dollar profit

**Before**:
- Right side showed: "PROFITABLE" / "NOT PROFITABLE"
- Below that: "$X.XX/day" profit

**After**:
- Right side shows: "DAILY COINS"
- Below that: Coin amount in full decimal format
- Bottom stats still show: Coins/Day, Revenue/Day, Monthly Profit

### 3. Number Formatting
**Updated**: Removed scientific notation (e.g., 1.23e-7)

**New Format**:
- Very small amounts (< 0.0001): Shows 8 decimal places (0.00000123)
- Small amounts (0.0001 - 1): Shows 6 decimal places (0.123456)
- Medium amounts (1 - 1000): Shows 4 decimal places (12.3456)
- Large amounts (> 1000): Shows 2 decimal places (1234.56)

## Visual Examples

### Bitcoin Mining (100 MH/s)
```
DAILY MINING RATE
0.00000002
BTC per day
$0.001/day
```

### Ravencoin Mining (100 MH/s)
```
DAILY MINING RATE
55.4000
RVN per day
$1.11/day
```

### Profitability Card
```
RVN   [KAWPOW]   [ACTIVE]
Ravencoin

DAILY COINS
55.4000

Coins/Day    Revenue/Day    Monthly Profit
55.4000      $1.11          $33
```

## Benefits

✅ **More Informative**: Users see exactly how many coins they earn
✅ **Educational**: Shows real mining rates (not just dollars)
✅ **Accurate**: Full decimal display for very small amounts
✅ **Readable**: No confusing scientific notation
✅ **Dollar Context**: USD value still shown for reference

## Testing

The app has been rebuilt successfully. To verify:

1. Run the app
2. Navigate to Mining screen
3. Check the daily mining rate shows coins (not just dollars)
4. Scroll through the profitability list
5. Verify each coin shows daily coin amount prominently
6. Check Bitcoin shows full decimals like "0.00000002" instead of "2.00e-8"

## Files Modified

- `lib/screens/mining_screen.dart` - Updated formatting, removed scientific notation
- `lib/widgets/mining_profitability_card.dart` - Changed daily profit to daily coins display
