import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

/// Authentication service with mock data support
class AuthService {
  static const String _userKey = 'current_user';
  static const String _usersKey = 'registered_users';

  /// Register a new user (mock - stores locally)
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    List<EmergencyContact> emergencyContacts = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _getStoredUsers(prefs);

    // Check if email already exists
    if (users.any((u) => u['email'] == email)) {
      throw Exception('Email already registered');
    }

    final user = UserModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
      emergencyContacts: emergencyContacts,
    );

    users.add(user.toJson());
    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    return user;
  }

  /// Login with email/password (mock)
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _getStoredUsers(prefs);

    final userJson = users.firstWhere(
      (u) => u['email'] == email,
      orElse: () => throw Exception('User not found'),
    );

    final user = UserModel.fromJson(userJson);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    return user;
  }

  /// Get currently logged in user
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userStr));
    } catch (e) {
      debugPrint('Error parsing user: $e');
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  /// Seed demo users for hackathon
  Future<void> seedDemoData() async {
    final prefs = await SharedPreferences.getInstance();
    final users = _getStoredUsers(prefs);
    if (users.isNotEmpty) return;

    final demoUsers = [
      UserModel(
        id: 'demo-user-1',
        name: 'Priya Sharma',
        email: 'priya@demo.com',
        phone: '+919876543210',
        emergencyContacts: [
          EmergencyContact(name: 'Mom', phone: '+919876543211', relation: 'Mother'),
          EmergencyContact(name: 'Dad', phone: '+919876543212', relation: 'Father'),
        ],
      ),
      UserModel(
        id: 'demo-volunteer-1',
        name: 'Rahul Verma',
        email: 'rahul@demo.com',
        phone: '+919876543220',
        role: 'volunteer',
        latitude: 28.6149,
        longitude: 77.2090,
      ),
      UserModel(
        id: 'demo-authority-1',
        name: 'Inspector Singh',
        email: 'authority@demo.com',
        phone: '+919876543230',
        role: 'authority',
      ),
    ];

    final usersList = demoUsers.map((u) => u.toJson()).toList();
    await prefs.setString(_usersKey, jsonEncode(usersList));
  }

  List<Map<String, dynamic>> _getStoredUsers(SharedPreferences prefs) {
    final usersStr = prefs.getString(_usersKey);
    if (usersStr == null) return [];
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(usersStr));
    } catch (e) {
      return [];
    }
  }
}
