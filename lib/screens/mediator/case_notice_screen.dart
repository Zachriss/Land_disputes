import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class CaseNoticeScreen extends StatelessWidget {
  const CaseNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Case Notice',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Case Reference',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Recipient Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: 'Notice Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'summon', child: Text('Summon')),
                        DropdownMenuItem(value: 'reminder', child: Text('Reminder')),
                        DropdownMenuItem(value: 'warning', child: Text('Warning')),
                        DropdownMenuItem(value: 'decision', child: Text('Decision Notice')),
                      ],
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Notice Content',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Send Notice',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}