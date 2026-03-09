import 'package:flutter/material.dart';
import '../models/zone_risk.dart';
import '../services/ai_service.dart';

/// Map state provider for risk zones and heatmap data
class MapProvider extends ChangeNotifier {
  final AiService _aiService = AiService();

  List<ZoneRisk> _riskZones = [];
  ZoneRisk? _currentRisk;
  bool _isLoadingHeatmap = false;
  bool _showHeatmap = true;

  List<ZoneRisk> get riskZones => _riskZones;
  ZoneRisk? get currentRisk => _currentRisk;
  bool get isLoadingHeatmap => _isLoadingHeatmap;
  bool get showHeatmap => _showHeatmap;

  /// Load heatmap data for area
  Future<void> loadHeatmapData(double lat, double lng, {double radiusKm = 2.0}) async {
    _isLoadingHeatmap = true;
    notifyListeners();

    try {
      _riskZones = await _aiService.getHeatmapData(lat, lng, radiusKm);
    } catch (e) {
      debugPrint('Error loading heatmap: $e');
    }

    _isLoadingHeatmap = false;
    notifyListeners();
  }

  /// Get risk for current location
  Future<void> checkCurrentRisk(double lat, double lng) async {
    try {
      _currentRisk = await _aiService.predictRisk(lat, lng);
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking risk: $e');
    }
  }

  /// Toggle heatmap visibility
  void toggleHeatmap() {
    _showHeatmap = !_showHeatmap;
    notifyListeners();
  }
}
