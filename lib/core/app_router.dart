import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/map_screen.dart';
import '../screens/sos_active_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/safe_route_screen.dart';
import '../screens/volunteer_screen.dart';
import '../screens/authority_dashboard_screen.dart';
import '../screens/fake_call_screen.dart';
import '../screens/profile_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String map = '/map';
  static const String sosActive = '/sos-active';
  static const String reports = '/reports';
  static const String safeRoute = '/safe-route';
  static const String volunteers = '/volunteers';
  static const String authorityDashboard = '/authority-dashboard';
  static const String fakeCall = '/fake-call';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen());
      case login:
        return _buildRoute(const LoginScreen());
      case register:
        return _buildRoute(const RegisterScreen());
      case dashboard:
        return _buildRoute(const DashboardScreen());
      case map:
        return _buildRoute(const MapScreen());
      case sosActive:
        return _buildRoute(const SosActiveScreen());
      case reports:
        return _buildRoute(const ReportsScreen());
      case safeRoute:
        return _buildRoute(const SafeRouteScreen());
      case volunteers:
        return _buildRoute(const VolunteerScreen());
      case authorityDashboard:
        return _buildRoute(const AuthorityDashboardScreen());
      case fakeCall:
        return _buildRoute(const FakeCallScreen());
      case profile:
        return _buildRoute(const ProfileScreen());
      default:
        return _buildRoute(const SplashScreen());
    }
  }

  static MaterialPageRoute _buildRoute(Widget screen) {
    return MaterialPageRoute(builder: (_) => screen);
  }
}
