@echo off
echo ========================================
echo Crypto Mining Empire - Flutter App
echo ========================================
echo.
echo Cleaning previous builds...
flutter clean

echo.
echo Getting dependencies...
flutter pub get

echo.
echo Building and running on Windows...
flutter run -d windows

pause
