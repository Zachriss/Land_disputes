import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dispute_provider.dart';
import '../../models/dispute_model.dart';
import '../../models/user_model.dart';
import '../../constants/colors.dart';

class ReportsAnalyticsScreen extends StatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
  int _touchedIndex = -1;
  bool _isLoadingOfficer = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOfficerData();
  }

  Future<void> _loadOfficerData() async {
    setState(() {
      _isLoadingOfficer = true;
      _errorMessage = null;
    });

    try {
      final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (currentUser == null) {
        setState(() => _errorMessage = 'No user logged in. Please log in again.');
        return;
      }

      // DEBUG: Print the actual role to console – remove after debugging
      print('User role: "${currentUser.role}"');

      // Case‑insensitive role check – replace 'officer' with your exact stored value if needed
      if (currentUser.role != UserRole.officer) {
        setState(() => _errorMessage = 'Officer access required. Your role: ${currentUser.role}');
        return;
      }

      if (currentUser.id == null) {
        setState(() => _errorMessage = 'Officer ID not found.');
        return;
      }

      final disputeProvider = Provider.of<DisputeProvider>(context, listen: false);
      await disputeProvider.loadDisputesByOfficer(currentUser.id!);

      setState(() => _isLoadingOfficer = false);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadOfficerData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingOfficer) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.errorColor),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOfficerData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Consumer<DisputeProvider>(
      builder: (context, disputeProvider, child) {
        final currentUser = Provider.of<AuthProvider>(context).currentUser;

        // Additional safety checks
        if (currentUser == null) {
          return const Center(child: Text('User data not available.'));
        }

        if (disputeProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (disputeProvider.errorMessage != null) {
          return Center(
            child: Column(
              children: [
                Text('Error: ${disputeProvider.errorMessage}'),
                ElevatedButton(
                  onPressed: () => disputeProvider.loadDisputesByOfficer(currentUser.id!),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final stats = disputeProvider.getDisputesByStatusCount();
        final total = stats.values.reduce((a, b) => a + b);
        final resolvedRate = total > 0
            ? ((stats['resolved'] ?? 0) / total * 100).toStringAsFixed(1)
            : '0';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Overview Statistics ----------
            const Text(
              'Overview Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: [
                _buildMetricCard('Total Disputes', total.toString(), Icons.folder_open, AppColors.primaryColor),
                _buildMetricCard('Resolved Rate', '$resolvedRate%', Icons.check_circle, AppColors.successColor),
                _buildMetricCard('Pending', (stats['pending'] ?? 0).toString(), Icons.hourglass_top, AppColors.warningColor),
                _buildMetricCard('In Progress', (stats['in_progress'] ?? 0).toString(), Icons.pending, AppColors.infoColor),
              ],
            ),
            const SizedBox(height: 24),

            // ---------- Status Distribution Pie Chart ----------
            const Text('Status Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(height: 250, child: _buildPieChart(stats)),
              ),
            ),
            const SizedBox(height: 16),

            // ---------- Officer Information ----------
            const Text('Officer Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [const Icon(Icons.person, color: AppColors.primaryColor), const SizedBox(width: 8), Text(currentUser.fullName ?? 'Unknown', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))]),
                    const SizedBox(height: 8),
                    Row(children: [const Icon(Icons.badge, color: AppColors.primaryColor), const SizedBox(width: 8), Text('Officer ID: ${currentUser.id ?? 'N/A'}', style: const TextStyle(fontSize: 14, color: AppColors.textLight))]),
                    const SizedBox(height: 8),
                    Row(children: [const Icon(Icons.email, color: AppColors.primaryColor), const SizedBox(width: 8), Text(currentUser.email ?? 'N/A', style: const TextStyle(fontSize: 14, color: AppColors.textLight))]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ---------- Legend ----------
            _buildLegend(),
            const SizedBox(height: 24),

            // ---------- Detailed Status Breakdown ----------
            const Text('Detailed Status Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatusRow('Pending', stats['pending'] ?? 0, AppColors.warningColor),
                    const SizedBox(height: 12),
                    _buildStatusRow('In Progress', stats['in_progress'] ?? 0, AppColors.infoColor),
                    const SizedBox(height: 12),
                    _buildStatusRow('Resolved', stats['resolved'] ?? 0, AppColors.successColor),
                    const SizedBox(height: 12),
                    _buildStatusRow('Rejected', stats['rejected'] ?? 0, AppColors.errorColor),
                    const SizedBox(height: 12),
                    _buildStatusRow('On Hold', stats['on_hold'] ?? 0, AppColors.textLight),
                    const SizedBox(height: 12),
                    _buildStatusRow('Closed', stats['closed'] ?? 0, AppColors.borderColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ---------- Dispute Types ----------
            const Text('Dispute Types', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTypeRow('Boundary', disputeProvider.getDisputesByType(DisputeType.boundary).length, Colors.blue),
                    const SizedBox(height: 12),
                    _buildTypeRow('Ownership', disputeProvider.getDisputesByType(DisputeType.ownership).length, Colors.green),
                    const SizedBox(height: 12),
                    _buildTypeRow('Inheritance', disputeProvider.getDisputesByType(DisputeType.inheritance).length, Colors.orange),
                    const SizedBox(height: 12),
                    _buildTypeRow('Lease', disputeProvider.getDisputesByType(DisputeType.lease).length, Colors.purple),
                    const SizedBox(height: 12),
                    _buildTypeRow('Other', disputeProvider.getDisputesByType(DisputeType.other).length, Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ---------- Export Report Button ----------
            ElevatedButton.icon(
              onPressed: () => _generateReport(disputeProvider),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export Report'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ],
        );
      },
    );
  }

  // ---------- Helper: Pie Chart with zero‑data protection ----------
  Widget _buildPieChart(Map<String, int> stats) {
    final values = [
      stats['pending'] ?? 0,
      stats['in_progress'] ?? 0,
      stats['resolved'] ?? 0,
      stats['rejected'] ?? 0,
      stats['on_hold'] ?? 0,
      stats['closed'] ?? 0,
    ];

    if (values.every((v) => v == 0)) {
      return const Center(child: Text('No data to display'));
    }

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: _getPieChartSections(stats),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections(Map<String, int> stats) {
    final colors = [
      AppColors.warningColor,
      AppColors.infoColor,
      AppColors.successColor,
      AppColors.errorColor,
      AppColors.textLight,
      AppColors.borderColor,
    ];
    final values = [
      stats['pending'] ?? 0,
      stats['in_progress'] ?? 0,
      stats['resolved'] ?? 0,
      stats['rejected'] ?? 0,
      stats['on_hold'] ?? 0,
      stats['closed'] ?? 0,
    ];

    return List.generate(6, (index) {
      final isTouched = index == _touchedIndex;
      final value = values[index].toDouble();
      if (value == 0) {
        return PieChartSectionData(
          color: colors[index],
          value: 0,
          showTitle: false,
          radius: 0,
        );
      }
      return PieChartSectionData(
        color: colors[index],
        value: value,
        title: value.toInt().toString(),
        radius: isTouched ? 60 : 50,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  // ---------- Generate Report (placeholder) ----------
  Future<void> _generateReport(DisputeProvider disputeProvider) async {
    try {
      final currentUser = Provider.of<AuthProvider>(context).currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final stats = disputeProvider.getDisputesByStatusCount();
      final total = stats.values.reduce((a, b) => a + b);
      final resolvedRate = total > 0 ? ((stats['resolved'] ?? 0) / total * 100).toStringAsFixed(1) : '0';

      final reportContent = '''
LAND DISPUTES MANAGEMENT SYSTEM
OFFICER PERFORMANCE REPORT
${DateTime.now().toString().substring(0, 16)}

----------------------------------
OFFICER DETAILS
Name: ${currentUser.fullName ?? 'Unknown'}
ID: ${currentUser.id ?? 'N/A'}
Email: ${currentUser.email ?? 'N/A'}

----------------------------------
OVERVIEW STATISTICS
Total Disputes: $total
Resolved Rate: $resolvedRate%
Pending: ${stats['pending'] ?? 0}
In Progress: ${stats['in_progress'] ?? 0}
Resolved: ${stats['resolved'] ?? 0}
Rejected: ${stats['rejected'] ?? 0}
On Hold: ${stats['on_hold'] ?? 0}
Closed: ${stats['closed'] ?? 0}

----------------------------------
DISPUTE TYPE BREAKDOWN
Boundary: ${disputeProvider.getDisputesByType(DisputeType.boundary).length}
Ownership: ${disputeProvider.getDisputesByType(DisputeType.ownership).length}
Inheritance: ${disputeProvider.getDisputesByType(DisputeType.inheritance).length}
Lease: ${disputeProvider.getDisputesByType(DisputeType.lease).length}
Other: ${disputeProvider.getDisputesByType(DisputeType.other).length}
----------------------------------
''';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report generated successfully (saving not yet implemented)')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate report: $e')),
      );
    }
  }

  // ---------- UI Components ----------
  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textLight), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        Text(count.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildTypeRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        Text(count.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: const [
        _LegendItem('Pending', AppColors.warningColor),
        _LegendItem('In Progress', AppColors.infoColor),
        _LegendItem('Resolved', AppColors.successColor),
        _LegendItem('Rejected', AppColors.errorColor),
        _LegendItem('On Hold', AppColors.textLight),
        _LegendItem('Closed', AppColors.borderColor),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendItem(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}