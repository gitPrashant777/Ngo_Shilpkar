import 'dart:async';
import 'package:flutter/services.dart';

class EmergencyAlarm {
  static bool _isPlaying = false;
  static Timer? _timer;

  static void playOnce({Duration duration = const Duration(seconds: 15)}) {
    if (_isPlaying) return;
    _isPlaying = true;

    int ticks = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      SystemSound.play(SystemSoundType.alert);
      ticks += 1;
      if (ticks >= duration.inSeconds) {
        timer.cancel();
        _isPlaying = false;
      }
    });
  }

  static void stop() {
    _timer?.cancel();
    _isPlaying = false;
  }
}
