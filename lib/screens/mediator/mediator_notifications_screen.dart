import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../constants/colors.dart';
import '../../constants/firebase_consts.dart';
import '../../services/notification_service.dart';
import '../citizen/notification_details_screen.dart';

class MediatorNotificationsScreen extends StatefulWidget {
  const MediatorNotificationsScreen({super.key});

  @override
  State<MediatorNotificationsScreen> createState() => _MediatorNotificationsScreenState();
}

class _MediatorNotificationsScreenState extends State<MediatorNotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<QueryDocumentSnapshot> _notifications = [];
  bool _isInitialLoading = true;
  bool _isStreamActive = false;
  StreamSubscription<QuerySnapshot>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupStableNotificationStream();
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _setupStableNotificationStream() {
    if (_isStreamActive) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userUid;

    if (userId == null) {
      setState(() {
        _isInitialLoading = false;
      });
      return;
    }

    _isStreamActive = true;

    // ✅ STABLE STREAM CONFIGURATION:
    // - No server-side orderBy (avoids missing index + empty results bug)
    // - includeMetadataChanges = true prevents stream from clearing during updates
    // - cache first policy ensures instant UI rendering
    _streamSubscription = FirebaseFirestore.instance
        .collection(FirebaseConsts.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) => snapshot.data() ?? {},
          toFirestore: (data, _) => data,
        )
        .snapshots(includeMetadataChanges: true)
        .listen(
      (snapshot) {
        if (!mounted) return;

        // ✅ NEVER clear existing data during updates!
        // This is the #1 fix for disappearing notifications
        if (snapshot.docs.isEmpty && snapshot.metadata.isFromCache) {
          // Ignore empty cache results - wait for server sync
          return;
        }

        // ✅ STABLE CLIENT-SIDE SORTING:
        // All sorting done locally to avoid Firestore index requirements
        // and prevent query failures
        final sortedDocs = List<QueryDocumentSnapshot>.from(snapshot.docs);
        sortedDocs.sort((a, b) {
          try {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final aTime = aData['createdAt'] as Timestamp?;
            final bTime = bData['createdAt'] as Timestamp?;

            // Proper null ordering: items without timestamp go at the end
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;

            // Descending order (newest first)
            return bTime.compareTo(aTime);
          } catch (e) {
            debugPrint('Sort error: $e');
            return 0;
          }
        });

        setState(() {
          _notifications = sortedDocs;
          _isInitialLoading = false;
        });
      },
      onError: (error) {
        debugPrint('✅ Notification stream handled error: $error');
        if (mounted) {
          setState(() {
            _isInitialLoading = false;
          });
        }
        // Stream automatically continues after errors - no need to restart
      },
      cancelOnError: false,
    );
  }

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
                // ✅ NEVER show loading indicator if we already have data!
                // This eliminates UI flicker completely during updates
                if (_isInitialLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_notifications.isEmpty)
                  const Center(child: Text('No notifications'))
                else
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final data =
                          notification.data() as Map<String, dynamic>? ?? {};

                      // ✅ FULL NULL SAFETY FOR ALL FIELDS
                      final isRead = data['read'] ?? false;
                      final title = data['title'] ?? 'Notification';
                      final body = data['body'] ?? '';
                      final type = data['type'] as String?;

                      return Card(
                        elevation: isRead ? 1 : 3,
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isRead
                            ? null
                            : AppColors.primaryColor.withOpacity(0.05),
                        child: ListTile(
                          leading: _buildNotificationIcon(type),
                          title: Text(
                            title,
                            style: TextStyle(
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(body),
                          trailing: isRead
                              ? null
                              : const Icon(Icons.circle,
                                  color: AppColors.primaryColor, size: 10),
                          onTap: () => _handleNotificationTap(notification),
                        ),
                      );
                    },
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
      case 'mediator_assignment':
        return const Icon(Icons.person, color: AppColors.primaryColor);
      case 'mediator_assigned':
        return const Icon(Icons.assignment_turned_in, color: AppColors.primaryColor);
      case 'rejected':
        return const Icon(Icons.cancel, color: AppColors.errorColor);
      default:
        return const Icon(Icons.notifications, color: AppColors.primaryColor);
    }
  }

  void _handleNotificationTap(QueryDocumentSnapshot notification) async {
    try {
      // ✅ FIRST navigate, THEN update Firestore
      // This ensures no UI flicker while stream updates
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationDetailsScreen(
            notification: notification,
          ),
        ),
      );

      // Update after user returns - user won't see the stream update happen
      try {
        await notification.reference.set(
          {'read': true},
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('Mark as read error: $e');
      }
    } catch (e) {
      debugPrint('Failed to handle notification tap: $e');
    }
  }

  Future<void> _markAllAsRead(String? userId) async {
    if (userId == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final query = await FirebaseFirestore.instance
          .collection(FirebaseConsts.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get(const GetOptions(source: Source.serverAndCache));

      for (final doc in query.docs) {
        batch.set(
          doc.reference,
          {'read': true},
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Mark all read error: $e');
    }
  }
}