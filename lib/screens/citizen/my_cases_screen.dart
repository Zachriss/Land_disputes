import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dispute_provider.dart';
import '../../constants/colors.dart';
import '../../widgets/dispute_card.dart';

class MyCasesScreen extends StatefulWidget {
  const MyCasesScreen({super.key});

  @override
  State<MyCasesScreen> createState() => _MyCasesScreenState();
}

class _MyCasesScreenState extends State<MyCasesScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadCases(),
        child: Consumer<DisputeProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.disputes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.disputes.isEmpty) {
              return const Center(
                child: Text('No cases found.\nTap + to report a new dispute.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.disputes.length,
              itemBuilder: (context, index) {
                final dispute = provider.disputes[index];
                return DisputeCard(
                  dispute: dispute,
                  onTap: () {
                    // Navigate to dispute details
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}