import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dispute_provider.dart';
import '../../models/dispute_model.dart';
import '../../models/user_model.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../constants/firebase_consts.dart';
import '../../widgets/dispute_card.dart';
import '../../widgets/app_drawer.dart';
import '../auth/login_screen.dart';
import 'report_dispute_screen.dart';
import 'my_cases_screen.dart';
import 'notifications_screen.dart';
import 'citizen_profile_screen.dart';
import 'view_notices_screen.dart';
import 'view_meetings_screen.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  int _currentIndex = 0;
  int _unreadNotificationsCount = 0;
  StreamSubscription? _notificationsSubscription;
  
  final List<Widget> _screens = [
    const _DashboardHome(),
    const MyCasesScreen(),
    const ReportDisputeScreen(),
    const ViewMeetingsScreen(),
    const ViewNoticesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Delay data loading until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDisputes();
      _setupUnreadNotificationsListener();
    });
  }

  void _loadDisputes() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final disputeProvider = Provider.of<DisputeProvider>(context, listen: false);
    if (authProvider.userUid != null) {
      disputeProvider.loadDisputesByUser(authProvider.userUid!);
    }
  }

  void _setupUnreadNotificationsListener() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userUid;
    
    if (userId == null) return;
    
    _notificationsSubscription = FirebaseFirestore.instance
        .collection(FirebaseConsts.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
          if (mounted) {
            setState(() {
              _unreadNotificationsCount = snapshot.docs.length;
            });
          }
        });
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    UserModel? currentUser = authProvider.currentUser;

    return Scaffold(
      drawer: currentUser != null 
          ? AppDrawer(currentUser: currentUser, currentPage: 'dashboard') 
          : null,
      appBar: AppBar(
        title: const Text('Citizen'),
        toolbarHeight: 56,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Open Menu',
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                },
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _unreadNotificationsCount > 99 ? '99+' : _unreadNotificationsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CitizenProfileScreen()));
            },
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CitizenProfileScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: currentUser?.profilePictureUrl != null && currentUser!.profilePictureUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          currentUser!.profilePictureUrl!,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        currentUser?.fullName.isNotEmpty == true
                            ? currentUser!.fullName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.textLight,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: AppStrings.myCases,
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Report Dispute',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Meetings',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.announcement),
              label: 'Notices',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final disputeProvider = Provider.of<DisputeProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Citizen Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
             shrinkWrap: true,
             physics: const NeverScrollableScrollPhysics(),
             crossAxisCount: 2,
             crossAxisSpacing: 16,
             mainAxisSpacing: 16,
             childAspectRatio: 1.75,
            children: [
              _StatCard(
                title: 'Pending',
                count: disputeProvider.disputes.where((d) => d.status == DisputeStatus.pending).length,
                color: AppColors.warningColor,
                icon: Icons.hourglass_top,
              ),
              _StatCard(
                title: 'In Progress',
                count: disputeProvider.disputes.where((d) => d.status == DisputeStatus.inProgress).length,
                color: AppColors.infoColor,
                icon: Icons.pending,
              ),
              _StatCard(
                title: 'Resolved',
                count: disputeProvider.disputes.where((d) => d.status == DisputeStatus.resolved).length,
                color: AppColors.successColor,
                icon: Icons.check_circle,
              ),
              _StatCard(
                title: 'Total Cases',
                count: disputeProvider.disputes.length,
                color: AppColors.primaryColor,
                icon: Icons.description,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Disputes
          const Text(
            'Recent Disputes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Consumer<DisputeProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.disputes.isEmpty) {
                return const Center(
                  child: Text('No disputes found. Tap + to report one.'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.disputes.length > 5 ? 5 : provider.disputes.length,
                itemBuilder: (context, index) {
                  return DisputeCard(
                    dispute: provider.disputes[index],
                    onTap: () {
                      // Navigate to dispute details
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}