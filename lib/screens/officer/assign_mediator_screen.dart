import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dispute_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/dispute_model.dart';
import '../../models/user_model.dart';
import '../../constants/colors.dart';

class AssignMediatorScreen extends StatefulWidget {
  const AssignMediatorScreen({super.key});

  @override
  State<AssignMediatorScreen> createState() => _AssignMediatorScreenState();
}

class _AssignMediatorScreenState extends State<AssignMediatorScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DisputeProvider>(context, listen: false).loadAllDisputes();
    });
  }

  Future<void> _refreshDisputes() async {
    await Provider.of<DisputeProvider>(context, listen: false).loadAllDisputes();
  }

  Future<void> _showMediatorSelectionDialog(DisputeModel dispute) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadMediators();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Mediator'),
        content: Consumer<UserProvider>(
          builder: (context, provider, child) {
            // Fixed height container to avoid layout jumps and intrinsic width errors
            return SizedBox(
              height: 400,
              width: double.maxFinite,
              child: _buildDialogContent(provider, dispute),
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

  Widget _buildDialogContent(UserProvider provider, DisputeModel dispute) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.mediators.isEmpty) {
      return const Center(child: Text('No mediators available in system'));
    }

    return ListView.builder(
      // shrinkWrap is false by default – safe because parent has fixed height
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
  }

  Future<void> _assignMediatorToDispute(DisputeModel dispute, UserModel mediator) async {
    Navigator.pop(context); // close the dialog

    final disputeProvider = Provider.of<DisputeProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool success = await disputeProvider.assignMediator(dispute.id!, mediator.id!);

    if (!mounted) return;
    Navigator.pop(context); // close loading dialog

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Mediator ${mediator.fullName} assigned successfully'),
          backgroundColor: AppColors.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(disputeProvider.errorMessage ?? '❌ Failed to assign mediator'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Mediators'),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDisputes,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search disputes to assign',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: AppColors.primaryColor.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Tap on any dispute to select and assign a mediator',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

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
                          Icon(Icons.error_outline, color: Colors.red[700], size: 48),
                          const SizedBox(height: 16),
                          const Text('Error loading disputes', style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(provider.errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshDisputes,
                            child: const Text('Retry Loading'),
                          ),
                        ],
                      ),
                    );
                  }

                  var filteredDisputes = provider.disputes;

                  if (_searchQuery.isNotEmpty) {
                    filteredDisputes = filteredDisputes
                        .where((d) =>
                            d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            d.description.toLowerCase().contains(_searchQuery.toLowerCase()))
                        .toList();
                  }

                  if (filteredDisputes.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No disputes available'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredDisputes.length,
                    itemBuilder: (context, index) {
                      final dispute = filteredDisputes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: InkWell(
                          onTap: () => _showMediatorSelectionDialog(dispute),
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (dispute.assignedMediatorId != null)
                                      const Chip(
                                        label: Text('Assigned'),
                                        backgroundColor: Colors.green,
                                        labelStyle: TextStyle(color: Colors.white, fontSize: 11),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(dispute.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(dispute.location, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: () => _showMediatorSelectionDialog(dispute),
                                      icon: const Icon(Icons.person_add, size: 16),
                                      label: const Text('Assign Mediator'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primaryColor,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
      ),
    );
  }
}