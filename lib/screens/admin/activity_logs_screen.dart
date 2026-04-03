import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dispute_provider.dart';
import '../../models/dispute_model.dart';
import '../../constants/colors.dart';

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key});

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    Provider.of<DisputeProvider>(context, listen: false).loadAllDisputes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Logs'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'System Activity',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'View all system activities and changes',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _filterType == 'all',
                        onSelected: (_) => setState(() => _filterType = 'all'),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Created'),
                        selected: _filterType == 'created',
                        onSelected: (_) => setState(() => _filterType = 'created'),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Updated'),
                        selected: _filterType == 'updated',
                        onSelected: (_) => setState(() => _filterType = 'updated'),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Resolved'),
                        selected: _filterType == 'resolved',
                        onSelected: (_) => setState(() => _filterType = 'resolved'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<DisputeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                var disputes = provider.disputes;
                if (_filterType != 'all') {
                  disputes = disputes.where((d) {
                    switch (_filterType) {
                      case 'created':
                        return d.status == DisputeStatus.pending;
                      case 'updated':
                        return d.status == DisputeStatus.inProgress;
                      case 'resolved':
                        return d.status == DisputeStatus.resolved;
                      default:
                        return true;
                    }
                  }).toList();
                }

                if (disputes.isEmpty) {
                  return const Center(child: Text('No activity logs found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: disputes.length,
                  itemBuilder: (context, index) {
                    final dispute = disputes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(dispute.status),
                          child: Icon(
                            _getStatusIcon(dispute.status),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(dispute.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${_statusToLabel(dispute.status)}'),
                            Text(
                              'Created: ${_formatDate(dispute.createdAt)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            _statusToLabel(dispute.status),
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: _getStatusColor(dispute.status).withOpacity(0.2),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending:
        return Colors.orange;
      case DisputeStatus.inProgress:
        return Colors.blue;
      case DisputeStatus.resolved:
        return Colors.green;
      case DisputeStatus.rejected:
        return Colors.red;
      case DisputeStatus.onHold:
        return Colors.grey;
      case DisputeStatus.closed:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending:
        return Icons.hourglass_top;
      case DisputeStatus.inProgress:
        return Icons.pending;
      case DisputeStatus.resolved:
        return Icons.check_circle;
      case DisputeStatus.rejected:
        return Icons.cancel;
      case DisputeStatus.onHold:
        return Icons.pause;
      case DisputeStatus.closed:
        return Icons.archive;
    }
  }

  String _statusToLabel(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending:
        return 'Pending';
      case DisputeStatus.inProgress:
        return 'In Progress';
      case DisputeStatus.resolved:
        return 'Resolved';
      case DisputeStatus.rejected:
        return 'Rejected';
      case DisputeStatus.onHold:
        return 'On Hold';
      case DisputeStatus.closed:
        return 'Closed';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}