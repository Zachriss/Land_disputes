import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/colors.dart';
import '../../constants/firebase_consts.dart';
import '../../services/notification_service.dart';

class NotificationDetailsScreen extends StatefulWidget {
  final QueryDocumentSnapshot notification;

  const NotificationDetailsScreen({
    super.key,
    required this.notification,
  });

  @override
  State<NotificationDetailsScreen> createState() => _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  Future<void> _markAsRead() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await widget.notification.reference.update({'read': true});
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final data = widget.notification.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification Icon
                  Center(
                    child: _buildNotificationIcon(data['type']),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    data['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Body
                  Text(
                    data['body'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Metadata
                  Row(
                    children: [
                      Text(
                        'Dispute ID: ${data['disputeId'] ?? 'N/A'}',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(data['createdAt']),
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Actions
                  if (data['disputeId'] != null && data['disputeId']!.isNotEmpty)
                    ElevatedButton(
                      onPressed: () => _viewDisputeDetails(data['disputeId']!),
                      child: const Text('View Dispute Details'),
                    ),
                ],
              ),
            ),
    );
  }

  Icon _buildNotificationIcon(String? type) {
    switch (type) {
      case 'status_update':
        return const Icon(Icons.update, color: AppColors.infoColor, size: 48);
      case 'resolved':
        return const Icon(Icons.check_circle, color: AppColors.successColor, size: 48);
      case 'mediator_assigned':
        return const Icon(Icons.person, color: AppColors.primaryColor, size: 48);
      case 'rejected':
        return const Icon(Icons.cancel, color: AppColors.errorColor, size: 48);
      default:
        return const Icon(Icons.notifications, color: AppColors.primaryColor, size: 48);
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  void _viewDisputeDetails(String disputeId) {
    // Navigate to dispute details screen
    // This would require implementing dispute details navigation
    // For now, show a simple dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dispute Details'),
        content: Text('Dispute ID: $disputeId'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}