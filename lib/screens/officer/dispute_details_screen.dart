import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/dispute_model.dart';
import '../../models/document_model.dart';
import '../../widgets/document_card.dart';
import '../../widgets/custom_button.dart';
import '../../constants/colors.dart';
import '../../providers/dispute_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

class DisputeDetailsScreen extends StatefulWidget {
  final DisputeModel dispute;

  const DisputeDetailsScreen({
    super.key,
    required this.dispute,
  });

  @override
  State<DisputeDetailsScreen> createState() => _DisputeDetailsScreenState();
}

class _DisputeDetailsScreenState extends State<DisputeDetailsScreen> {
  List<DocumentModel> _documents = [];
  bool _loadingDocuments = false;
  String? _documentsError;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _loadingDocuments = true;
      _documentsError = null;
    });

    try {
      // TODO: Implement document loading from Firestore using documentIds
      setState(() {
        _documents = [];
        _loadingDocuments = false;
      });
    } catch (e) {
      setState(() {
        _documentsError = e.toString();
        _loadingDocuments = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispute Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dispute.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatusBadge(widget.dispute.status),
                        const SizedBox(width: 8),
                        _buildPriorityChip(widget.dispute.priority),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(widget.dispute.description),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: AppColors.primaryColor),
                      title: Text(widget.dispute.location),
                      subtitle: Text('Plot Number: ${widget.dispute.plotNumber}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: AppColors.infoColor),
                      title: Text('Submitted Date'),
                      subtitle: Text('${widget.dispute.createdAt.day}/${widget.dispute.createdAt.month}/${widget.dispute.createdAt.year}'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Documents / Attachments Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Attached Documents',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Chip(
                          label: Text('${_documents.length} Documents'),
                          backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_loadingDocuments)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_documentsError != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Error loading documents: $_documentsError'),
                        ),
                      )
                    else if (_documents.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No documents attached'),
                        ),
                      )
                    else
                      ..._documents.map((document) {
                      return DocumentCard(
                        document: document,
                        showVerificationButtons: true,
                        onVerifyValid: () => _verifyDocument(document, true),
                        onVerifyInvalid: () => _verifyDocument(document, false),
                      );
                      }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Officer Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Assign Mediator',
                    icon: Icons.person_add,
                    onPressed: () => _showMediatorSelectionDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Update Status',
                    icon: Icons.update,
                    onPressed: () => _showStatusUpdateDialog(),
                    color: AppColors.infoColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(DisputeStatus status) {
    Color color;
    String label;
    switch (status) {
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

  Widget _buildPriorityChip(DisputePriority priority) {
    Color color;
    String label;
    switch (priority) {
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

  Future<void> _verifyDocument(DocumentModel document, bool isValid) async {
    // TODO: Implement verifyDocument method in DisputeProvider
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Document marked as ${isValid ? 'Valid' : 'Invalid'}'),
        backgroundColor: isValid ? AppColors.successColor : AppColors.errorColor,
      ),
    );
  }

  Future<void> _showMediatorSelectionDialog() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadMediators();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Mediator'),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<UserProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (provider.mediators.isEmpty) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: Text('No mediators available')),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: provider.mediators.length,
                itemBuilder: (context, index) {
                  final mediator = provider.mediators[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(mediator.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(mediator.email),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        child: Icon(Icons.person, color: AppColors.primaryColor),
                      ),
                      trailing: widget.dispute.assignedMediatorId == mediator.id
                          ? TextButton.icon(
                              icon: const Icon(Icons.remove_circle, color: AppColors.errorColor, size: 18),
                              label: const Text('Unassign', style: TextStyle(color: AppColors.errorColor, fontSize: 12)),
                              onPressed: () => _unassignMediator(),
                            )
                          : null,
                      onTap: widget.dispute.assignedMediatorId == mediator.id
                          ? null
                          : () => _assignMediatorToDispute(mediator),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _assignMediatorToDispute(UserModel mediator) async {
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final disputeProvider = Provider.of<DisputeProvider>(context, listen: false);
    bool success = await disputeProvider.assignMediator(widget.dispute.id!, mediator.id!);

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mediator assigned successfully'),
          backgroundColor: AppColors.successColor,
        ),
      );
    }
  }

  Future<void> _unassignMediator() async {
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final disputeProvider = Provider.of<DisputeProvider>(context, listen: false);
    bool success = await disputeProvider.assignMediator(widget.dispute.id!, null);

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mediator unassigned successfully'),
          backgroundColor: AppColors.successColor,
        ),
      );
    }
  }

  Future<void> _showStatusUpdateDialog() async {
    DisputeStatus? selectedStatus = widget.dispute.status;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: DisputeStatus.values.map((status) {
              return RadioListTile<DisputeStatus>(
                title: Text(_statusToLabel(status)),
                value: status,
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                  Navigator.pop(context, value);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedStatus != null && selectedStatus != widget.dispute.status) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final disputeProvider = Provider.of<DisputeProvider>(context, listen: false);
      bool success = await disputeProvider.updateDisputeStatus(widget.dispute.id!, selectedStatus!);

      if (!mounted) return;
      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status updated successfully'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
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
}