import 'package:flutter/material.dart';

class AppConstants {
  // API Endpoints
  static const String baseApiUrl = 'http://localhost:5000/api';
  static const String aiApiUrl = 'http://localhost:5001';
  static const String wsUrl = 'ws://localhost:5000/ws/location';

  // Google Maps
  static const String googleMapsApiKey = 'AIzaSyCLPSjIBbjGHmAYJc5Kjd9JC9I9vVfsTEo';
  static const double defaultLat = 28.6139; // New Delhi
  static const double defaultLng = 77.2090;
  static const double defaultZoom = 14.0;

  // Twilio SMS
  static const String twilioAccountSid = 'ACb7ca1557703145732b758686b8ddae10';
  static const String twilioAuthToken = '9c52edae2cc1b7fe53ffcf98c25aacf7';
  static const String twilioFromNumber = '+1234567890';

  // SOS
  static const int sosCountdownSeconds = 5;
  static const String sosVoiceTrigger = 'help me';

  // Risk Levels
  static const String riskLow = 'LOW';
  static const String riskMedium = 'MEDIUM';
  static const String riskHigh = 'HIGH';
}

class AppColors {
  static const Color primary = Color(0xFFE53935);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color accent = Color(0xFFFF6F00);
  static const Color safe = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA000);
  static const Color danger = Color(0xFFE53935);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E2E);
  static const Color surfaceLight = Color(0xFF2A2A3E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color cardBg = Color(0xFF252540);
  static const Color shimmer = Color(0xFF3A3A5C);
  static const Color gradientStart = Color(0xFFE53935);
  static const Color gradientEnd = Color(0xFFFF6F00);
}
