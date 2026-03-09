import 'package:flutter/material.dart';
import '../models/emergency_event.dart';
import '../services/sos_service.dart';
import '../services/location_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/sms_service.dart';
import '../services/websocket_service.dart';

/// Emergency state provider managing SOS events
class EmergencyProvider extends ChangeNotifier {
  late final SosService _sosService;
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<EmergencyEvent> _events = [];
  bool _isEmergencyActive = false;
  EmergencyEvent? _activeEvent;
  bool _isLoading = false;
  int _countdownSeconds = 0;

  List<EmergencyEvent> get events => _events;
  bool get isEmergencyActive => _isEmergencyActive;
  EmergencyEvent? get activeEvent => _activeEvent;
  bool get isLoading => _isLoading;
  int get countdownSeconds => _countdownSeconds;

  EmergencyProvider() {
    _sosService = SosService(
      locationService: LocationService(),
      databaseService: _databaseService,
      notificationService: _notificationService,
      smsService: SmsService(),
      webSocketService: WebSocketService(),
    );
  }

  /// Trigger SOS
  Future<void> triggerSOS({
    required String userId,
    required String userName,
    String type = 'sos_button',
    List<String> emergencyPhones = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _activeEvent = await _sosService.triggerSOS(
        userId: userId,
        userName: userName,
        type: type,
        emergencyPhones: emergencyPhones,
      );
      _isEmergencyActive = true;
      _events.insert(0, _activeEvent!);
    } catch (e) {
      debugPrint('SOS trigger failed: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Resolve active emergency
  Future<void> resolveEmergency({String? notes}) async {
    await _sosService.resolveEmergency(notes: notes);
    _isEmergencyActive = false;
    _activeEvent = null;
    notifyListeners();
  }

  /// Load past events
  Future<void> loadEvents() async {
    try {
      _events = await _databaseService.getEmergencies();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
  }

  /// Update countdown for SOS activation
  void setCountdown(int seconds) {
    _countdownSeconds = seconds;
    notifyListeners();
  }

  @override
  void dispose() {
    _sosService.dispose();
    super.dispose();
  }
}
