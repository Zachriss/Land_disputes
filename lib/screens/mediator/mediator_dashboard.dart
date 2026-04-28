import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dispute_provider.dart';
import '../../models/dispute_model.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../constants/firebase_consts.dart';
import '../../widgets/dispute_card.dart';
import '../../widgets/app_drawer.dart';
import '../auth/login_screen.dart';
import 'assigned_cases_screen.dart';
import 'mediator_reports_screen.dart';
import 'mediator_notifications_screen.dart';
import 'mediator_profile_screen.dart';
import 'schedule_meeting_screen.dart';
import 'case_notice_screen.dart';
import 'mediator_settings_screen.dart';

class MediatorDashboard extends StatefulWidget {
  const MediatorDashboard({super.key});

  @override
  State<MediatorDashboard> createState() => _MediatorDashboardState();
}

class _MediatorDashboardState extends State<MediatorDashboard> {
  int _currentIndex = 0;
  int _unreadNotificationsCount = 0;
  StreamSubscription<QuerySnapshot>? _notificationStreamSubscription;

  final List<Widget> _screens = [
    const _DashboardHome(),
    const AssignedCasesScreen(),
    const MediatorReportsScreen(),
    const ScheduleMeetingScreen(),
    const CaseNoticeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Delay data loading until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDisputes();
      _setupNotificationBadgeStream();
    });
  }

  @override
  void dispose() {
    _notificationStreamSubscription?.cancel();
    super.dispose();
  }

  void _setupNotificationBadgeStream() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userUid;
    
    if (userId == null) return;

    _notificationStreamSubscription = FirebaseFirestore.instance
        .collection(FirebaseConsts.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
          if (!mounted) return;
          setState(() {
            _unreadNotificationsCount = snapshot.docs.length;
          });
        });
  }

  void _loadDisputes() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final disputeProvider = Provider.of<DisputeProvider>(context, listen: false);
    if (authProvider.userUid != null) {
      disputeProvider.loadDisputesByMediator(authProvider.userUid!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      drawer: currentUser != null
          ? AppDrawer(currentUser: currentUser, currentPage: 'dashboard')
          : null,
      appBar: AppBar(
        title: const Text('Mediator'),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MediatorNotificationsScreen()));
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MediatorSettingsScreen()));
            },
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MediatorProfileScreen()));
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
                            : 'M',
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
        elevation: 0,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.textLight,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in),
              label: 'Assigned Cases',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Reports',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.schedule),
              label: 'Schedule Meeting',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.announcement),
              label: 'Case Notice',
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
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final disputeProvider = Provider.of<DisputeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mediator Overview',
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
              childAspectRatio: 1.9,
            children: [
              _StatCard(
                title: 'Assigned Cases',
                count: disputeProvider.disputes.length,
                color: AppColors.primaryColor,
                icon: Icons.assignment_turned_in,
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
                title: 'Unresolved',
                count: disputeProvider.disputes.where((d) => d.status == DisputeStatus.onHold).length,
                color: AppColors.errorColor,
                icon: Icons.cancel,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Assigned Disputes
          const Text(
            'Recent Assigned Cases',
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
                  child: Text('No cases assigned to you yet.'),
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
      child: Padding(
         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
         child: Wrap(
           direction: Axis.vertical,
           alignment: WrapAlignment.center,
           crossAxisAlignment: WrapCrossAlignment.center,
           spacing: 2,
           children: [
             Icon(icon, color: color, size: 26),
             Text(
               count.toString(),
               style: TextStyle(
                 fontSize: 19,
                 fontWeight: FontWeight.bold,
                 color: color,
               ),
             ),
             Text(
               title,
               textAlign: TextAlign.center,
               style: const TextStyle(
                 fontSize: 11,
                 color: AppColors.textLight,
               ),
             ),
           ],
         ),
      ),
    );
  }
}