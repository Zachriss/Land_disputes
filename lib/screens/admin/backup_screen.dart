import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isBackingUp = false;
  bool _isRestoring = false;
  String? _lastBackupDate;

  Future<void> _performBackup() async {
    setState(() => _isBackingUp = true);

    // Simulate backup
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isBackingUp = false;
      _lastBackupDate = DateTime.now().toString().split('.').first;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup completed successfully'),
        backgroundColor: AppColors.successColor,
      ),
    );
  }

  Future<void> _performRestore() async {
    setState(() => _isRestoring = true);

    // Simulate restore
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isRestoring = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restore completed successfully'),
        backgroundColor: AppColors.successColor,
      ),
    );
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
              'Backup & Restore',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _BackupCard(
              title: 'Backup Data',
              description: 'Create a backup of all disputes and user data',
              icon: Icons.cloud_upload,
              isLoading: _isBackingUp,
              onTap: _performBackup,
              lastBackup: _lastBackupDate,
            ),
            const SizedBox(height: 16),
            _BackupCard(
              title: 'Restore Data',
              description: 'Restore data from a previous backup',
              icon: Icons.cloud_download,
              isLoading: _isRestoring,
              onTap: _performRestore,
              isRestore: true,
            ),
            const SizedBox(height: 24),
            const Text(
              'Backup Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Automatic Backup'),
                    subtitle: const Text('Backup data daily'),
                    value: false,
                    onChanged: (value) {
                      // Update setting
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Backup History'),
                    subtitle: Text(_lastBackupDate != null ? 'Last: $_lastBackupDate' : 'No backups yet'),
                    onTap: () {
                      // Show backup history
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;
  final String? lastBackup;
  final bool isRestore;

  const _BackupCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isLoading,
    required this.onTap,
    this.lastBackup,
    this.isRestore = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isRestore
                        ? AppColors.infoColor.withOpacity(0.1)
                        : AppColors.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isRestore ? AppColors.infoColor : AppColors.successColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (lastBackup != null) ...[
              const SizedBox(height: 12),
              Text(
                'Last backup: $lastBackup',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onTap,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(isRestore ? Icons.restore : Icons.backup),
                label: Text(isLoading ? 'Processing...' : isRestore ? 'Restore' : 'Backup Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}