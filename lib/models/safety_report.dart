/// Community safety report submitted by users
class SafetyReport {
  final String id;
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;
  final String address;
  final String description;
  final String category; // 'harassment', 'theft', 'assault', 'suspicious', 'other'
  final String severity; // 'low', 'medium', 'high'
  final DateTime timestamp;
  final bool isAnonymous;
  final int upvotes;

  SafetyReport({
    required this.id,
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    this.address = '',
    required this.description,
    this.category = 'other',
    this.severity = 'medium',
    DateTime? timestamp,
    this.isAnonymous = false,
    this.upvotes = 0,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'description': description,
        'category': category,
        'severity': severity,
        'timestamp': timestamp.toIso8601String(),
        'isAnonymous': isAnonymous,
        'upvotes': upvotes,
      };

  factory SafetyReport.fromJson(Map<String, dynamic> json) => SafetyReport(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        userName: json['userName'] ?? '',
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        longitude: (json['longitude'] ?? 0.0).toDouble(),
        address: json['address'] ?? '',
        description: json['description'] ?? '',
        category: json['category'] ?? 'other',
        severity: json['severity'] ?? 'medium',
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
        isAnonymous: json['isAnonymous'] ?? false,
        upvotes: json['upvotes'] ?? 0,
      );
}
