import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../models/safety_report.dart';

/// Safety report card for the reports list
class ReportCard extends StatelessWidget {
  final SafetyReport report;
  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final severityColor = report.severity == 'high' ? AppColors.danger : report.severity == 'medium' ? AppColors.warning : AppColors.safe;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: severityColor.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.person, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 6),
                Text(report.isAnonymous ? 'Anonymous' : report.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: severityColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Text(report.severity.toUpperCase(), style: TextStyle(color: severityColor, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(report.description, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Expanded(child: Text(report.address.isNotEmpty ? report.address : '${report.latitude.toStringAsFixed(4)}, ${report.longitude.toStringAsFixed(4)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11))),
              const SizedBox(width: 8),
              Icon(Icons.thumb_up_outlined, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Text('${report.upvotes}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(width: 12),
              Text(DateFormat('MMM d, h:mm a').format(report.timestamp), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
