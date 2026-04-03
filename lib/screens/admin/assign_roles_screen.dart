import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_button.dart';

class AssignRolesScreen extends StatefulWidget {
  const AssignRolesScreen({super.key});

  @override
  State<AssignRolesScreen> createState() => _AssignRolesScreenState();
}

class _AssignRolesScreenState extends State<AssignRolesScreen> {
  String _searchQuery = '';
  UserRole? _filterRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  void _loadUsers() {
    Provider.of<UserProvider>(context, listen: false).loadAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Roles'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage User Roles',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Change user roles and permissions',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search users...',
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
                        selected: _filterRole == null,
                        onSelected: (_) => setState(() => _filterRole = null),
                      ),
                      const SizedBox(width: 8),
                      ...UserRole.values.map((role) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(_roleToLabel(role)),
                            selected: _filterRole == role,
                            onSelected: (selected) {
                              setState(() => _filterRole = selected ? role : null);
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
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.users.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                var users = provider.users;
                if (_filterRole != null) {
                  users = users.where((u) => u.role == _filterRole).toList();
                }
                if (_searchQuery.isNotEmpty) {
                  users = users.where((u) =>
                      u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      u.email.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }

                if (users.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(user.role),
                          child: Text(
                            user.fullName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(user.fullName),
                        subtitle: Text(user.email),
                        trailing: DropdownButton<UserRole>(
                          value: user.role,
                          onChanged: (newRole) {
                            if (newRole != null && newRole != user.role) {
                              _showChangeRoleDialog(user, newRole);
                            }
                          },
                          items: UserRole.values.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(_roleToLabel(role)),
                            );
                          }).toList(),
                        ),
                      ),
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

  void _showChangeRoleDialog(UserModel user, UserRole newRole) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Role'),
        content: Text(
          'Change ${user.fullName}\'s role from ${_roleToLabel(user.role)} to ${_roleToLabel(newRole)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<UserProvider>(context, listen: false)
                  .updateUserRole(user.id!, newRole);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Role updated to ${_roleToLabel(newRole)}'),
                  backgroundColor: AppColors.successColor,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.citizen:
        return Colors.blue;
      case UserRole.officer:
        return Colors.orange;
      case UserRole.mediator:
        return Colors.purple;
      case UserRole.admin:
        return Colors.red;
    }
  }

  String _roleToLabel(UserRole role) {
    switch (role) {
      case UserRole.citizen:
        return 'Citizen';
      case UserRole.officer:
        return 'Officer';
      case UserRole.mediator:
        return 'Mediator';
      case UserRole.admin:
        return 'Admin';
    }
  }
}