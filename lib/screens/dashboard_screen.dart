import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import '../core/app_router.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/emergency_provider.dart';
import '../providers/location_provider.dart';
import '../providers/map_provider.dart';
import '../providers/voice_sos_settings_provider.dart';
import '../services/voice_alert_service.dart';
import '../widgets/sos_button.dart';
import '../widgets/stat_card.dart';

/// Main dashboard with SOS button, quick actions, and status overview
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const String _fallbackEmergencyNumber = '112';
  final loc.Location _location = loc.Location();
  final VoiceAlertService _voiceAlertService = VoiceAlertService();
  int _currentIndex = 0;
  bool _isSosTriggering = false;
  bool? _appliedVoiceSosEnabled;

  @override
  void initState() {
    super.initState();
    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().init();
      context.read<MapProvider>().loadHeatmapData(
            AppConstants.defaultLat,
            AppConstants.defaultLng,
          );
      final enabled = context.read<VoiceSosSettingsProvider>().isEnabled;
      unawaited(_applyVoiceSosSetting(enabled));
    });
  }

  @override
  void dispose() {
    unawaited(_voiceAlertService.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final emergency = context.watch<EmergencyProvider>();
    final voiceSosEnabled = context.watch<VoiceSosSettingsProvider>().isEnabled;

    if (_appliedVoiceSosEnabled != voiceSosEnabled) {
      _appliedVoiceSosEnabled = voiceSosEnabled;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_applyVoiceSosSetting(voiceSosEnabled));
        }
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${user?.name.split(' ').first ?? 'User'} 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.safe,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              emergency.isEmergencyActive
                                  ? 'EMERGENCY ACTIVE'
                                  : 'You are safe',
                              style: TextStyle(
                                color: emergency.isEmergencyActive
                                    ? AppColors.danger
                                    : AppColors.safe,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.profile),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.8),
                              AppColors.accent.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // SOS Button
                Center(
                  child: SOSButton(
                    emergencyNumber: user == null
                        ? _fallbackEmergencyNumber
                        : _resolveEmergencyNumber(user),
                    locationLinkProvider: _buildLiveLocationLink,
                    onTrigger: _handleSosTrigger,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Tap for emergency',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Risk Status Card
                Consumer<MapProvider>(
                  builder: (context, mapProv, _) {
                    final risk = mapProv.currentRisk;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: risk?.classification == 'HIGH'
                              ? [const Color(0xFF8B0000), const Color(0xFFC62828)]
                              : risk?.classification == 'MEDIUM'
                                  ? [const Color(0xFFE65100), const Color(0xFFF57C00)]
                                  : [const Color(0xFF1B5E20), const Color(0xFF388E3C)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            risk?.classification == 'HIGH'
                                ? Icons.warning_amber_rounded
                                : risk?.classification == 'MEDIUM'
                                    ? Icons.info_outline
                                    : Icons.verified_user,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Area Risk: ${risk?.classification ?? 'Analyzing...'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  risk?.reason ?? 'Checking your area safety...',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Quick Actions Grid
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildQuickAction(
                      icon: Icons.map_outlined,
                      label: 'Safety Map',
                      color: const Color(0xFF1565C0),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.map),
                    ),
                    _buildQuickAction(
                      icon: Icons.local_police_outlined,
                      label: 'Call Police',
                      color: const Color(0xFFC62828),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.fakeCall),
                    ),
                    _buildQuickAction(
                      icon: Icons.report_outlined,
                      label: 'Reports',
                      color: const Color(0xFFE65100),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.reports),
                    ),
                    _buildQuickAction(
                      icon: Icons.group_outlined,
                      label: 'Volunteers',
                      color: const Color(0xFF2E7D32),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.volunteers),
                    ),
                    _buildQuickAction(
                      icon: Icons.alt_route,
                      label: 'Safe Route',
                      color: const Color(0xFF00838F),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.safeRoute),
                    ),
                    _buildQuickAction(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Authority',
                      color: const Color(0xFF4E342E),
                      onTap: () => Navigator.pushNamed(
                          context, AppRouter.authorityDashboard),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats Row
                const Text(
                  'Your Safety Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.shield,
                        label: 'Safe Days',
                        value: '28',
                        color: AppColors.safe,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.warning_amber,
                        label: 'Alerts Sent',
                        value: '${emergency.events.length}',
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.people,
                        label: 'Contacts',
                        value: '${user?.emergencyContacts.length ?? 0}',
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, AppRouter.map);
              break;
            case 2:
              Navigator.pushNamed(context, AppRouter.reports);
              break;
            case 3:
              Navigator.pushNamed(context, AppRouter.profile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_outlined),
            activeIcon: Icon(Icons.report),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _handleSosTrigger() async {
    if (_isSosTriggering) return;
    _isSosTriggering = true;

    final authProvider = context.read<AuthProvider>();
    final emergencyProvider = context.read<EmergencyProvider>();
    final user = authProvider.user;
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (user == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('User not found. Please login again.')),
        );
        return;
      }

      // 1) Immediately fetch live location with proper permissions.
      final locationData = await _getLiveLocation();
      if (locationData == null) {
        return;
      }

      final lat = locationData.latitude;
      final lng = locationData.longitude;
      if (lat == null || lng == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Unable to get live location')),
        );
        return;
      }

      // 2) Keep existing app emergency flow after external actions.
      await emergencyProvider.triggerSOS(
        userId: user.id,
        userName: user.name,
        emergencyPhones: user.emergencyContacts.map((e) => e.phone).toList(),
      );

      if (!mounted) return;
      Navigator.pushNamed(context, AppRouter.sosActive);
    } finally {
      _isSosTriggering = false;
    }
  }

  Future<void> _startVoiceSosListener() async {
    try {
      await _voiceAlertService.startContinuousListening(
        onCommandDetected: (command) async {
          debugPrint('Voice SOS command detected: $command');
          final user = context.read<AuthProvider>().user;
          if (user != null) {
            final emergencyNumber = _resolveEmergencyNumber(user);
            final didCall = await _placeEmergencyCall(emergencyNumber);
            if (!didCall && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unable to place emergency call')),
              );
            }
          }
          await _handleSosTrigger();
        },
        triggerPhrases: const ['help', 'emergency'],
      );
    } catch (e) {
      debugPrint('Voice SOS startup failed: $e');
    }
  }

  Future<void> _applyVoiceSosSetting(bool enabled) async {
    if (enabled) {
      await _startVoiceSosListener();
    } else {
      await _voiceAlertService.stopListening();
    }
  }

  Future<loc.LocationData?> _getLiveLocation() async {
    final messenger = ScaffoldMessenger.of(context);

    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Location service is disabled')),
        );
        return null;
      }
    }

    loc.PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == loc.PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
    }

    if (permissionStatus == loc.PermissionStatus.denied ||
        permissionStatus == loc.PermissionStatus.deniedForever) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
      return null;
    }

    return _location.getLocation();
  }

  Future<String?> _buildLiveLocationLink() async {
    final locationData = await _getLiveLocation();
    if (locationData == null) return null;
    final lat = locationData.latitude;
    final lng = locationData.longitude;
    if (lat == null || lng == null) return null;
    return 'https://www.google.com/maps?q=$lat,$lng';
  }

  Future<bool> _placeEmergencyCall(String phoneNumber) async {
    final normalized = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (normalized.isEmpty) return false;

    if (Platform.isAndroid) {
      final permission = await Permission.phone.request();
      if (!permission.isGranted) {
        return false;
      }
      return await FlutterPhoneDirectCaller.callNumber(normalized) ?? false;
    }

    final callUri = Uri(scheme: 'tel', path: normalized);
    if (!await canLaunchUrl(callUri)) {
      return false;
    }
    return launchUrl(callUri, mode: LaunchMode.externalApplication);
  }

  String _resolveEmergencyNumber(UserModel user) {
    final trustedPhone = user.emergencyContacts.isNotEmpty
        ? user.emergencyContacts.first.phone.trim()
        : '';
    if (trustedPhone.isNotEmpty) return trustedPhone;

    final profilePhone = user.phone.trim();
    if (profilePhone.isNotEmpty) return profilePhone;

    return _fallbackEmergencyNumber;
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

