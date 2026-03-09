import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/safety_report.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../services/report_service.dart';
import '../services/database_service.dart';
import '../widgets/report_card.dart';

/// Community safety reporting screen
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _reportService =
      ReportService(databaseService: DatabaseService());
  List<SafetyReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    _reports = await _reportService.getReports();
    setState(() => _isLoading = false);
  }

  void _showAddReportSheet() {
    final descController = TextEditingController();
    String selectedCategory = 'suspicious';
    String selectedSeverity = 'medium';
    bool isAnonymous = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Report Unsafe Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category
                  const Text('Category',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['harassment', 'theft', 'assault', 'suspicious', 'other']
                        .map((c) => ChoiceChip(
                              label: Text(c.toUpperCase(),
                                  style: const TextStyle(fontSize: 11)),
                              selected: selectedCategory == c,
                              onSelected: (_) =>
                                  setSheetState(() => selectedCategory = c),
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surfaceLight,
                              labelStyle: TextStyle(
                                color: selectedCategory == c
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Severity
                  const Text('Severity',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ('low', AppColors.safe),
                      ('medium', AppColors.warning),
                      ('high', AppColors.danger),
                    ]
                        .map((s) => ChoiceChip(
                              label: Text(s.$1.toUpperCase(),
                                  style: const TextStyle(fontSize: 11)),
                              selected: selectedSeverity == s.$1,
                              onSelected: (_) =>
                                  setSheetState(() => selectedSeverity = s.$1),
                              selectedColor: s.$2,
                              backgroundColor: AppColors.surfaceLight,
                              labelStyle: TextStyle(
                                color: selectedSeverity == s.$1
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: descController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe what makes this area unsafe...',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Anonymous toggle
                  Row(
                    children: [
                      Switch(
                        value: isAnonymous,
                        onChanged: (v) =>
                            setSheetState(() => isAnonymous = v),
                        activeColor: AppColors.primary,
                      ),
                      const Text('Submit Anonymously',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (descController.text.isEmpty) return;
                        final user = context.read<AuthProvider>().user;
                        final loc = context.read<LocationProvider>();
                        await _reportService.submitReport(
                          userId: user?.id ?? 'anonymous',
                          userName: user?.name ?? 'Anonymous',
                          latitude: loc.latitude,
                          longitude: loc.longitude,
                          description: descController.text,
                          category: selectedCategory,
                          severity: selectedSeverity,
                          isAnonymous: isAnonymous,
                        );
                        if (mounted) {
                          Navigator.pop(ctx);
                          _loadReports();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Report submitted successfully'),
                              backgroundColor: AppColors.safe,
                            ),
                          );
                        }
                      },
                      child: const Text('Submit Report'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Reports'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _reports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.report_outlined,
                          size: 60, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No reports yet',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) =>
                        ReportCard(report: _reports[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReportSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Report', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
