import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../models/user_model.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../constants/firebase_consts.dart';
import '../../services/cloudinary_service.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class MediatorProfileScreen extends StatefulWidget {
  const MediatorProfileScreen({super.key});

  @override
  State<MediatorProfileScreen> createState() => _MediatorProfileScreenState();
}

class _MediatorProfileScreenState extends State<MediatorProfileScreen> {
  final StorageService _storageService = StorageService();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    UserModel? currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        backgroundImage: currentUser.profilePictureUrl != null
                            ? NetworkImage(currentUser.profilePictureUrl!)
                            : null,
                        child: currentUser.profilePictureUrl == null
                            ? const Icon(Icons.person, size: 60, color: AppColors.primaryColor)
                            : null,
                      ),
                      if (_isUploading)
                        const Positioned.fill(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        InkWell(
                          onTap: _uploadProfilePicture,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // User Info
                  Text(
                    currentUser.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentUser.email,
                    style: const TextStyle(color: AppColors.textLight, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phone: ${currentUser.phoneNumber ?? "Not provided"}',
                    style: const TextStyle(color: AppColors.textLight),
                  ),
                  const SizedBox(height: 32),

                  // Profile Details Cards
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Full Name'),
                      subtitle: Text(currentUser.fullName),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email Address'),
                      subtitle: Text(currentUser.email),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.phone),
                      title: const Text('Phone Number'),
                      subtitle: Text(currentUser.phoneNumber ?? 'Not set'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Address'),
                      subtitle: Text(currentUser.address ?? 'Not provided'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Member Since'),
                      subtitle: Text(
                        '${currentUser.createdAt.day}/${currentUser.createdAt.month}/${currentUser.createdAt.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  CustomButton(
                    text: 'Edit Profile',
                    onPressed: () => _showEditProfileDialog(currentUser),
                  ),
                  const SizedBox(height: 16),
                   CustomButton(
                     text: 'Change Password',
                     onPressed: _showChangePasswordDialog,
                     color: Colors.grey[700],
                   ),
                   const SizedBox(height: 16),
                   CustomButton(
                     text: 'Logout',
                     onPressed: () => _handleLogout(context),
                     color: Colors.red,
                   ),
                 ],
              ),
            ),
    );
  }

  Future<void> _uploadProfilePicture() async {
    try {
      PlatformFile? file = await _storageService.pickFile(
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        maxSizeInBytes: 5 * 1024 * 1024,
      );

      if (file == null) return;

      setState(() {
        _isUploading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final cloudinary = CloudinaryService();
      String? imageUrl = await cloudinary.uploadProfileImage(File(file.path!));

      if (imageUrl != null) {
        await FirebaseFirestore.instance
            .collection(FirebaseConsts.usersCollection)
            .doc(authProvider.userUid!)
            .update({
          'profilePictureUrl': imageUrl,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: AppColors.successColor,
            ),
          );
        }
      }

      setState(() {
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload profile picture: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  void _showEditProfileDialog(UserModel currentUser) {
    TextEditingController nameController = TextEditingController(text: currentUser.fullName);
    TextEditingController phoneController = TextEditingController(text: currentUser.phoneNumber);
    TextEditingController addressController = TextEditingController(text: currentUser.address);
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  keyboardType: TextInputType.streetAddress,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                setDialogState(() {
                  isSaving = true;
                });

                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final docRef = FirebaseFirestore.instance
                      .collection(FirebaseConsts.usersCollection)
                      .doc(currentUser.id);
                  
                  // Save to Firebase
                  await docRef.update({
                    'fullName': nameController.text.trim(),
                    'phoneNumber': phoneController.text.trim(),
                    'address': addressController.text.trim(),
                  });

                  // ✅ REFRESH PROVIDER STATE WITH LATEST DATA
                  // This is the critical fix - re-fetch user from Firestore and update provider
                  final updatedDoc = await docRef.get();
                  if (updatedDoc.exists) {
                    final updatedUser = UserModel.fromJson(updatedDoc.id, updatedDoc.data()!);
                    authProvider.setCurrentUser(updatedUser);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully'),
                        backgroundColor: AppColors.successColor,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('Profile update error: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update profile: $e'),
                        backgroundColor: AppColors.errorColor,
                      ),
                    );
                  }
                } finally {
                  setDialogState(() {
                    isSaving = false;
                  });
                }
              },
              child: isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }

   void _showChangePasswordDialog() {
    TextEditingController currentPassController = TextEditingController();
    TextEditingController newPassController = TextEditingController();
    TextEditingController confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPassController,
                  decoration: const InputDecoration(labelText: 'Current Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter current password';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: newPassController,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: confirmPassController,
                  decoration: const InputDecoration(labelText: 'Confirm New Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value != newPassController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
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
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  User user = FirebaseAuth.instance.currentUser!;
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: currentPassController.text,
                  );
                  await user.reauthenticateWithCredential(credential);
                  await user.updatePassword(newPassController.text);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password changed successfully'),
                        backgroundColor: AppColors.successColor,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to change password: $e'),
                      backgroundColor: AppColors.errorColor,
                    ),
                  );
                }
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }
}