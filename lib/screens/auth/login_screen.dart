import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';
import '../citizen/citizen_dashboard.dart';
import '../officer/officer_dashboard.dart';
import '../mediator/mediator_dashboard.dart';
import '../admin/admin_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Get user data from Firestore
      UserService userService = UserService();
      UserModel? user = await userService.getUserById(userCredential.user!.uid);

      if (!mounted) return;
      Navigator.of(context).pop(); // hide loading

      if (user != null) {
        // Navigate to correct dashboard based on user role
        Widget dashboard;
        switch (user.role) {
          case UserRole.citizen:
            dashboard = const CitizenDashboard();
            break;
          case UserRole.officer:
            dashboard = const OfficerDashboard();
            break;
          case UserRole.mediator:
            dashboard = const MediatorDashboard();
            break;
          case UserRole.admin:
            dashboard = const AdminDashboard();
            break;
        }
        
        if (!mounted) return;
        
        // Navigate using named routes which work properly with Provider scope
        String route;
        switch (user.role) {
          case UserRole.citizen:
            route = AppRoutes.citizenDashboard;
            break;
          case UserRole.officer:
            route = AppRoutes.officerDashboard;
            break;
          case UserRole.mediator:
            route = AppRoutes.mediatorDashboard;
            break;
          case UserRole.admin:
            route = AppRoutes.adminDashboard;
            break;
        }
        
        Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data not found'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // hide loading
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.errorColor,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // hide loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                AppStrings.login,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _emailController,
                label: AppStrings.email,
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _passwordController,
                label: AppStrings.password,
                hintText: 'Enter password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textLight,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: AppStrings.login,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text(AppStrings.register),
              ),
            ],
          ),
        ),
      ),
    );
  }
}