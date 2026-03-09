import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';

/// Animated pulsing SOS button widget
class SOSButton extends StatefulWidget {
  final String emergencyNumber;
  final Future<String?> Function()? locationLinkProvider;
  final Future<void> Function()? onTrigger;

  const SOSButton({
    super.key,
    required this.emergencyNumber,
    this.locationLinkProvider,
    this.onTrigger,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnim;
  bool _isPressed = false;
  bool _isTriggering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerSos,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          final scale = _isPressed ? 0.92 : _pulseAnim.value;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(colors: [Color(0xFFFF1744), Color(0xFFD50000)]),
                boxShadow: [
                  BoxShadow(color: AppColors.danger.withOpacity(0.4 + (_pulseAnim.value - 1) * 3), blurRadius: 30 + (_pulseAnim.value - 1) * 100, spreadRadius: 5 + (_pulseAnim.value - 1) * 50),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sos, size: 48, color: Colors.white),
                  SizedBox(height: 6),
                  Text('SOS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 3)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _triggerSos() async {
    if (_isTriggering) return;

    setState(() {
      _isPressed = true;
      _isTriggering = true;
    });

    try {
      final normalizedNumber =
          widget.emergencyNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      if (normalizedNumber.isEmpty) {
        _showMessage('No emergency number found in profile');
        if (widget.onTrigger != null) {
          await widget.onTrigger!.call();
        }
        return;
      }

      final locationLink = await _getLocationLink();
      final whatsappMessage = locationLink == null
          ? 'EMERGENCY ALERT\nLive location unavailable.'
          : 'EMERGENCY ALERT\nMy live location: $locationLink';

      await _sendEmergencyWhatsApp(normalizedNumber, whatsappMessage);
      await _placeEmergencyCall(normalizedNumber);

      if (widget.onTrigger != null) {
        await widget.onTrigger!.call();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTriggering = false;
          _isPressed = false;
        });
      }
    }
  }

  Future<void> _placeEmergencyCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;

    if (Platform.isAndroid) {
      final permission = await Permission.phone.request();
      if (!permission.isGranted) {
        _showMessage('Call permission denied');
        return;
      }
      final didCall = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      if (didCall != true) {
        _showMessage('Unable to place emergency call');
      }
      return;
    }

    final callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri, mode: LaunchMode.externalApplication);
    } else {
      _showMessage('Unable to place emergency call');
    }
  }

  Future<void> _sendEmergencyWhatsApp(String phoneNumber, String message) async {
    final phoneDigits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (phoneDigits.isEmpty) {
      _showMessage('Invalid emergency number for WhatsApp');
      return;
    }

    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUri = Uri.parse(
      'whatsapp://send?phone=$phoneDigits&text=$encodedMessage',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      return;
    }

    final waWebUri = Uri.parse(
      'https://wa.me/$phoneDigits?text=$encodedMessage',
    );
    if (await canLaunchUrl(waWebUri)) {
      await launchUrl(waWebUri, mode: LaunchMode.externalApplication);
    } else {
      _showMessage('WhatsApp not available');
    }
  }

  Future<String?> _getLocationLink() async {
    if (widget.locationLinkProvider == null) return null;
    final link = await widget.locationLinkProvider!.call();
    if (link == null || link.trim().isEmpty) return null;
    return link.trim();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
