# GitHub Setup Guide

## ✅ API Key Removed - Safe to Upload

Your CoinMarketCap API key has been removed from the code and the project is now safe to upload to GitHub.

## What Was Changed

### 1. API Key Removed
**File**: `lib/core/services/api_service.dart`

The hardcoded API key has been replaced with an environment variable:

```dart
// OLD (REMOVED):
static const String coinMarketCapKey = 'ccbba13b9fe842eb8f3dc81e6743528e';

// NEW (SAFE):
static const String coinMarketCapKey = String.fromEnvironment(
  'COINMARKETCAP_API_KEY',
  defaultValue: '', // Users provide their own key
);
```

### 2. .gitignore Updated
Added these lines to prevent committing sensitive files:

```
# Environment variables and API keys (DO NOT COMMIT)
.env
.env.local
.env.*.local
*.key
secrets.dart
**/api_keys.dart
**/secrets/

# Temporary test files
tmp_*
temp_*
```

### 3. .env.example Created
Template file for users to set up their own API key:

```
COINMARKETCAP_API_KEY=your_api_key_here
```

## How to Upload to GitHub

### Option 1: GitHub Desktop (Easiest)

1. **Download GitHub Desktop**: https://desktop.github.com/
2. **Open the app** and sign in to your GitHub account
3. **Add repository**:
   - Click "File" → "Add local repository"
   - Select the `CryptoMiningEmpire` folder
4. **Create repository on GitHub**:
   - Click "Publish repository"
   - Name: "CryptoMiningEmpire"
   - Description: "A cryptocurrency mining idle game built with Flutter"
   - Choose public or private
   - Uncheck "Keep this code private" if you want it public
5. **Click "Publish repository"**

### Option 2: Command Line (Git)

```bash
cd CryptoMiningEmpire

# Initialize git (if not already)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - Crypto Mining Empire game"

# Create repository on GitHub.com first, then:
git remote add origin https://github.com/YOUR_USERNAME/CryptoMiningEmpire.git

# Push to GitHub
git push -u origin main
```

### Option 3: Upload via GitHub Website

1. Go to https://github.com/new
2. Name: "CryptoMiningEmpire"
3. Click "Create repository"
4. Click "uploading an existing file"
5. Drag and drop the entire `CryptoMiningEmpire` folder
6. Click "Commit changes"

## For Other Users to Use Your Code

Users who clone your repository will need to:

1. **Get their own API key** (free):
   - Visit https://coinmarketcap.com/api/
   - Sign up for free
   - Copy their API key

2. **Run with the API key**:

   **Option A**: Set environment variable (Recommended)
   ```bash
   # Windows PowerShell
   $env:COINMARKETCAP_API_KEY="their_key_here"
   flutter run
   
   # Or build with:
   flutter build windows --dart-define=COINMARKETCAP_API_KEY=their_key_here
   ```

   **Option B**: Create a .env file (Not recommended for Flutter)
   - Flutter doesn't natively support .env files
   - Would need additional package like `flutter_dotenv`

   **Option C**: Edit api_service.dart (Quick but not ideal)
   - Users can temporarily edit the defaultValue
   - Not recommended for open source

3. **The app works without the API key**:
   - Falls back to CoinGecko API
   - Still fully functional, just missing some logo features

## Recommended README Addition

Add this to your README.md:

```markdown
## Setup

### Prerequisites
- Flutter SDK (latest stable)
- Windows development environment

### API Key (Optional)
The game uses CoinGecko API by default. For CoinMarketCap features:

1. Get free API key: https://coinmarketcap.com/api/
2. Run with: 
   ```
   flutter run --dart-define=COINMARKETCAP_API_KEY=your_key_here
   ```

### Running the Game
```bash
flutter pub get
flutter run -d windows
```
```

## Double-Check Before Pushing

Run this command to verify no API key is in tracked files:

```bash
cd CryptoMiningEmpire
git grep -i "ccbba13b9fe842eb8f3dc81e6743528e"
```

If nothing is returned, you're safe! ✅

## Files Safe to Commit

✅ All `.dart` files (API key removed)
✅ `.gitignore` (updated)
✅ `.env.example` (template only)
✅ `pubspec.yaml`
✅ `README.md`
✅ All documentation `.md` files
✅ Asset files

## Files NEVER to Commit

❌ `.env` (if you create one)
❌ Any file with your actual API key
❌ `build/` folder (too large)
❌ `.dart_tool/` (generated files)
❌ `tmp_*` files (temporary test files)

## Your Repository is Now Safe! 🎉

You can upload to GitHub without exposing your API key. Users will need to get their own free API key from CoinMarketCap.
