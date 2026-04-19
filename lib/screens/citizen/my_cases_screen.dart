import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dispute_provider.dart';
import '../../models/dispute_model.dart';
import '../../constants/colors.dart';
import '../../widgets/dispute_card.dart';

class MyCasesScreen extends StatefulWidget {
  const MyCasesScreen({super.key});

  @override
  State<MyCasesScreen> createState() => _MyCasesScreenState();
}

class _MyCasesScreenState extends State<MyCasesScreen> {
  DisputeStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  void _loadCases() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userUid != null) {
      Provider.of<DisputeProvider>(context, listen: false)
          .loadDisputesByUser(authProvider.userUid!);
    }
  }

  List<DisputeModel> getFilteredDisputes(List<DisputeModel> disputes) {
    if (_selectedFilter == null) return disputes;
    return disputes.where((d) => d.status == _selectedFilter).toList();
  }

  void _showDisputeDetails(DisputeModel dispute) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                dispute.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    dispute.location,
                    style: const TextStyle(color: AppColors.textLight),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  const Icon(Icons.numbers, size: 16, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    'Plot No: ${dispute.plotNumber}',
                    style: const TextStyle(color: AppColors.textLight),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Text(
                'Description',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(dispute.description),
              const SizedBox(height: 16),
              
              if (dispute.status == DisputeStatus.rejected) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rejection Reason',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.errorColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dispute.additionalInfo?['rejectionReason'] ?? 'No reason provided',
                        style: const TextStyle(color: AppColors.errorColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              const Text(
                'Attached Documents',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              
              if (dispute.documentIds == null || dispute.documentIds!.isEmpty)
                const Text('No documents attached', style: TextStyle(color: AppColors.textLight))
              else
                ...dispute.documentIds!.map((url) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.insert_drive_file, color: AppColors.primaryColor),
                    title: Text(url.split('/').last.split('?').first),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () async {
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                )),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cases'),
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, 'All'),
                const SizedBox(width: 8),
                _buildFilterChip(DisputeStatus.pending, 'Pending'),
                const SizedBox(width: 8),
                _buildFilterChip(DisputeStatus.inProgress, 'In Progress'),
                const SizedBox(width: 8),
                _buildFilterChip(DisputeStatus.resolved, 'Resolved'),
                const SizedBox(width: 8),
                _buildFilterChip(DisputeStatus.rejected, 'Rejected'),
                const SizedBox(width: 8),
                _buildFilterChip(DisputeStatus.closed, 'Closed'),
              ],
            ),
          ),
          
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadCases(),
              child: Consumer<DisputeProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.disputes.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredDisputes = getFilteredDisputes(provider.disputes);

                  if (filteredDisputes.isEmpty) {
                    return const Center(
                      child: Text('No cases found for selected filter.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDisputes.length,
                    itemBuilder: (context, index) {
                      final dispute = filteredDisputes[index];
                      return DisputeCard(
                        dispute: dispute,
                        onTap: () => _showDisputeDetails(dispute),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(DisputeStatus? status, String label) {
    bool isSelected = _selectedFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? status : null;
        });
      },
      selectedColor: AppColors.primaryColor.withOpacity(0.2),
      checkmarkColor: AppColors.primaryColor,
    );
  }
}
