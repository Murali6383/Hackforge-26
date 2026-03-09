import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import '../core/constants.dart';
import '../core/app_router.dart';
import '../providers/auth_provider.dart';
import '../providers/emergency_provider.dart';

/// Animated splash screen with SafeSphere branding
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final QuickActions _quickActions = const QuickActions();
  bool _safeTouchTriggered = false;
  bool _safeTouchHandled = false;

  @override
  void initState() {
    super.initState();
    _initializeSafeTouchShortcut();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Navigate after splash
    Timer(const Duration(seconds: 3), () {
      _navigateNext();
    });
  }

  void _initializeSafeTouchShortcut() {
    _quickActions.initialize((shortcutType) {
      if (shortcutType == 'safe_touch') {
        _safeTouchTriggered = true;
      }
    });

    unawaited(_quickActions.setShortcutItems(const <ShortcutItem>[
      ShortcutItem(
        type: 'safe_touch',
        localizedTitle: 'Safe Touch',
        icon: 'ic_launcher',
      ),
    ]));
  }

  Future<void> _navigateNext() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.init();

    if (!mounted) return;

    if (authProvider.isLoggedIn) {
      if (_safeTouchTriggered) {
        await _triggerSafeTouchSos(authProvider);
        return;
      }
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.login);
    }
  }

  Future<void> _triggerSafeTouchSos(AuthProvider authProvider) async {
    if (_safeTouchHandled) return;
    _safeTouchHandled = true;

    final user = authProvider.user;
    if (user == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.login);
      return;
    }

    final emergency = context.read<EmergencyProvider>();
    await emergency.triggerSOS(
      userId: user.id,
      userName: user.name,
      type: 'safe_touch',
      emergencyPhones: user.emergencyContacts.map((e) => e.phone).toList(),
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.sosActive);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Shield Icon
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.gradientStart, AppColors.gradientEnd],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // App Name
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'SafeSphere',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'AI Powered Emergency & Safety',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
