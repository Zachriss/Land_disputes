import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_button.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailAlerts = true;
  bool _smsAlerts = false;
  bool _darkMode = false;
  String _language = 'English';
  String _timezone = 'UTC+0';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            _buildSectionHeader('Notifications'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive push notifications'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Email Alerts'),
                    subtitle: const Text('Receive email notifications'),
                    value: _emailAlerts,
                    onChanged: (value) {
                      setState(() => _emailAlerts = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('SMS Alerts'),
                    subtitle: const Text('Receive SMS notifications'),
                    value: _smsAlerts,
                    onChanged: (value) {
                      setState(() => _smsAlerts = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Appearance Section
            _buildSectionHeader('Appearance'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Enable dark theme'),
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() => _darkMode = value);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Language'),
                    subtitle: Text(_language),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showLanguageDialog();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Timezone'),
                    subtitle: Text(_timezone),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showTimezoneDialog();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Security Section
            _buildSectionHeader('Security'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showChangePasswordDialog();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Two-Factor Authentication'),
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {
                        // TODO: Implement 2FA
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Login History'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Show login history
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Data & Privacy Section
            _buildSectionHeader('Data & Privacy'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('Export Data'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Export data
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showDeleteAccountDialog();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader('About'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('App Version'),
                    subtitle: const Text('1.0.0'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Show terms
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Show privacy policy
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Save Settings',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings saved successfully'),
                      backgroundColor: AppColors.successColor,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('Spanish'),
            _buildLanguageOption('French'),
            _buildLanguageOption('German'),
            _buildLanguageOption('Chinese'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return RadioListTile(
      title: Text(language),
      value: language,
      groupValue: _language,
      onChanged: (value) {
        setState(() => _language = value.toString());
        Navigator.pop(context);
      },
    );
  }

  void _showTimezoneDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Timezone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTimezoneOption('UTC-12'),
            _buildTimezoneOption('UTC-8'),
            _buildTimezoneOption('UTC-5'),
            _buildTimezoneOption('UTC+0'),
            _buildTimezoneOption('UTC+3'),
            _buildTimezoneOption('UTC+8'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimezoneOption(String timezone) {
    return RadioListTile(
      title: Text(timezone),
      value: timezone,
      groupValue: _timezone,
      onChanged: (value) {
        setState(() => _timezone = value.toString());
        Navigator.pop(context);
      },
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text == confirmPasswordController.text) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully'),
                    backgroundColor: AppColors.successColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: AppColors.errorColor,
                  ),
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}