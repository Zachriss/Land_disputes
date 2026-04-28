import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dispute_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/dispute_model.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
//import '../../widgets/dispute_card.dart';
import '../../widgets/app_drawer.dart';
import '../auth/login_screen.dart';
import 'manage_users_screen.dart';
import 'backup_screen.dart';
import 'all_disputes_screen.dart';
import 'activity_logs_screen.dart';
import 'admin_profile_screen.dart';
import 'admin_settings_screen.dart';
import '../citizen/notifications_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardHome(),
    const AllDisputesScreen(),
    const ManageUsersScreen(),
    const ActivityLogsScreen(),
    const BackupScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final disputeProvider = Provider.of<DisputeProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    disputeProvider.loadAllDisputes();
    userProvider.loadAllUsers();
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
        title: const Text('Admin'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Open Menu',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminSettingsScreen(),
                ),
              );
            },
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminProfileScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child:
                    currentUser?.profilePictureUrl != null &&
                        currentUser!.profilePictureUrl!.isNotEmpty
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
                            : 'A',
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
      bottomNavigationBar: SizedBox(
        height: kBottomNavigationBarHeight + 4,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.textLight,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10,
          unselectedFontSize: 9,
          iconSize: 20,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'Disputes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Users',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Logs'),
            BottomNavigationBarItem(icon: Icon(Icons.backup), label: 'Backup'),
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
    final userProvider = Provider.of<UserProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Administration Overview',
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
                title: 'Total Users',
                count: userProvider.users.length,
                color: AppColors.primaryColor,
                icon: Icons.people,
              ),
              _StatCard(
                title: 'Total Disputes',
                count: disputeProvider.disputes.length,
                color: AppColors.infoColor,
                icon: Icons.description,
              ),
              _StatCard(
                title: 'Pending',
                count: disputeProvider.disputes
                    .where((d) => d.status == DisputeStatus.pending)
                    .length,
                color: AppColors.warningColor,
                icon: Icons.hourglass_top,
              ),
              _StatCard(
                title: 'Resolved',
                count: disputeProvider.disputes
                    .where((d) => d.status == DisputeStatus.resolved)
                    .length,
                color: AppColors.successColor,
                icon: Icons.check_circle,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            child: Consumer<DisputeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.disputes.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final recent = provider.disputes.take(5).toList();
                if (recent.isEmpty) {
                  return const Center(
                    child: Text(
                      'No recent activity',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: recent.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final dispute = recent[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: _getStatusColor(dispute.status)
                            .withOpacity(0.1),
                        child: Icon(
                          Icons.description,
                          color: _getStatusColor(dispute.status),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        dispute.title ?? 'Untitled',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${_getStatusText(dispute.status)} • ${_formatDate(dispute.createdAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 16),
                      onTap: () {},
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
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

Color _getStatusColor(DisputeStatus status) {
  switch (status) {
    case DisputeStatus.pending:
      return AppColors.warningColor;
    case DisputeStatus.inProgress:
      return AppColors.infoColor;
    case DisputeStatus.resolved:
      return AppColors.successColor;
    case DisputeStatus.rejected:
      return AppColors.errorColor;
    case DisputeStatus.closed:
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

String _getStatusText(DisputeStatus status) {
  switch (status) {
    case DisputeStatus.pending:
      return 'Pending';
    case DisputeStatus.inProgress:
      return 'In Progress';
    case DisputeStatus.resolved:
      return 'Resolved';
    case DisputeStatus.rejected:
      return 'Rejected';
    case DisputeStatus.closed:
      return 'Closed';
    default:
      return 'Unknown';
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
