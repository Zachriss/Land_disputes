// lib/screens/admin/all_disputes_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dispute_provider.dart';
import '../../models/dispute_model.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';

class AllDisputesScreen extends StatefulWidget {
  const AllDisputesScreen({super.key});

  @override
  State<AllDisputesScreen> createState() => _AllDisputesScreenState();
}

class _AllDisputesScreenState extends State<AllDisputesScreen> {
  String _searchQuery = '';
  DisputeStatus? _filterStatus;
  String _sortBy = 'date'; // date, status, title
  bool _isAscending = false;

  @override
  void initState() {
    super.initState();
    _loadDisputes();
  }

  void _loadDisputes() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final disputeProvider = Provider.of<DisputeProvider>(context, listen: false);
      disputeProvider.loadAllDisputes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Disputes'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDisputes,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  _isAscending = !_isAscending;
                } else {
                  _sortBy = value;
                  _isAscending = false;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date',
                child: ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Sort by Date'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'status',
                child: ListTile(
                  leading: Icon(Icons.label),
                  title: Text('Sort by Status'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'title',
                child: ListTile(
                  leading: Icon(Icons.title),
                  title: Text('Sort by Title'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search disputes by title, description, or location...',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 16),
                
                // Status filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _filterStatus == null,
                        onSelected: (_) => setState(() => _filterStatus = null),
                        backgroundColor: Colors.grey[200],
                        selectedColor: AppColors.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      ...DisputeStatus.values.map((status) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(_getStatusText(status)),
                            selected: _filterStatus == status,
                            onSelected: (selected) {
                              setState(() => _filterStatus = selected ? status : null);
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: _getStatusColor(status).withOpacity(0.2),
                            checkmarkColor: _getStatusColor(status),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Disputes list
          Expanded(
            child: Consumer<DisputeProvider>(
              builder: (context, disputeProvider, child) {
                if (disputeProvider.isLoading && disputeProvider.disputes.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading disputes...'),
                      ],
                    ),
                  );
                }

                // Filter and search disputes
                var disputes = List<DisputeModel>.from(disputeProvider.disputes);
                
                // Apply status filter
                if (_filterStatus != null) {
                  disputes = disputes.where((d) => d.status == _filterStatus).toList();
                }
                
                // Apply search filter - adjust these fields based on your DisputeModel
                if (_searchQuery.isNotEmpty) {
                  disputes = disputes.where((d) =>
                      (d.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                      (d.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                      (d.location?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                      (d.id?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
                  ).toList();
                }
                
                // Apply sorting
                disputes = _sortDisputes(disputes);
                
                if (disputes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          disputeProvider.disputes.isEmpty 
                              ? 'No disputes found in the system'
                              : 'No disputes match your filters',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_searchQuery.isNotEmpty || _filterStatus != null)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _filterStatus = null;
                              });
                            },
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Clear all filters'),
                          ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: disputes.length,
                  itemBuilder: (context, index) {
                    final dispute = disputes[index];
                    return _DisputeListItem(
                      dispute: dispute,
                      onTap: () => _showDisputeDetails(dispute),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterDialog(),
        child: const Icon(Icons.filter_list),
        backgroundColor: AppColors.primaryColor,
        tooltip: 'Advanced Filters',
      ),
    );
  }

  List<DisputeModel> _sortDisputes(List<DisputeModel> disputes) {
    switch (_sortBy) {
      case 'date':
        disputes.sort((a, b) => _isAscending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case 'status':
        disputes.sort((a, b) => _isAscending
            ? a.status.index.compareTo(b.status.index)
            : b.status.index.compareTo(a.status.index));
        break;
      case 'title':
        disputes.sort((a, b) => _isAscending
            ? (a.title ?? '').compareTo(b.title ?? '')
            : (b.title ?? '').compareTo(a.title ?? ''));
        break;
    }
    return disputes;
  }

  void _showDisputeDetails(DisputeModel dispute) {
    // Show a dialog with dispute details since DisputeDetailScreen might not exist
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dispute.title ?? 'Dispute Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Status', _getStatusText(dispute.status)),
              const SizedBox(height: 8),
              _buildDetailRow('Description', dispute.description ?? 'No description'),
              const SizedBox(height: 8),
              if (dispute.location != null)
                _buildDetailRow('Location', dispute.location!),
              const SizedBox(height: 8),
              _buildDetailRow('Created', _formatDate(dispute.createdAt)),
            ],
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Filters'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sort Order:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Date'),
                    value: 'date',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setState(() => _sortBy = value!);
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Status'),
                    value: 'status',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setState(() => _sortBy = value!);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Ascending Order'),
              value: _isAscending,
              onChanged: (value) {
                setState(() => _isAscending = value);
                Navigator.pop(context);
              },
            ),
          ],
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

  String _getStatusText(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending:
        return 'Pending';
      case DisputeStatus.inProgress:
        return 'In Progress';
      case DisputeStatus.resolved:
        return 'Resolved';
      case DisputeStatus.rejected:
        return 'Rejected';
      case DisputeStatus.closed:
        return 'Closed';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending:
        return AppColors.warningColor;
      case DisputeStatus.inProgress:
        return AppColors.infoColor;
      case DisputeStatus.resolved:
        return AppColors.successColor;
      case DisputeStatus.rejected:
        return AppColors.errorColor;
      case DisputeStatus.closed:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DisputeListItem extends StatelessWidget {
  final DisputeModel dispute;
  final VoidCallback onTap;

  const _DisputeListItem({
    required this.dispute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dispute.title ?? 'Untitled Dispute',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(dispute.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(dispute.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(dispute.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Description
              if (dispute.description != null)
                Text(
                  dispute.description!,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              
              // Location if available
              if (dispute.location != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dispute.location!,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              
              // Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(dispute.createdAt),
                        style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right, size: 20, color: AppColors.textLight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending:
        return 'Pending';
      case DisputeStatus.inProgress:
        return 'In Progress';
      case DisputeStatus.resolved:
        return 'Resolved';
      case DisputeStatus.rejected:
        return 'Rejected';
      case DisputeStatus.closed:
        return 'Closed';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending:
        return AppColors.warningColor;
      case DisputeStatus.inProgress:
        return AppColors.infoColor;
      case DisputeStatus.resolved:
        return AppColors.successColor;
      case DisputeStatus.rejected:
        return AppColors.errorColor;
      case DisputeStatus.closed:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}