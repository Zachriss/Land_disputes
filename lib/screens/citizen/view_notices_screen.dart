import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class ViewNoticesScreen extends StatelessWidget {
  const ViewNoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Case Notices',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.announcement, color: AppColors.primaryColor),
                ),
                title: const Text('Case Summon'),
                subtitle: const Text('Case #LD-2026-001 • 2 days ago'),
                trailing: const Chip(
                  label: Text('New'),
                  backgroundColor: Colors.red,
                  labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                ),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.warning, color: Colors.orange),
                ),
                title: const Text('Meeting Reminder'),
                subtitle: const Text('Case #LD-2026-001 • 5 days ago'),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}