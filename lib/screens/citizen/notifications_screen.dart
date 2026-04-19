import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../constants/colors.dart';
import '../../constants/firebase_consts.dart';
import '../../services/notification_service.dart';
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;
  String? _selectedNotificationId;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.userUid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => _markAllAsRead(userId),
            child: const Text(
              'Mark all read',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: Text('Please login to view notifications'))
          : Stack(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(FirebaseConsts.notificationsCollection)
                      .where('userId', isEqualTo: userId)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No notifications'));
                    }

                    final notifications = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        final data = notification.data() as Map<String, dynamic>;
                        final isRead = data['read'] ?? false;

                        return Card(
                          elevation: isRead ? 1 : 3,
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isRead ? null : AppColors.primaryColor.withOpacity(0.05),
                          child: ListTile(
                            leading: _buildNotificationIcon(data['type']),
                            title: Text(
                              data['title'] ?? '',
                              style: TextStyle(
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(data['body'] ?? ''),
                            trailing: isRead ? null : const Icon(Icons.circle, color: AppColors.primaryColor, size: 10),
                            onTap: () => _handleNotificationTap(notification),
                          ),
                        );
                      },
                    );
                  },
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }
  Icon _buildNotificationIcon(String? type) {
    switch (type) {
      case 'status_update':
        return const Icon(Icons.update, color: AppColors.infoColor);
      case 'resolved':
        return const Icon(Icons.check_circle, color: AppColors.successColor);
      case 'mediator_assigned':
        return const Icon(Icons.person, color: AppColors.primaryColor);
      case 'rejected':
        return const Icon(Icons.cancel, color: AppColors.errorColor);
      default:
        return const Icon(Icons.notifications, color: AppColors.primaryColor);
    }
  }

  void _handleNotificationTap(QueryDocumentSnapshot notification) async {
    try {
      setState(() {
        _isLoading = true;
        _selectedNotificationId = notification.id;
      });

      await notification.reference.update({'read': true});

      // Navigate to notification details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationDetailsScreen(
            notification: notification,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _selectedNotificationId = null;
      });
    }
  }
  Future<void> _markAllAsRead(String? userId) async {
    if (userId == null) return;
    
    final batch = FirebaseFirestore.instance.batch();
    final query = await FirebaseFirestore.instance
        .collection(FirebaseConsts.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    for (final doc in query.docs) {
      batch.update(doc.reference, {'read': true});
    }

    await batch.commit();
  }
}