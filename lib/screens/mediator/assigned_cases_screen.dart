import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dispute_provider.dart';
import '../../models/dispute_model.dart';
import '../../widgets/dispute_card.dart';

class AssignedCasesScreen extends StatefulWidget {
  const AssignedCasesScreen({super.key});

  @override
  State<AssignedCasesScreen> createState() => _AssignedCasesScreenState();
}

class _AssignedCasesScreenState extends State<AssignedCasesScreen> {
  DisputeStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _filterStatus == null,
                    onSelected: (selected) {
                      setState(() => _filterStatus = null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ...[
                    DisputeStatus.pending,
                    DisputeStatus.inProgress,
                    DisputeStatus.resolved,
                  ].map((status) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_statusToLabel(status)),
                        selected: _filterStatus == status,
                        onSelected: (selected) {
                          setState(() {
                            _filterStatus = selected ? status : null;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          // Cases list
          Expanded(
            child: Consumer<DisputeProvider>(
              builder: (context, provider, child) {
                var disputes = provider.disputes;

                if (_filterStatus != null) {
                  disputes = disputes
                      .where((d) => d.status == _filterStatus)
                      .toList();
                }

                if (disputes.isEmpty) {
                  return const Center(
                    child: Text('No assigned cases'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: disputes.length,
                  itemBuilder: (context, index) {
                    final dispute = disputes[index];
                    return DisputeCard(
                      dispute: dispute,
                      onTap: () {
                        _showDisputeDetails(context, dispute);
                      },
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

  void _showDisputeDetails(BuildContext context, DisputeModel dispute) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dispute Details',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Title', dispute.title),
                _buildDetailRow('Location', dispute.location),
                _buildDetailRow('Plot Number', dispute.plotNumber),
                _buildDetailRow('Type', _typeToLabel(dispute.disputeType)),
                _buildDetailRow('Priority', _priorityToLabel(dispute.priority)),
                _buildDetailRow('Status', _statusToLabel(dispute.status)),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(dispute.description),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to status update
                    },
                    icon: const Icon(Icons.update),
                    label: const Text('Update Status'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _statusToLabel(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending: return 'Pending';
      case DisputeStatus.inProgress: return 'In Progress';
      case DisputeStatus.resolved: return 'Resolved';
      case DisputeStatus.rejected: return 'Rejected';
      case DisputeStatus.onHold: return 'On Hold';
      case DisputeStatus.closed: return 'Closed';
    }
  }

  String _priorityToLabel(DisputePriority priority) {
    switch (priority) {
      case DisputePriority.low: return 'Low';
      case DisputePriority.medium: return 'Medium';
      case DisputePriority.high: return 'High';
      case DisputePriority.urgent: return 'Urgent';
    }
  }

  String _typeToLabel(DisputeType type) {
    switch (type) {
      case DisputeType.boundary: return 'Boundary';
      case DisputeType.ownership: return 'Ownership';
      case DisputeType.inheritance: return 'Inheritance';
      case DisputeType.lease: return 'Lease';
      case DisputeType.other: return 'Other';
    }
  }
}