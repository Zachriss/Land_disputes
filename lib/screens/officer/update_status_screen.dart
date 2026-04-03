import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dispute_provider.dart';
import '../../models/dispute_model.dart';
import '../../constants/colors.dart';
import '../../widgets/dispute_card.dart';

class UpdateStatusScreen extends StatefulWidget {
  const UpdateStatusScreen({super.key});

  @override
  State<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  DisputeModel? _selectedDispute;
  DisputeStatus? _newStatus;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus() async {
    if (_selectedDispute == null || _newStatus == null) return;

    final disputeProvider = Provider.of<DisputeProvider>(context, listen: false);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool success = await disputeProvider.updateDisputeStatus(
      _selectedDispute!.id!,
      _newStatus!,
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // Hide loading

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status updated successfully'),
          backgroundColor: AppColors.successColor,
        ),
      );
      setState(() {
        _selectedDispute = null;
        _newStatus = null;
        _notesController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(disputeProvider.errorMessage ?? 'Failed to update status'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Dispute Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Select dispute section
            if (_selectedDispute == null) _buildDisputeSelection(),
            if (_selectedDispute != null) _buildSelectedDispute(),

            if (_selectedDispute != null) ...[
              const SizedBox(height: 24),
              const Text(
                'New Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DisputeStatus.values.map((status) {
                  return ChoiceChip(
                    label: Text(_statusToLabel(status)),
                    selected: _newStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        _newStatus = selected ? status : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Add notes about this status change',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_newStatus != null) ? _updateStatus : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Update Status'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDisputeSelection() {
    return Consumer<DisputeProvider>(
      builder: (context, provider, child) {
        if (provider.disputes.isEmpty) {
          return const Center(child: Text('No disputes available to update'));
        }

        return Column(
          children: [
            const Text('Select a dispute to update:'),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.disputes.length > 5 ? 5 : provider.disputes.length,
              itemBuilder: (context, index) {
                final dispute = provider.disputes[index];
                return DisputeCard(
                  dispute: dispute,
                  onTap: () {
                    setState(() => _selectedDispute = dispute);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectedDispute() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selected Dispute',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedDispute = null;
                      _newStatus = null;
                      _notesController.clear();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Title: ${_selectedDispute!.title}'),
            Text('Current Status: ${_statusToLabel(_selectedDispute!.status)}'),
            Text('Priority: ${_priorityToLabel(_selectedDispute!.priority)}'),
          ],
        ),
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
}