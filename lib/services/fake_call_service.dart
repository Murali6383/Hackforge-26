import 'dart:async';
import 'package:flutter/foundation.dart';

/// Fake call simulation service to escape uncomfortable situations
class FakeCallService {
  Timer? _callTimer;

  /// Schedule a fake call after [delaySeconds]
  void scheduleFakeCall({
    required int delaySeconds,
    required Function onCallStart,
  }) {
    _callTimer?.cancel();
    _callTimer = Timer(Duration(seconds: delaySeconds), () {
      debugPrint('Fake call triggered');
      onCallStart();
    });
    debugPrint('Fake call scheduled in $delaySeconds seconds');
  }

  /// Cancel scheduled fake call
  void cancelFakeCall() {
    _callTimer?.cancel();
    _callTimer = null;
  }

  /// Get list of fake call presets
  List<FakeCallPreset> getPresets() {
    return [
      FakeCallPreset(
        name: 'Mom',
        number: '+91 98765 43210',
        delay: 10,
        icon: '👩',
      ),
      FakeCallPreset(
        name: 'Boss',
        number: '+91 98765 43211',
        delay: 15,
        icon: '👔',
      ),
      FakeCallPreset(
        name: 'Best Friend',
        number: '+91 98765 43212',
        delay: 5,
        icon: '👫',
      ),
      FakeCallPreset(
        name: 'Emergency (112)',
        number: '112',
        delay: 3,
        icon: '🚨',
      ),
    ];
  }

  void dispose() {
    cancelFakeCall();
  }
}

class FakeCallPreset {
  final String name;
  final String number;
  final int delay; // seconds
  final String icon;

  FakeCallPreset({
    required this.name,
    required this.number,
    required this.delay,
    required this.icon,
  });
}
