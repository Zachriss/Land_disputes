import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoAssignDisputes = false;
  bool _emailNotifications = true;
  int _maxDisputeDays = 30;
  String _defaultLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Configuration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configure system-wide settings and preferences',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 24),
            
            // Notification Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: const Text('Receive system notifications'),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Email Notifications'),
                      subtitle: const Text('Send email notifications'),
                      value: _emailNotifications,
                      onChanged: (value) {
                        setState(() => _emailNotifications = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Dispute Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dispute Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Auto-assign Disputes'),
                      subtitle: const Text('Automatically assign disputes to officers'),
                      value: _autoAssignDisputes,
                      onChanged: (value) {
                        setState(() => _autoAssignDisputes = value);
                      },
                    ),
                    ListTile(
                      title: const Text('Maximum Dispute Days'),
                      subtitle: Text('$_maxDisputeDays days'),
                      trailing: SizedBox(
                        width: 100,
                        child: Slider(
                          value: _maxDisputeDays.toDouble(),
                          min: 7,
                          max: 90,
                          divisions: 83,
                          onChanged: (value) {
                            setState(() => _maxDisputeDays = value.toInt());
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Language Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Language & Region',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Default Language'),
                      subtitle: Text(_defaultLanguage),
                      trailing: DropdownButton<String>(
                        value: _defaultLanguage,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _defaultLanguage = value);
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'English', child: Text('English')),
                          DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
                          DropdownMenuItem(value: 'French', child: Text('French')),
                          DropdownMenuItem(value: 'German', child: Text('German')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings saved successfully'),
                      backgroundColor: AppColors.successColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}