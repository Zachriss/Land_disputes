/// Navigation helper functions

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/citizen/citizen_dashboard.dart';
import '../screens/officer/officer_dashboard.dart';
import '../screens/mediator/mediator_dashboard.dart';
import '../screens/admin/admin_dashboard.dart';

class Navigation {
  // Navigate based on user role after login
  static void navigateToDashboard(BuildContext context, UserRole role) {
    Widget screen;
    switch (role) {
      case UserRole.citizen:
        screen = const CitizenDashboard();
        break;
      case UserRole.officer:
        screen = const OfficerDashboard();
        break;
      case UserRole.mediator:
        screen = const MediatorDashboard();
        break;
      case UserRole.admin:
        screen = const AdminDashboard();
        break;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }

  // Navigate to login screen
  static void navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // Push replacement
  static void pushReplacement(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // Push new screen
  static void push(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // Pop current screen
  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}