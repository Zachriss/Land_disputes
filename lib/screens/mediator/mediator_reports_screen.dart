import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dispute_provider.dart';
import '../../models/dispute_model.dart';
import '../../constants/colors.dart';

class MediatorReportsScreen extends StatelessWidget {
  const MediatorReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final disputeProvider = Provider.of<DisputeProvider>(context);
    final totalCases = disputeProvider.disputes.length;
    final resolvedCases = disputeProvider.disputes.where((d) => d.status == DisputeStatus.resolved).length;
    final pendingCases = disputeProvider.disputes.where((d) => d.status == DisputeStatus.pending).length;
    final inProgressCases = disputeProvider.disputes.where((d) => d.status == DisputeStatus.inProgress).length;
    final onHoldCases = disputeProvider.disputes.where((d) => d.status == DisputeStatus.onHold).length;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reports & Analytics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.95,
              children: [
                _ReportCard(
                  title: 'Total Assigned',
                  count: totalCases,
                  color: AppColors.primaryColor,
                  icon: Icons.assignment,
                ),
                _ReportCard(
                  title: 'Resolved',
                  count: resolvedCases,
                  color: AppColors.successColor,
                  icon: Icons.check_circle,
                ),
                _ReportCard(
                  title: 'In Progress',
                  count: inProgressCases,
                  color: AppColors.infoColor,
                  icon: Icons.pending,
                ),
                _ReportCard(
                  title: 'Pending',
                  count: pendingCases,
                  color: AppColors.warningColor,
                  icon: Icons.hourglass_top,
                ),
                _ReportCard(
                  title: 'On Hold',
                  count: onHoldCases,
                  color: AppColors.errorColor,
                  icon: Icons.pause_circle,
                ),
                _ReportCard(
                  title: 'Resolution Rate',
                  count: totalCases > 0 ? ((resolvedCases / totalCases) * 100).round() : 0,
                  color: Colors.teal,
                  icon: Icons.trending_up,
                  suffix: '%',
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Performance Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _ProgressRow(
                      label: 'Resolved Cases',
                      value: resolvedCases,
                      total: totalCases,
                      color: AppColors.successColor,
                    ),
                    const SizedBox(height: 12),
                    _ProgressRow(
                      label: 'In Progress Cases',
                      value: inProgressCases,
                      total: totalCases,
                      color: AppColors.infoColor,
                    ),
                    const SizedBox(height: 12),
                    _ProgressRow(
                      label: 'Pending Cases',
                      value: pendingCases,
                      total: totalCases,
                      color: AppColors.warningColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final String? suffix;

  const _ReportCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
         child: Wrap(
           direction: Axis.vertical,
           alignment: WrapAlignment.center,
           crossAxisAlignment: WrapCrossAlignment.center,
           spacing: 1,
           children: [
             Icon(icon, color: color, size: 22),
             Text(
               suffix != null ? '$count$suffix' : count.toString(),
               style: TextStyle(
                 fontSize: 17,
                 fontWeight: FontWeight.bold,
                 color: color,
               ),
             ),
             Text(
               title,
               textAlign: TextAlign.center,
               style: const TextStyle(
                 fontSize: 10,
                 color: AppColors.textLight,
               ),
             ),
           ],
         ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;

  const _ProgressRow({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? value / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$value / $total'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: color.withOpacity(0.2),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}