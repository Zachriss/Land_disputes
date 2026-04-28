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
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCases();
    });
  }

  Future<void> _loadCases() async {
    if (_isRefreshing) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userUid == null) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await Provider.of<DisputeProvider>(context, listen: false)
          .loadDisputesByUser(authProvider.userUid!);
    } catch (e) {
      debugPrint('Failed to load cases: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  /// ✅ Stable filtered list (computed once per build, no unnecessary copies)
  List<DisputeModel> getFilteredDisputes(List<DisputeModel> disputes) {
    if (_selectedFilter == null) return disputes;
    return disputes.where((d) {
      // Safe null check for status
      return d.status == _selectedFilter;
    }).toList(growable: false);
  }

  void _showDisputeDetails(DisputeModel dispute) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.7, 0.95],
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
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
                  dispute.title ?? 'Untitled Dispute',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ Full null safety for all fields
                if (dispute.location.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dispute.location,
                            style: const TextStyle(color: AppColors.textLight),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (dispute.plotNumber.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.numbers, size: 16, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(
                          'Plot No: ${dispute.plotNumber}',
                          style: const TextStyle(color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),

                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(dispute.description ?? 'No description provided'),
                const SizedBox(height: 16),

                // Rejection reason - only show if rejected
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

                // ✅ Safe document handling
                if (dispute.documentIds == null || dispute.documentIds!.isEmpty)
                  const Text('No documents attached', style: TextStyle(color: AppColors.textLight))
                else
                  ...dispute.documentIds!
                      .where((url) => url.isNotEmpty)
                      .map((url) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.insert_drive_file, color: AppColors.primaryColor),
                          title: Text(
                            url.split('/').last.split('?').first,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.open_in_new, size: 18),
                          onTap: () => _openDocument(url),
                        ),
                      )),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Safe URL launching with proper error handling
  Future<void> _openDocument(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open document')),
          );
        }
      }
    } catch (e) {
      debugPrint('Document open error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open document')),
        );
      }
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
              'My Cases',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
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
            const SizedBox(height: 16),
            Consumer<DisputeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.disputes.isEmpty && !_isRefreshing) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredDisputes = getFilteredDisputes(provider.disputes);

                if (filteredDisputes.isEmpty && !provider.isLoading) {
                  return const Center(
                    child: Text('No cases found for selected filter.'),
                  );
                }

                return Column(
                  children: filteredDisputes.map((dispute) {
                    return DisputeCard(
                      dispute: dispute,
                      onTap: () => _showDisputeDetails(dispute),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(DisputeStatus? status, String label) {
    final isSelected = _selectedFilter == status;
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
      side: isSelected
          ? BorderSide(color: AppColors.primaryColor.withOpacity(0.5))
          : const BorderSide(color: Colors.grey),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}