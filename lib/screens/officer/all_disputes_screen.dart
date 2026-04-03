import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dispute_provider.dart';
import '../../models/dispute_model.dart';
import '../../widgets/dispute_card.dart';

class AllDisputesScreen extends StatefulWidget {
  const AllDisputesScreen({super.key});

  @override
  State<AllDisputesScreen> createState() => _AllDisputesScreenState();
}

class _AllDisputesScreenState extends State<AllDisputesScreen> {
  DisputeStatus? _filterStatus;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                      onTap: () {
                        // Navigate to dispute details
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