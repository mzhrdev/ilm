import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class CallAudioService {
  static final CallAudioService instance = CallAudioService._();
  CallAudioService._();

  bool _isPlaying = false;

  /// Plays incoming ringtone loop and triggers subtle haptics
  void startRingtone() {
    if (_isPlaying) return;
    _isPlaying = true;

    FlutterRingtonePlayer().playRingtone(looping: true, volume: 1.0, asAlarm: false);

    HapticFeedback.vibrate();
  }

  /// Plays outgoing ringback sound (dialing tone)
  void startOutgoingTone() {
    if (_isPlaying) return;
    _isPlaying = true;

    FlutterRingtonePlayer().play(
      android: AndroidSounds.ringtone,
      ios: IosSounds.glass,
      looping: true,
      volume: 0.8,
    );
  }

  /// Stops all playing tones immediately
  void stop() {
    if (!_isPlaying) return;
    _isPlaying = false;

    FlutterRingtonePlayer().stop();
  }
}
