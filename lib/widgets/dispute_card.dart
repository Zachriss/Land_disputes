import 'package:flutter/material.dart';
import '../models/dispute_model.dart';
import '../constants/colors.dart';

class DisputeCard extends StatelessWidget {
  final DisputeModel dispute;
  final VoidCallback onTap;

  const DisputeCard({
    super.key,
    required this.dispute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      dispute.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    '${dispute.location} - Plot: ${dispute.plotNumber}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityChip(),
                  const SizedBox(width: 8),
                  _buildTypeChip(),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Submitted: ${_formatDate(dispute.createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                  if (dispute.priority == DisputePriority.high || dispute.priority == DisputePriority.urgent)
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warningColor, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;
    switch (dispute.status) {
      case DisputeStatus.pending:
        color = AppColors.warningColor;
        label = 'Pending';
        break;
      case DisputeStatus.inProgress:
        color = AppColors.infoColor;
        label = 'In Progress';
        break;
      case DisputeStatus.resolved:
        color = AppColors.successColor;
        label = 'Resolved';
        break;
      case DisputeStatus.rejected:
        color = AppColors.errorColor;
        label = 'Rejected';
        break;
      case DisputeStatus.onHold:
        color = AppColors.textLight;
        label = 'On Hold';
        break;
      case DisputeStatus.closed:
        color = AppColors.borderColor;
        label = 'Closed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    Color color;
    String label;
    switch (dispute.priority) {
      case DisputePriority.low:
        color = Colors.blue;
        label = 'Low';
        break;
      case DisputePriority.medium:
        color = Colors.orange;
        label = 'Medium';
        break;
      case DisputePriority.high:
        color = Colors.red;
        label = 'High';
        break;
      case DisputePriority.urgent:
        color = Colors.purple;
        label = 'Urgent';
        break;
    }

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Widget _buildTypeChip() {
    String label;
    switch (dispute.disputeType) {
      case DisputeType.boundary:
        label = 'Boundary';
        break;
      case DisputeType.ownership:
        label = 'Ownership';
        break;
      case DisputeType.inheritance:
        label = 'Inheritance';
        break;
      case DisputeType.lease:
        label = 'Lease';
        break;
      case DisputeType.other:
        label = 'Other';
        break;
    }

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: AppColors.primaryColor.withOpacity(0.3)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}