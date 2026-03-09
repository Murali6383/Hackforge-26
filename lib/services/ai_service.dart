import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/zone_risk.dart';

/// AI service for unsafe zone prediction via REST API
/// Falls back to mock data when AI backend is unavailable
class AiService {
  /// Predict risk for a given location
  Future<ZoneRisk> predictRisk(double latitude, double longitude) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.aiApiUrl}/predict_risk'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return ZoneRisk.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('AI API unavailable, using mock data: $e');
    }

    // Return mock data when API is unavailable
    return _getMockRisk(latitude, longitude);
  }

  /// Get heatmap data for surrounding area
  Future<List<ZoneRisk>> getHeatmapData(
      double latitude, double longitude, double radiusKm) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.aiApiUrl}/heatmap'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'radius_km': radiusKm,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => ZoneRisk.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Heatmap API unavailable, using mock data: $e');
    }

    return _getMockHeatmapData(latitude, longitude);
  }

  /// Mock risk based on location hash for consistent demo results
  ZoneRisk _getMockRisk(double lat, double lng) {
    // Create deterministic but varied risk scores
    final hash = ((lat * 1000).toInt() + (lng * 1000).toInt()) % 100;
    double score;
    String classification;

    if (hash < 40) {
      score = 0.1 + (hash / 100);
      classification = AppConstants.riskLow;
    } else if (hash < 75) {
      score = 0.4 + (hash / 200);
      classification = AppConstants.riskMedium;
    } else {
      score = 0.7 + (hash / 400);
      classification = AppConstants.riskHigh;
    }

    return ZoneRisk(
      latitude: lat,
      longitude: lng,
      riskScore: score.clamp(0.0, 1.0),
      classification: classification,
      reason: _getReasonForRisk(classification),
      incidentCount: (hash * 0.3).toInt(),
    );
  }

  List<ZoneRisk> _getMockHeatmapData(double centerLat, double centerLng) {
    final List<ZoneRisk> zones = [];
    // Generate a grid of risk zones around the center
    for (double dLat = -0.02; dLat <= 0.02; dLat += 0.005) {
      for (double dLng = -0.02; dLng <= 0.02; dLng += 0.005) {
        zones.add(_getMockRisk(centerLat + dLat, centerLng + dLng));
      }
    }
    return zones;
  }

  String _getReasonForRisk(String classification) {
    switch (classification) {
      case 'HIGH':
        return 'Multiple incidents reported. Poor lighting. Low foot traffic after dark.';
      case 'MEDIUM':
        return 'Occasional incidents. Moderate foot traffic. Some surveillance gaps.';
      default:
        return 'Well-lit area. Good surveillance coverage. Active patrol route.';
    }
  }
}
