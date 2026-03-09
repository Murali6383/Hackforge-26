import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/safety_report.dart';
import 'database_service.dart';

/// Service for community safety reports
class ReportService {
  final DatabaseService _databaseService;

  // Mock reports for demo
  final List<SafetyReport> _mockReports = [
    SafetyReport(
      id: 'report-1',
      userId: 'demo-user-1',
      userName: 'Anonymous',
      latitude: 28.6129,
      longitude: 77.2295,
      address: 'Connaught Place, New Delhi',
      description: 'Poor street lighting near the market area. Felt unsafe walking alone after 9 PM.',
      category: 'suspicious',
      severity: 'high',
      isAnonymous: true,
      upvotes: 15,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    SafetyReport(
      id: 'report-2',
      userId: 'demo-user-2',
      userName: 'Meera K.',
      latitude: 28.6304,
      longitude: 77.2177,
      address: 'Karol Bagh Metro Station',
      description: 'Group of people loitering near the metro exit after dark. Multiple women reported being followed.',
      category: 'harassment',
      severity: 'high',
      upvotes: 23,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    SafetyReport(
      id: 'report-3',
      userId: 'demo-user-3',
      userName: 'Anonymous',
      latitude: 28.5672,
      longitude: 77.2100,
      address: 'Hauz Khas Village',
      description: 'Well-lit area with CCTV. Feels safe even at night. Good police presence.',
      category: 'other',
      severity: 'low',
      isAnonymous: true,
      upvotes: 8,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SafetyReport(
      id: 'report-4',
      userId: 'demo-user-4',
      userName: 'Anita S.',
      latitude: 28.6508,
      longitude: 77.2340,
      address: 'Old Delhi Railway Station',
      description: 'Petty theft reported multiple times. Keep belongings close.',
      category: 'theft',
      severity: 'medium',
      upvotes: 12,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  ReportService({required DatabaseService databaseService})
      : _databaseService = databaseService;

  /// Get all reports (mock + local DB)
  Future<List<SafetyReport>> getReports() async {
    try {
      final localReports = await _databaseService.getReports();
      return [...localReports, ..._mockReports];
    } catch (e) {
      debugPrint('Error fetching reports: $e');
      return _mockReports;
    }
  }

  /// Submit a new safety report
  Future<SafetyReport> submitReport({
    required String userId,
    required String userName,
    required double latitude,
    required double longitude,
    required String description,
    String category = 'other',
    String severity = 'medium',
    bool isAnonymous = false,
    String address = '',
  }) async {
    final report = SafetyReport(
      id: const Uuid().v4(),
      userId: userId,
      userName: isAnonymous ? 'Anonymous' : userName,
      latitude: latitude,
      longitude: longitude,
      address: address,
      description: description,
      category: category,
      severity: severity,
      isAnonymous: isAnonymous,
    );

    await _databaseService.insertReport(report);
    return report;
  }
}
