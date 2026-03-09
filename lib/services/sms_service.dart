import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// SMS service for sending emergency alerts
/// Uses URL launcher for demo, with Twilio integration scaffold
class SmsService {
  /// Send emergency SMS via URL launcher (opens SMS app)
  Future<void> sendEmergencySMS({
    required String to,
    required String message,
  }) async {
    try {
      final uri = Uri(
        scheme: 'sms',
        path: to,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        debugPrint('SMS: Would send to $to: $message');
      }
    } catch (e) {
      debugPrint('SMS send failed (demo mode): $e');
      // In demo mode, just log
      debugPrint('SMS: [$to] $message');
    }
  }

  /// Make emergency call
  Future<void> makeEmergencyCall(String number) async {
    try {
      final uri = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Call failed: $e');
    }
  }

  // ─── Twilio Integration (Scaffold) ─────────────────────────────
  // To use Twilio, uncomment and configure:
  //
  // Future<void> sendViaTwilio({
  //   required String to,
  //   required String message,
  // }) async {
  //   final response = await http.post(
  //     Uri.parse('https://api.twilio.com/2010-04-01/Accounts/${AppConstants.twilioAccountSid}/Messages.json'),
  //     headers: {
  //       'Authorization': 'Basic ' + base64Encode(
  //         utf8.encode('${AppConstants.twilioAccountSid}:${AppConstants.twilioAuthToken}'),
  //       ),
  //     },
  //     body: {
  //       'From': AppConstants.twilioFromNumber,
  //       'To': to,
  //       'Body': message,
  //     },
  //   );
  //   debugPrint('Twilio response: ${response.statusCode}');
  // }
}
