import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/emergency_call_button.dart';

/// Replaces the old fake call feature with direct emergency calling.
class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  static const String _policeNumber = '112';
  bool _sendSmsToTrustedContact = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final trustedContact = user?.emergencyContacts.isNotEmpty == true
        ? user!.emergencyContacts.first.phone
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Call')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade700.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.shade400.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Use only in real emergencies. This button can place a direct police call.',
                      style: TextStyle(color: Colors.white.withOpacity(0.85)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              value: _sendSmsToTrustedContact,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Also notify trusted contact via SMS',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                trustedContact ?? 'No trusted contact found',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              onChanged: trustedContact == null
                  ? null
                  : (value) => setState(() => _sendSmsToTrustedContact = value),
            ),
            const SizedBox(height: 18),
            EmergencyCallButton(
              policeNumber: _policeNumber,
              trustedContactNumber: trustedContact,
              sendSmsToTrustedContact: _sendSmsToTrustedContact,
              smsMessage:
                  'Emergency alert: I am contacting the police right now. Please reach me as soon as possible.',
            ),
            const SizedBox(height: 16),
            Text(
              'Police Number: $_policeNumber',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
