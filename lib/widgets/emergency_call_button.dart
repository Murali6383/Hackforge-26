import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Emergency action button that directly calls police and can optionally
/// open an SMS composer for a trusted contact.
class EmergencyCallButton extends StatefulWidget {
  const EmergencyCallButton({
    super.key,
    required this.policeNumber,
    this.trustedContactNumber,
    this.sendSmsToTrustedContact = false,
    this.smsMessage =
        'Emergency: I have called the police. Please check on me immediately.',
  });

  final String policeNumber;
  final String? trustedContactNumber;
  final bool sendSmsToTrustedContact;
  final String smsMessage;

  @override
  State<EmergencyCallButton> createState() => _EmergencyCallButtonState();
}

class _EmergencyCallButtonState extends State<EmergencyCallButton> {
  bool _isProcessing = false;

  Future<void> _handleEmergencyCall() async {
    if (_isProcessing) return;

    final confirmed = await _confirmEmergencyAction();
    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final hasPermission = await _ensureCallPermission();
      if (!hasPermission) {
        _showMessage('Call permission denied');
        return;
      }

      final didCall = await _placePoliceCall(widget.policeNumber);
      if (!didCall) {
        _showMessage('Unable to place call');
        return;
      }

      _showMessage('Calling police...');

      if (widget.sendSmsToTrustedContact &&
          widget.trustedContactNumber != null &&
          widget.trustedContactNumber!.trim().isNotEmpty) {
        await _openSmsComposer(
          phone: widget.trustedContactNumber!,
          message: widget.smsMessage,
        );
      }
    } catch (e) {
      _showMessage('Emergency action failed: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<bool> _ensureCallPermission() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.phone.request();
    return status.isGranted;
  }

  Future<bool> _placePoliceCall(String phone) async {
    final normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (normalized.isEmpty) return false;

    if (Platform.isAndroid) {
      // Android: direct call without opening the dialer.
      return await FlutterPhoneDirectCaller.callNumber(normalized) ?? false;
    }

    // iOS fallback: open phone app with tel: URI.
    final telUri = Uri(scheme: 'tel', path: normalized);
    if (!await canLaunchUrl(telUri)) return false;
    return launchUrl(telUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openSmsComposer({
    required String phone,
    required String message,
  }) async {
    final normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (normalized.isEmpty) return;

    final smsUri = Uri(
      scheme: 'sms',
      path: normalized,
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
    } else {
      _showMessage('Could not open SMS app');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirmEmergencyAction() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Emergency Call'),
          content: const Text(
            'This will directly call police services. Continue only for a real emergency.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Call Police'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _handleEmergencyCall,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.local_police_outlined),
        label: Text(
          _isProcessing ? 'Processing...' : 'Call Police',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
