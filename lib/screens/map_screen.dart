import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../providers/location_provider.dart';
import '../providers/map_provider.dart';
import '../widgets/risk_badge.dart';

/// Map screen with Google Maps, AI heatmap overlay, and precise live tracking.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;

  LatLng? _liveLatLng;
  bool _isFollowingUser = true;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeLiveLocation());
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeLiveLocation() async {
    if (!mounted) return;

    final locationReady = await _ensureLocationReady();
    if (!locationReady) {
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    final locationProv = context.read<LocationProvider>();
    final mapProv = context.read<MapProvider>();

    await locationProv.init();

    try {
      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        ),
      );

      final initialLatLng = LatLng(current.latitude, current.longitude);
      _applyLiveLocation(initialLatLng, animateCamera: true);
      locationProv.updatePosition(current.latitude, current.longitude);
      mapProv.loadHeatmapData(current.latitude, current.longitude);
      mapProv.checkCurrentRisk(current.latitude, current.longitude);
    } catch (_) {
      _showSnackBar('Unable to fetch current GPS location');
    }

    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
      ),
    ).listen(
      (position) {
        final latLng = LatLng(position.latitude, position.longitude);
        _applyLiveLocation(latLng, animateCamera: _isFollowingUser);
        locationProv.updatePosition(position.latitude, position.longitude);
      },
      onError: (_) {
        _showSnackBar('Live location tracking failed');
      },
    );

    if (mounted) setState(() => _isLoadingLocation = false);
  }

  Future<bool> _ensureLocationReady() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled && !await Geolocator.isLocationServiceEnabled()) {
        _showSnackBar('Location service is disabled');
        return false;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _showSnackBar('Location permission denied');
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permission denied permanently. Open app settings.');
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  void _applyLiveLocation(LatLng latLng, {required bool animateCamera}) {
    if (!mounted) return;

    setState(() {
      _liveLatLng = latLng;
    });

    if (animateCamera && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(latLng),
      );
    }
  }

  Future<void> _shareLocationOnWhatsApp() async {
    final latLng = _liveLatLng;
    if (latLng == null) {
      _showSnackBar('Live location is not available yet');
      return;
    }

    final mapsUrl = 'https://www.google.com/maps?q=${latLng.latitude},${latLng.longitude}';
    final text = 'My live location: $mapsUrl';
    final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('WhatsApp not available');
    }
  }

  Future<void> _shareLocationByEmail() async {
    final latLng = _liveLatLng;
    if (latLng == null) {
      _showSnackBar('Live location is not available yet');
      return;
    }

    final mapsUrl = 'https://www.google.com/maps?q=${latLng.latitude},${latLng.longitude}';
    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': 'My Live Location',
        'body': 'My exact live location: $mapsUrl',
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('No email app found');
    }
  }

  void _showShareSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Share via WhatsApp'),
                onTap: () {
                  Navigator.pop(context);
                  _shareLocationOnWhatsApp();
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Share via Email'),
                onTap: () {
                  Navigator.pop(context);
                  _shareLocationByEmail();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProv = context.watch<LocationProvider>();
    final mapProv = context.watch<MapProvider>();

    final fallback = LatLng(locationProv.latitude, locationProv.longitude);
    final userLocation = _liveLatLng ?? fallback;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Map'),
        actions: [
          IconButton(
            icon: Icon(
              mapProv.showHeatmap ? Icons.layers : Icons.layers_outlined,
              color: mapProv.showHeatmap ? AppColors.primary : Colors.white,
            ),
            onPressed: mapProv.toggleHeatmap,
            tooltip: 'Toggle Heatmap',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => mapProv.loadHeatmapData(
              locationProv.latitude,
              locationProv.longitude,
            ),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.share_location_outlined),
            onPressed: _showShareSheet,
            tooltip: 'Share Live Location',
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildGoogleMap(userLocation, mapProv),
          if (_isLoadingLocation)
            const Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Fetching precise live location...'),
                ),
              ),
            ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildRiskCard(mapProv),
          ),
          if (mapProv.showHeatmap)
            Positioned(
              bottom: 100,
              right: 16,
              child: _buildLegend(),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'share_fab',
            onPressed: _showShareSheet,
            backgroundColor: AppColors.accent,
            child: const Icon(Icons.send, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'loc_fab',
            onPressed: () {
              _isFollowingUser = true;
              if (_liveLatLng != null && _mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(_liveLatLng!, 17),
                );
              }
              mapProv.checkCurrentRisk(
                locationProv.latitude,
                locationProv.longitude,
              );
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap(LatLng userLocation, MapProvider mapProv) {
    final circles = <Circle>{};
    if (mapProv.showHeatmap) {
      for (int i = 0; i < mapProv.riskZones.length; i++) {
        final zone = mapProv.riskZones[i];
        circles.add(
          Circle(
            circleId: CircleId('risk_$i'),
            center: LatLng(zone.latitude, zone.longitude),
            radius: 200,
            fillColor: zone.classification == 'HIGH'
                ? Colors.red.withOpacity(0.3)
                : zone.classification == 'MEDIUM'
                    ? Colors.orange.withOpacity(0.25)
                    : Colors.green.withOpacity(0.15),
            strokeColor: zone.classification == 'HIGH'
                ? Colors.red.withOpacity(0.6)
                : zone.classification == 'MEDIUM'
                    ? Colors.orange.withOpacity(0.5)
                    : Colors.green.withOpacity(0.3),
            strokeWidth: 1,
          ),
        );
      }
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: userLocation,
        zoom: 16,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(userLocation, 17),
        );
      },
      onCameraMoveStarted: () {
        _isFollowingUser = false;
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      circles: circles,
      markers: {
        Marker(
          markerId: const MarkerId('user_live'),
          position: userLocation,
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      },
    );
  }

  Widget _buildRiskCard(MapProvider mapProv) {
    final risk = mapProv.currentRisk;
    if (risk == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          RiskBadge(classification: risk.classification),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Risk Score: ${(risk.riskScore * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  risk.reason,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Risk Zones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          _legendItem(Colors.red, 'High Risk'),
          _legendItem(Colors.orange, 'Medium'),
          _legendItem(Colors.green, 'Low Risk'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
