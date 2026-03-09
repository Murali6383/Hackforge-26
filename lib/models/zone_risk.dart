/// AI risk prediction result for a zone
class ZoneRisk {
  final double latitude;
  final double longitude;
  final double riskScore; // 0.0 - 1.0
  final String classification; // 'LOW', 'MEDIUM', 'HIGH'
  final String reason;
  final int incidentCount;
  final DateTime lastUpdated;

  ZoneRisk({
    required this.latitude,
    required this.longitude,
    required this.riskScore,
    required this.classification,
    this.reason = '',
    this.incidentCount = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'riskScore': riskScore,
        'classification': classification,
        'reason': reason,
        'incidentCount': incidentCount,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory ZoneRisk.fromJson(Map<String, dynamic> json) => ZoneRisk(
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        longitude: (json['longitude'] ?? 0.0).toDouble(),
        riskScore: (json['riskScore'] ?? json['risk_score'] ?? 0.0).toDouble(),
        classification:
            json['classification'] ?? json['risk_level'] ?? 'LOW',
        reason: json['reason'] ?? '',
        incidentCount: json['incidentCount'] ?? json['incident_count'] ?? 0,
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.parse(json['lastUpdated'])
            : DateTime.now(),
      );
}
