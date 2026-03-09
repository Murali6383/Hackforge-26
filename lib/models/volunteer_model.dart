/// Volunteer in the emergency network
class VolunteerModel {
  final String id;
  final String name;
  final String phone;
  final double latitude;
  final double longitude;
  final double distance; // in km from user
  final bool isAvailable;
  final String status; // 'idle', 'responding', 'busy'
  final int emergenciesHandled;
  final double rating;

  VolunteerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.latitude,
    required this.longitude,
    this.distance = 0.0,
    this.isAvailable = true,
    this.status = 'idle',
    this.emergenciesHandled = 0,
    this.rating = 5.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'latitude': latitude,
        'longitude': longitude,
        'distance': distance,
        'isAvailable': isAvailable,
        'status': status,
        'emergenciesHandled': emergenciesHandled,
        'rating': rating,
      };

  factory VolunteerModel.fromJson(Map<String, dynamic> json) =>
      VolunteerModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        longitude: (json['longitude'] ?? 0.0).toDouble(),
        distance: (json['distance'] ?? 0.0).toDouble(),
        isAvailable: json['isAvailable'] ?? true,
        status: json['status'] ?? 'idle',
        emergenciesHandled: json['emergenciesHandled'] ?? 0,
        rating: (json['rating'] ?? 5.0).toDouble(),
      );
}
