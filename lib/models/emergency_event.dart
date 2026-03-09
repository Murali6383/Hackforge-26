/// Emergency SOS event with location, timestamp, and status tracking
class EmergencyEvent {
  final String id;
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;
  final String address;
  final String status; // 'active', 'responded', 'resolved', 'cancelled'
  final String type; // 'sos_button', 'voice', 'safe_touch', 'auto'
  final DateTime timestamp;
  final List<LocationPoint> trackingPath;
  final String? responderId;
  final String? responderName;
  final String? notes;

  EmergencyEvent({
    required this.id,
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    this.address = '',
    this.status = 'active',
    this.type = 'sos_button',
    DateTime? timestamp,
    this.trackingPath = const [],
    this.responderId,
    this.responderName,
    this.notes,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'status': status,
        'type': type,
        'timestamp': timestamp.toIso8601String(),
        'trackingPath': trackingPath.map((e) => e.toJson()).toList(),
        'responderId': responderId,
        'responderName': responderName,
        'notes': notes,
      };

  factory EmergencyEvent.fromJson(Map<String, dynamic> json) =>
      EmergencyEvent(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        userName: json['userName'] ?? '',
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        longitude: (json['longitude'] ?? 0.0).toDouble(),
        address: json['address'] ?? '',
        status: json['status'] ?? 'active',
        type: json['type'] ?? 'sos_button',
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
        trackingPath: (json['trackingPath'] as List<dynamic>?)
                ?.map((e) => LocationPoint.fromJson(e))
                .toList() ??
            [],
        responderId: json['responderId'],
        responderName: json['responderName'],
        notes: json['notes'],
      );

  EmergencyEvent copyWith({
    String? status,
    String? responderId,
    String? responderName,
    List<LocationPoint>? trackingPath,
    String? notes,
  }) {
    return EmergencyEvent(
      id: id,
      userId: userId,
      userName: userName,
      latitude: latitude,
      longitude: longitude,
      address: address,
      status: status ?? this.status,
      type: type,
      timestamp: timestamp,
      trackingPath: trackingPath ?? this.trackingPath,
      responderId: responderId ?? this.responderId,
      responderName: responderName ?? this.responderName,
      notes: notes ?? this.notes,
    );
  }
}

class LocationPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LocationPoint.fromJson(Map<String, dynamic> json) => LocationPoint(
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        longitude: (json['longitude'] ?? 0.0).toDouble(),
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
      );
}
