import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../core/constants.dart';

/// Location state provider for tracking user position
class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  double _latitude = AppConstants.defaultLat;
  double _longitude = AppConstants.defaultLng;
  bool _isTracking = false;
  bool _hasPermission = false;
  StreamSubscription<Position>? _subscription;

  double get latitude => _latitude;
  double get longitude => _longitude;
  bool get isTracking => _isTracking;
  bool get hasPermission => _hasPermission;
  LocationService get service => _locationService;

  /// Initialize and get initial position
  Future<void> init() async {
    _hasPermission = await _locationService.checkPermissions();
    if (_hasPermission) {
      final pos = await _locationService.getCurrentPosition();
      if (pos != null) {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      }
    }
    notifyListeners();
  }

  /// Start continuous tracking
  void startTracking() {
    _locationService.startTracking();
    _isTracking = true;
    _subscription = _locationService.locationStream.listen((position) {
      _latitude = position.latitude;
      _longitude = position.longitude;
      notifyListeners();
    });
    notifyListeners();
  }

  /// Stop tracking
  void stopTracking() {
    _locationService.stopTracking();
    _subscription?.cancel();
    _isTracking = false;
    notifyListeners();
  }

  /// Update position manually (for map movements)
  void updatePosition(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _locationService.dispose();
    super.dispose();
  }
}
