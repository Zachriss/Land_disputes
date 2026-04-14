import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dispute_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/dispute_model.dart';
import '../../models/user_model.dart';
import '../../widgets/dispute_card.dart';
import '../../constants/colors.dart';
import 'update_status_screen.dart';

class AllDisputesScreen extends StatefulWidget {
  const AllDisputesScreen({super.key});

  @override
  State<AllDisputesScreen> createState() => _AllDisputesScreenState();
}

class _AllDisputesScreenState extends State<AllDisputesScreen> {
  DisputeStatus? _filterStatus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load all disputes from Firebase when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DisputeProvider>(context, listen: false).loadAllDisputes();
    });
  }

  Future<void> _refreshDisputes() async {
    await Provider.of<DisputeProvider>(context, listen: false).loadAllDisputes();
  }

  Future<void> _showMediatorSelectionDialog(DisputeModel dispute) async {
    // Load mediators from Firebase
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadMediators();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Mediator'),
        content: Consumer<UserProvider>(
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
                    trailing: dispute.assignedMediatorId == mediator.id
                        ? Chip(
                            label: const Text('Assigned'),
                            backgroundColor: AppColors.successColor.withOpacity(0.1),
                            side: BorderSide(color: AppColors.successColor),
                            labelStyle: TextStyle(color: AppColors.successColor, fontSize: 12),
                          )
                        : null,
                    onTap: dispute.assignedMediatorId == mediator.id
                        ? null
                        : () => _assignMediatorToDispute(dispute, mediator),
                  ),
                );
              },
            );
          },
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

  Future<void> _assignMediatorToDispute(DisputeModel dispute, UserModel mediator) async {
    Navigator.pop(context); // Close dialog

    final disputeProvider = Provider.of<DisputeProvider>(context, listen: false);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool success = await disputeProvider.assignMediator(dispute.id!, mediator.id!);

    if (!mounted) return;
    Navigator.pop(context); // Hide loading

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mediator assigned successfully'),
          backgroundColor: AppColors.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(disputeProvider.errorMessage ?? 'Failed to assign mediator'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Disputes'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDisputes,
        child: Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search disputes...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
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
                      ...DisputeStatus.values.map((status) {
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
              ],
            ),
          ),
          // Disputes List
          Expanded(
            child: Consumer<DisputeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error loading disputes',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(provider.errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshDisputes,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                var filteredDisputes = provider.disputes;

                if (_filterStatus != null) {
                  filteredDisputes = filteredDisputes
                      .where((d) => d.status == _filterStatus)
                      .toList();
                }

                if (_searchQuery.isNotEmpty) {
                  filteredDisputes = filteredDisputes
                      .where((d) =>
                          d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          d.description.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                if (filteredDisputes.isEmpty) {
                  return const Center(
                    child: Text('No disputes found'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredDisputes.length,
                  itemBuilder: (context, index) {
                return DisputeCard(
                  dispute: filteredDisputes[index],
                  showOfficerActions: true,
                  onTap: () {
                    // Navigate to dispute details
                  },
                  onAssignMediator: () => _showMediatorSelectionDialog(filteredDisputes[index]),
                  onUpdateStatus: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UpdateStatusScreen(),
                      ),
                    );
                  },
                );
                  },
                );
              },
            ),
          ),
        ],
        ),
      ),
    );
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