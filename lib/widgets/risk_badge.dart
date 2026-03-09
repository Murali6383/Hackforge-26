import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Risk level badge widget (LOW / MEDIUM / HIGH)
class RiskBadge extends StatelessWidget {
  final String classification;
  const RiskBadge({super.key, required this.classification});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (classification) {
      case 'HIGH':
        color = AppColors.danger;
        icon = Icons.warning_amber_rounded;
        break;
      case 'MEDIUM':
        color = AppColors.warning;
        icon = Icons.info_outline;
        break;
      default:
        color = AppColors.safe;
        icon = Icons.check_circle_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.5))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(classification, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
