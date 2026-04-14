import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class OfficerProfileScreen extends StatefulWidget {
  const OfficerProfileScreen({super.key});

  @override
  State<OfficerProfileScreen> createState() => _OfficerProfileScreenState();
}

class _OfficerProfileScreenState extends State<OfficerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _showLoginHistory = false;

  // Mock login history data
  final List<Map<String, dynamic>> _loginHistory = [
    {'date': '14/04/2026', 'time': '17:45:00', 'device': 'Edge Browser', 'ip': '192.168.1.105', 'location': 'Dar es Salaam'},
    {'date': '13/04/2026', 'time': '09:12:34', 'device': 'Chrome Mobile', 'ip': '192.168.1.102', 'location': 'Dar es Salaam'},
    {'date': '12/04/2026', 'time': '14:36:21', 'device': 'Edge Browser', 'ip': '192.168.1.105', 'location': 'Dar es Salaam'},
    {'date': '11/04/2026', 'time': '08:55:12', 'device': 'Firefox', 'ip': '10.0.0.45', 'location': 'Dar es Salaam'},
    {'date': '10/04/2026', 'time': '16:22:47', 'device': 'Edge Browser', 'ip': '192.168.1.105', 'location': 'Dar es Salaam'},
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: AppColors.successColor,
      ),
    );
    
    setState(() {
      _isEditing = false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primaryColor,
                    child: Text(
                      user?.fullName.substring(0, 1).toUpperCase() ?? 'O',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'Officer User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role.name.toUpperCase() ?? 'OFFICER',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _isEditing
                      ? CustomTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        )
                      : ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: const Text('Full Name'),
                          subtitle: Text(user?.fullName ?? 'N/A'),
                        ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(user?.email ?? 'N/A'),
                  ),
                  const Divider(),
                  _isEditing
                      ? CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        )
                      : ListTile(
                          leading: const Icon(Icons.phone_outlined),
                          title: const Text('Phone Number'),
                          subtitle: Text(user?.phoneNumber ?? 'N/A'),
                        ),
                  const Divider(),
                  // Login History Section
                  ListTile(
                    leading: const Icon(Icons.history_outlined),
                    title: const Text('Login History'),
                    subtitle: const Text('View your recent login activity'),
                    trailing: Icon(
                      _showLoginHistory ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textLight,
                    ),
                    onTap: () {
                      setState(() {
                        _showLoginHistory = !_showLoginHistory;
                      });
                    },
                  ),
                  if (_showLoginHistory)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: _loginHistory.map((login) {
                          return Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.successColor.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.login,
                                    size: 16,
                                    color: AppColors.successColor,
                                  ),
                                ),
                                title: Text('${login['date']} • ${login['time']}'),
                                subtitle: Text('${login['device']}\nIP: ${login['ip']} • ${login['location']}'),
                                isThreeLine: true,
                                dense: true,
                              ),
                              if (login != _loginHistory.last) const Divider(height: 0),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 32),
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Cancel',
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _nameController.text = user?.fullName ?? '';
                                _phoneController.text = user?.phoneNumber ?? '';
                              });
                            },
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: 'Save Changes',
                            onPressed: _isLoading ? null : _updateProfile,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
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