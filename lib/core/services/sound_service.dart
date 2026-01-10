// Sound service for game audio feedback
// Note: Uses web-compatible audio approach
import 'package:flutter/foundation.dart';

/// Sound service for game audio
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();
  
  bool _enabled = true;
  double _volume = 0.7;
  
  bool get enabled => _enabled;
  double get volume => _volume;
  
  void setEnabled(bool value) => _enabled = value;
  void setVolume(double value) => _volume = value.clamp(0.0, 1.0);
  
  /// Play click sound
  void playClick() {
    if (!_enabled) return;
    // Web audio API would be used here
    debugPrint('🔊 Click sound');
  }
  
  /// Play coin earned sound
  void playCoinEarn() {
    if (!_enabled) return;
    debugPrint('🔊 Coin earned!');
  }
  
  /// Play achievement unlocked sound  
  void playAchievement() {
    if (!_enabled) return;
    debugPrint('🔊 Achievement unlocked!');
  }
  
  /// Play trade completed sound
  void playTrade() {
    if (!_enabled) return;
    debugPrint('🔊 Trade completed!');
  }
  
  /// Play level up / milestone sound
  void playLevelUp() {
    if (!_enabled) return;
    debugPrint('🔊 Level up!');
  }
  
  /// Play error sound
  void playError() {
    if (!_enabled) return;
    debugPrint('🔊 Error!');
  }
  
  /// Play notification sound
  void playNotification() {
    if (!_enabled) return;
    debugPrint('🔊 Notification!');
  }
}

/// Global sound service instance
final soundService = SoundService();
