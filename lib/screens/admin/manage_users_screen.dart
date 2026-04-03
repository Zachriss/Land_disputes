import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _searchQuery = '';
  UserRole? _filterRole;

  @override
  void initState() {
    super.initState();
    // Load users after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  void _loadUsers() {
    // Make sure provider exists before calling
    final provider = Provider.of<UserProvider>(context, listen: false);
    provider.loadAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Manage Users',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add, edit, or remove users from the system',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Search field
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search users by name or email...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 16),
                
                // Filter chips
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
          
          // Users list
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, provider, child) {
                // Show loading indicator while loading and no users yet
                if (provider.isLoading && provider.users.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter users based on role and search query
                var users = List<UserModel>.from(provider.users);
                
                if (_filterRole != null) {
                  users = users.where((u) => u.role == _filterRole).toList();
                }
                if (_searchQuery.isNotEmpty) {
                  users = users.where((u) =>
                      u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      u.email.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }

                // Show empty state if no users
                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: AppColors.textLight),
                        const SizedBox(height: 16),
                        Text(
                          provider.users.isEmpty ? 'No users in system' : 'No users found',
                          style: const TextStyle(fontSize: 18, color: AppColors.textLight),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _showAddUserDialog(),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add a user'),
                        ),
                      ],
                    ),
                  );
                }

                // Display user list
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: user.isActive ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: user.isActive ? Colors.green : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(
                                _roleToLabel(user.role),
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'toggle_status',
                                  child: ListTile(
                                    leading: Icon(user.isActive ? Icons.block : Icons.check_circle),
                                    title: Text(user.isActive ? 'Deactivate' : 'Activate'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete, color: Colors.red),
                                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                              onSelected: (value) => _handleAction(user, value),
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserDialog(),
        icon: const Icon(Icons.person_add),
        label: const Text('Add User'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  void _handleAction(UserModel user, String action) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'toggle_status':
        _toggleUserStatus(user);
        break;
      case 'delete':
        _confirmDelete(user);
        break;
    }
  }

  void _showAddUserDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    UserRole selectedRole = UserRole.citizen;
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New User'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    obscureText: obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work),
                    ),
                    items: const [
                      DropdownMenuItem(value: UserRole.citizen, child: Text('Citizen')),
                      DropdownMenuItem(value: UserRole.officer, child: Text('Officer')),
                      DropdownMenuItem(value: UserRole.mediator, child: Text('Mediator')),
                      DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedRole = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _createUser(
                formKey,
                nameController,
                emailController,
                phoneController,
                passwordController,
                selectedRole,
              ),
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createUser(
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController phoneController,
    TextEditingController passwordController,
    UserRole role,
  ) async {
    if (!formKey.currentState!.validate()) return;

    // Show loading indicator
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creating user...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final email = emailController.text.trim();
      
      // Check if email already exists
      final existingUsers = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (existingUsers.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A user with this email already exists'),
            backgroundColor: AppColors.errorColor,
          ),
        );
        return;
      }

      // Create Firebase Auth user
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: passwordController.text.trim(),
      );

      // Save user data to Firestore
      final user = UserModel(
        id: userCredential.user!.uid, // Add the ID
        fullName: nameController.text.trim(),
        email: email,
        phoneNumber: phoneController.text.trim(),
        role: role,
        isActive: true,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toMap());

      if (!mounted) return;
      Navigator.pop(context); // Close dialog
      _loadUsers(); // Refresh user list
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_roleToLabel(role)} created successfully'),
          backgroundColor: AppColors.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating user: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void _showEditUserDialog(UserModel user) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.fullName);
    final phoneController = TextEditingController(text: user.phoneNumber);
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: user.email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    enabled: false, // Email cannot be changed
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work),
                    ),
                    items: const [
                      DropdownMenuItem(value: UserRole.citizen, child: Text('Citizen')),
                      DropdownMenuItem(value: UserRole.officer, child: Text('Officer')),
                      DropdownMenuItem(value: UserRole.mediator, child: Text('Mediator')),
                      DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedRole = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _updateUser(
                user,
                formKey,
                nameController,
                phoneController,
                selectedRole,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUser(
    UserModel user,
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController phoneController,
    UserRole role,
  ) async {
    if (!formKey.currentState!.validate()) return;

    final provider = Provider.of<UserProvider>(context, listen: false);
    
    // Update basic info
    await provider.updateUserProfile(user.id!, {
      'fullName': nameController.text.trim(),
      'phoneNumber': phoneController.text.trim(),
    });

    // Update role if changed
    if (role != user.role) {
      await provider.updateUserRole(user.id!, role);
    }

    if (!mounted) return;
    Navigator.pop(context);
    _loadUsers();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User updated successfully'),
        backgroundColor: AppColors.successColor,
      ),
    );
  }

  Future<void> _toggleUserStatus(UserModel user) async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    await provider.updateUserProfile(user.id!, {'isActive': !user.isActive});
    _loadUsers();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(user.isActive ? 'User deactivated' : 'User activated'),
        backgroundColor: AppColors.successColor,
      ),
    );
  }

  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<UserProvider>(context, listen: false);
              await provider.deleteUser(user.id!);
              
              // Also delete from Firebase Auth if needed
              try {
                // Note: Deleting from Auth requires admin privileges or re-authentication
                // This is optional based on your requirements
              } catch (e) {
                print('Error deleting auth user: $e');
              }
              
              if (!mounted) return;
              Navigator.pop(context);
              _loadUsers();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User deleted successfully'),
                  backgroundColor: AppColors.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorColor),
            child: const Text('Delete'),
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
  
  @override
  void dispose() {
    // Clean up controllers if needed
    super.dispose();
  }
}