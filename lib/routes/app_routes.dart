/// Named routes and route generator for the app

import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/citizen/citizen_dashboard.dart';
import '../screens/citizen/report_dispute_screen.dart';
import '../screens/citizen/my_cases_screen.dart';
import '../screens/officer/officer_dashboard.dart';
import '../screens/officer/all_disputes_screen.dart';
import '../screens/officer/update_status_screen.dart';
import '../screens/mediator/mediator_dashboard.dart';
import '../screens/mediator/assigned_cases_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/manage_users_screen.dart';
import '../screens/admin/backup_screen.dart';

class AppRoutes {
  // Route names
  static const String login = '/login';
  static const String register = '/register';
  
  // Citizen routes
  static const String citizenDashboard = '/citizen/dashboard';
  static const String reportDispute = '/citizen/report';
  static const String myCases = '/citizen/cases';
  
  // Officer routes
  static const String officerDashboard = '/officer/dashboard';
  static const String allDisputes = '/officer/disputes';
  static const String updateStatus = '/officer/update';
  
  // Mediator routes
  static const String mediatorDashboard = '/mediator/dashboard';
  static const String assignedCases = '/mediator/cases';
  
  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String manageUsers = '/admin/users';
  static const String backup = '/admin/backup';

  // Route generator
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case citizenDashboard:
        return MaterialPageRoute(builder: (_) => const CitizenDashboard());
      case reportDispute:
        return MaterialPageRoute(builder: (_) => const ReportDisputeScreen());
      case myCases:
        return MaterialPageRoute(builder: (_) => const MyCasesScreen());
      case officerDashboard:
        return MaterialPageRoute(builder: (_) => const OfficerDashboard());
      case allDisputes:
        return MaterialPageRoute(builder: (_) => const AllDisputesScreen());
      case updateStatus:
        return MaterialPageRoute(builder: (_) => const UpdateStatusScreen());
      case mediatorDashboard:
        return MaterialPageRoute(builder: (_) => const MediatorDashboard());
      case assignedCases:
        return MaterialPageRoute(builder: (_) => const AssignedCasesScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case manageUsers:
        return MaterialPageRoute(builder: (_) => const ManageUsersScreen());
      case backup:
        return MaterialPageRoute(builder: (_) => const BackupScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}