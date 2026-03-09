import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoiceSosSettingsProvider extends ChangeNotifier {
  static const String _voiceSosEnabledKey = 'voice_sos_enabled';

  bool _isEnabled = true;
  bool _isLoaded = false;

  bool get isEnabled => _isEnabled;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_voiceSosEnabledKey) ?? true;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_voiceSosEnabledKey, enabled);
  }
}
