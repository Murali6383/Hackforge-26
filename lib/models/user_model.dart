/// User model with role-based access: user, volunteer, authority
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'user', 'volunteer', 'authority'
  final List<EmergencyContact> emergencyContacts;
  final double? latitude;
  final double? longitude;
  final bool isAvailable; // for volunteers
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'user',
    this.emergencyContacts = const [],
    this.latitude,
    this.longitude,
    this.isAvailable = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'emergencyContacts': emergencyContacts.map((e) => e.toJson()).toList(),
        'latitude': latitude,
        'longitude': longitude,
        'isAvailable': isAvailable,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        role: json['role'] ?? 'user',
        emergencyContacts: (json['emergencyContacts'] as List<dynamic>?)
                ?.map((e) => EmergencyContact.fromJson(e))
                .toList() ??
            [],
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        isAvailable: json['isAvailable'] ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relation;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relation,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'relation': relation,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        relation: json['relation'] ?? '',
      );
}
