import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Safe route recommendation screen
class SafeRouteScreen extends StatefulWidget {
  const SafeRouteScreen({super.key});

  @override
  State<SafeRouteScreen> createState() => _SafeRouteScreenState();
}

class _SafeRouteScreenState extends State<SafeRouteScreen> {
  final _destController = TextEditingController();
  bool _routeCalculated = false;

  // Mock safe route data
  final List<_RouteOption> _routes = [
    _RouteOption(
      name: 'Safest Route',
      distance: '3.2 km',
      duration: '12 min',
      riskLevel: 'LOW',
      description: 'Via Main Road → MG Road → Park Lane. Well-lit with CCTV coverage.',
      isRecommended: true,
    ),
    _RouteOption(
      name: 'Fastest Route',
      distance: '2.1 km',
      duration: '8 min',
      riskLevel: 'MEDIUM',
      description: 'Via Back Lane → Market Street. Some dark stretches after 9 PM.',
      isRecommended: false,
    ),
    _RouteOption(
      name: 'Shortest Route',
      distance: '1.8 km',
      duration: '7 min',
      riskLevel: 'HIGH',
      description: 'Via Industrial Area → Narrow Lane. Low foot traffic. Not recommended.',
      isRecommended: false,
    ),
  ];

  @override
  void dispose() {
    _destController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safe Route')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.safe,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Current Location',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 24,
                        child: VerticalDivider(
                          color: AppColors.textSecondary,
                          thickness: 1,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _destController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Enter destination...',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Find Route Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() => _routeCalculated = true);
                },
                icon: const Icon(Icons.alt_route),
                label: const Text('Find Safe Route'),
              ),
            ),
            const SizedBox(height: 24),

            // Route Options
            if (_routeCalculated) ...[
              const Text(
                'Route Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.builder(
                  itemCount: _routes.length,
                  itemBuilder: (context, index) {
                    final route = _routes[index];
                    return _buildRouteCard(route);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(_RouteOption route) {
    final riskColor = route.riskLevel == 'HIGH'
        ? AppColors.danger
        : route.riskLevel == 'MEDIUM'
            ? AppColors.warning
            : AppColors.safe;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: route.isRecommended
              ? AppColors.safe.withOpacity(0.5)
              : Colors.white.withOpacity(0.05),
          width: route.isRecommended ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    route.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  if (route.isRecommended) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.safe.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '✓ RECOMMENDED',
                        style: TextStyle(
                          color: AppColors.safe,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  route.riskLevel,
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.straighten, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Text(route.distance,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(width: 16),
              Icon(Icons.timer_outlined, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Text(route.duration,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            route.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: riskColor.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Start Navigation',
                  style: TextStyle(color: riskColor)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteOption {
  final String name;
  final String distance;
  final String duration;
  final String riskLevel;
  final String description;
  final bool isRecommended;

  _RouteOption({
    required this.name,
    required this.distance,
    required this.duration,
    required this.riskLevel,
    required this.description,
    required this.isRecommended,
  });
}
