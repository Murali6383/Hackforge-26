import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/volunteer_model.dart';

/// Volunteer info card for the volunteer network list
class VolunteerCard extends StatelessWidget {
  final VolunteerModel volunteer;
  const VolunteerCard({super.key, required this.volunteer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(shape: BoxShape.circle, color: volunteer.isAvailable ? AppColors.safe.withOpacity(0.2) : AppColors.textSecondary.withOpacity(0.2)),
            child: Center(child: Text(volunteer.name[0], style: TextStyle(color: volunteer.isAvailable ? AppColors.safe : AppColors.textSecondary, fontSize: 20, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(volunteer.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                  Text(' ${volunteer.distance.toStringAsFixed(1)} km', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  const SizedBox(width: 10),
                  Icon(Icons.star, size: 12, color: AppColors.warning),
                  Text(' ${volunteer.rating}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  const SizedBox(width: 10),
                  Text('${volunteer.emergenciesHandled} helped', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ]),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: (volunteer.isAvailable ? AppColors.safe : AppColors.warning).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(volunteer.isAvailable ? 'Available' : 'Busy', style: TextStyle(color: volunteer.isAvailable ? AppColors.safe : AppColors.warning, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
