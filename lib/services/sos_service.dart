import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/emergency_event.dart';
import 'location_service.dart';
import 'database_service.dart';
import 'notification_service.dart';
import 'sms_service.dart';
import 'websocket_service.dart';

/// Core SOS service that orchestrates emergency alerts
class SosService {
  final LocationService _locationService;
  final DatabaseService _databaseService;
  final NotificationService _notificationService;
  final SmsService _smsService;
  final WebSocketService _webSocketService;

  EmergencyEvent? _activeEmergency;
  Timer? _trackingTimer;

  EmergencyEvent? get activeEmergency => _activeEmergency;
  bool get isEmergencyActive => _activeEmergency != null;

  SosService({
    required LocationService locationService,
    required DatabaseService databaseService,
    required NotificationService notificationService,
    required SmsService smsService,
    required WebSocketService webSocketService,
  })  : _locationService = locationService,
        _databaseService = databaseService,
        _notificationService = notificationService,
        _smsService = smsService,
        _webSocketService = webSocketService;

  /// Trigger SOS alert
  Future<EmergencyEvent> triggerSOS({
    required String userId,
    required String userName,
    String type = 'sos_button',
    List<String> emergencyPhones = const [],
  }) async {
    // Get current location
    final position = await _locationService.getCurrentPosition();
    final lat = position?.latitude ?? 28.6139;
    final lng = position?.longitude ?? 77.2090;

    // Create emergency event
    final event = EmergencyEvent(
      id: const Uuid().v4(),
      userId: userId,
      userName: userName,
      latitude: lat,
      longitude: lng,
      type: type,
      status: 'active',
      trackingPath: [
        LocationPoint(latitude: lat, longitude: lng),
      ],
    );

    _activeEmergency = event;

    // Store in local database
    await _databaseService.insertEmergency(event);

    // Send notifications
    await _notificationService.showEmergencyNotification(
      title: '🆘 SOS ALERT ACTIVE',
      body: 'Emergency triggered by $userName. Location shared with contacts.',
    );

    // Send SMS to emergency contacts
    for (final phone in emergencyPhones) {
      await _smsService.sendEmergencySMS(
        to: phone,
        message:
            '🆘 EMERGENCY ALERT from $userName! Location: https://maps.google.com/?q=$lat,$lng',
      );
    }

    // Notify volunteers/authorities and start live location sharing.
    _webSocketService.sendSOSAlert(userId, userName, lat, lng);
    _webSocketService.sendLocation(lat, lng, userId);
    await _notificationService.showVolunteerNotification(
      title: 'Volunteer Alert',
      body: '$userName triggered SOS. Authorities and volunteers notified.',
    );

    // Start continuous tracking
    _startContinuousTracking(userId);

    debugPrint('SOS triggered: ${event.id} at $lat, $lng');
    return event;
  }

  /// Cancel/resolve active emergency
  Future<void> resolveEmergency({String? notes}) async {
    if (_activeEmergency == null) return;

    _activeEmergency = _activeEmergency!.copyWith(
      status: 'resolved',
      notes: notes,
    );

    await _databaseService.updateEmergencyStatus(
      _activeEmergency!.id,
      'resolved',
    );

    _stopContinuousTracking();

    await _notificationService.showEmergencyNotification(
      title: '✅ Emergency Resolved',
      body: 'Your emergency has been marked as resolved.',
    );

    _activeEmergency = null;
  }

  void _startContinuousTracking(String userId) {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final position = await _locationService.getCurrentPosition();
      if (position != null && _activeEmergency != null) {
        _webSocketService.sendLocation(
          position.latitude,
          position.longitude,
          userId,
        );
      }
    });
  }

  void _stopContinuousTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
  }

  void dispose() {
    _stopContinuousTracking();
  }
}
