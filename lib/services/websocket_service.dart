import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants.dart';

/// WebSocket service for real-time location sharing during emergencies
class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  /// Connect to WebSocket server
  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(AppConstants.wsUrl));
      _isConnected = true;
      debugPrint('WebSocket connected');

      _channel!.stream.listen(
        (message) {
          debugPrint('WS received: $message');
        },
        onError: (error) {
          debugPrint('WS error: $error');
          _isConnected = false;
        },
        onDone: () {
          debugPrint('WS connection closed');
          _isConnected = false;
        },
      );
    } catch (e) {
      debugPrint('WS connection failed (expected in demo mode): $e');
      _isConnected = false;
    }
  }

  /// Send live location update
  void sendLocation(double latitude, double longitude, String userId) {
    final data = jsonEncode({
      'type': 'location_update',
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(data);
        debugPrint('WS sent location: $latitude, $longitude');
      } catch (e) {
        debugPrint('WS send failed: $e');
      }
    } else {
      debugPrint('WS not connected, location logged locally: $data');
    }
  }

  /// Send SOS alert via WebSocket
  void sendSOSAlert(String userId, String userName, double lat, double lng) {
    final data = jsonEncode({
      'type': 'sos_alert',
      'userId': userId,
      'userName': userName,
      'latitude': lat,
      'longitude': lng,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(data);
      } catch (e) {
        debugPrint('WS SOS send failed: $e');
      }
    }
  }

  /// Disconnect
  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }

  void dispose() {
    disconnect();
  }
}
