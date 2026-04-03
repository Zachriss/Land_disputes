import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/colors.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  final UserModel currentUser;
  final String currentPage;

  const AppDrawer({
    super.key,
    required this.currentUser,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header with User Info
          UserAccountsDrawerHeader(
            accountName: Text(
              currentUser.fullName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              currentUser.email,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                currentUser.fullName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
            ),
            otherAccountsPictures: [
              Chip(
                label: Text(
                  currentUser.role.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: Colors.white,
              ),
            ],
          ),

          // Menu Items based on User Role
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                if (currentUser.role == UserRole.citizen)
                  ..._buildCitizenMenu(context),
                if (currentUser.role == UserRole.officer)
                  ..._buildOfficerMenu(context),
                if (currentUser.role == UserRole.mediator)
                  ..._buildMediatorMenu(context),
                if (currentUser.role == UserRole.admin)
                  ..._buildAdminMenu(context),
                
                const Divider(),
                
                // Common items for all roles
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  selected: currentPage == 'profile',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to profile screen
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.logout_outlined, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Citizen Menu Items
  List<Widget> _buildCitizenMenu(BuildContext context) {
    return [
      ListTile(
        leading: const Icon(Icons.dashboard_outlined),
        title: const Text('Dashboard'),
        selected: currentPage == 'dashboard',
        onTap: () {
          Navigator.pop(context);
          if (currentPage != 'dashboard') {
            Navigator.pushReplacementNamed(context, AppRoutes.citizenDashboard);
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.report_problem_outlined),
        title: const Text('Report Dispute'),
        selected: currentPage == 'report',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.reportDispute);
        },
      ),
      ListTile(
        leading: const Icon(Icons.list_alt_outlined),
        title: const Text('My Cases'),
        selected: currentPage == 'cases',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.myCases);
        },
      ),
      ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: const Text('Notifications'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    ];
  }

  // Land Officer Menu Items
  List<Widget> _buildOfficerMenu(BuildContext context) {
    return [
      ListTile(
        leading: const Icon(Icons.dashboard_outlined),
        title: const Text('Dashboard'),
        selected: currentPage == 'dashboard',
        onTap: () {
          Navigator.pop(context);
          if (currentPage != 'dashboard') {
            Navigator.pushReplacementNamed(context, AppRoutes.officerDashboard);
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.description_outlined),
        title: const Text('All Disputes'),
        selected: currentPage == 'disputes',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.allDisputes);
        },
      ),
      ListTile(
        leading: const Icon(Icons.assignment_ind_outlined),
        title: const Text('Assign Mediators'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.bar_chart_outlined),
        title: const Text('Reports & Statistics'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    ];
  }

  // Mediator Menu Items
  List<Widget> _buildMediatorMenu(BuildContext context) {
    return [
      ListTile(
        leading: const Icon(Icons.dashboard_outlined),
        title: const Text('Dashboard'),
        selected: currentPage == 'dashboard',
        onTap: () {
          Navigator.pop(context);
          if (currentPage != 'dashboard') {
            Navigator.pushReplacementNamed(context, AppRoutes.mediatorDashboard);
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.assignment_turned_in_outlined),
        title: const Text('Assigned Cases'),
        selected: currentPage == 'cases',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.assignedCases);
        },
      ),
      ListTile(
        leading: const Icon(Icons.calendar_month_outlined),
        title: const Text('Schedule Meetings'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.note_add_outlined),
        title: const Text('Case Notes'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    ];
  }

  // Admin Menu Items
  List<Widget> _buildAdminMenu(BuildContext context) {
    return [
      ListTile(
        leading: const Icon(Icons.dashboard_outlined),
        title: const Text('Dashboard'),
        selected: currentPage == 'dashboard',
        onTap: () {
          Navigator.pop(context);
          if (currentPage != 'dashboard') {
            Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.people_outline),
        title: const Text('Manage Users'),
        selected: currentPage == 'users',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.manageUsers);
        },
      ),
      ListTile(
        leading: const Icon(Icons.verified_user_outlined),
        title: const Text('Assign Roles'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.folder_copy_outlined),
        title: const Text('All Disputes'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.backup_outlined),
        title: const Text('Backup & Restore'),
        selected: currentPage == 'backup',
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.backup);
        },
      ),
      ListTile(
        leading: const Icon(Icons.history_outlined),
        title: const Text('Activity Logs'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.admin_panel_settings_outlined),
        title: const Text('System Settings'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    ];
  }
}