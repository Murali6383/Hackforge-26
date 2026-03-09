import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Authority dashboard for monitoring SOS alerts and analytics
class AuthorityDashboardScreen extends StatelessWidget {
  const AuthorityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authority Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Overview
            Row(
              children: [
                _statTile('Active SOS', '3', AppColors.danger, Icons.sos),
                const SizedBox(width: 12),
                _statTile('Resolved', '47', AppColors.safe, Icons.check_circle),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statTile('Volunteers', '12', AppColors.accent, Icons.group),
                const SizedBox(width: 12),
                _statTile('Reports', '156', Color(0xFF1565C0), Icons.report),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Recent SOS Alerts', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _alertCard('Priya Sharma', '2 min ago', 'active', 'Connaught Place'),
            _alertCard('Ananya Singh', '15 min ago', 'responded', 'Karol Bagh'),
            _alertCard('Meera K.', '1 hour ago', 'resolved', 'Saket Mall'),
            _alertCard('Ritu Jain', '3 hours ago', 'resolved', 'Lajpat Nagar'),
            const SizedBox(height: 24),
            const Text('AI Risk Insights', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _insightRow('High Risk Zones', '8 areas identified'),
                  const Divider(color: Colors.white12, height: 20),
                  _insightRow('Incidents Today', '4 reports in South Delhi'),
                  const Divider(color: Colors.white12, height: 20),
                  _insightRow('Patrol Suggestion', 'Increase patrol in Karol Bagh after 9 PM'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w800)),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _alertCard(String name, String time, String status, String location) {
    final statusColor = status == 'active' ? AppColors.danger : status == 'responded' ? AppColors.warning : AppColors.safe;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(status == 'active' ? 0.5 : 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: statusColor.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(status == 'active' ? Icons.sos : Icons.check, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                Text('$location • $time', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _insightRow(String title, String detail) {
    return Row(
      children: [
        const Icon(Icons.insights, color: AppColors.accent, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(detail, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
