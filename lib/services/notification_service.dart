/// Notification Service for sending push notifications to users
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dispute_model.dart';
import '../models/user_model.dart';
import '../constants/firebase_consts.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send notification to a specific user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String disputeId,
    String? type,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConsts.notificationsCollection)
          .add({
        'userId': userId,
        'title': title,
        'body': body,
        'disputeId': disputeId,
        'type': type ?? 'general',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to send notification: $e';
    }
  }

  // Send notification when dispute status is updated
  Future<void> sendDisputeStatusUpdateNotification(DisputeModel dispute, String newStatus) async {
    try {
      // Send to Citizen who submitted the dispute
      if (dispute.submittedBy != null && dispute.submittedBy!.isNotEmpty) {
        await sendNotification(
          userId: dispute.submittedBy!,
          title: 'Dispute Status Updated',
          body: 'Your dispute "${dispute.title}" has been updated to status: $newStatus',
          disputeId: dispute.id!,
          type: 'status_update',
        );
      }

      // Send to assigned Mediator if exists
      if (dispute.assignedMediatorId != null && dispute.assignedMediatorId!.isNotEmpty) {
        await sendNotification(
          userId: dispute.assignedMediatorId!,
          title: 'Dispute Status Updated',
          body: 'Dispute "${dispute.title}" you are assigned to has been updated to status: $newStatus',
          disputeId: dispute.id!,
          type: 'status_update',
        );
      }
    } catch (e) {
      throw 'Failed to send status update notifications: $e';
    }
  }

  // Send notification when dispute is resolved
  Future<void> sendDisputeResolvedNotification(DisputeModel dispute) async {
    try {
      // Send to Citizen
      if (dispute.submittedBy != null && dispute.submittedBy!.isNotEmpty) {
        await sendNotification(
          userId: dispute.submittedBy!,
          title: 'Dispute Resolved',
          body: 'Great news! Your dispute "${dispute.title}" has been resolved.',
          disputeId: dispute.id!,
          type: 'resolved',
        );
      }

      // Send to Mediator
      if (dispute.assignedMediatorId != null && dispute.assignedMediatorId!.isNotEmpty) {
        await sendNotification(
          userId: dispute.assignedMediatorId!,
          title: 'Dispute Resolved',
          body: 'Dispute "${dispute.title}" has been successfully resolved.',
          disputeId: dispute.id!,
          type: 'resolved',
        );
      }
    } catch (e) {
      throw 'Failed to send resolved notifications: $e';
    }
  }

  // Send notification when mediator is assigned
  Future<void> sendMediatorAssignedNotification(DisputeModel dispute, UserModel mediator) async {
    try {
      // Send to Citizen
      if (dispute.submittedBy != null && dispute.submittedBy!.isNotEmpty) {
        await sendNotification(
          userId: dispute.submittedBy!,
          title: 'Mediator Assigned',
          body: 'Mediator ${mediator.fullName} has been assigned to your dispute "${dispute.title}"',
          disputeId: dispute.id!,
          type: 'mediator_assigned',
        );
      }

      // Send to Mediator
      if (mediator.id != null) {
        await sendNotification(
          userId: mediator.id!,
          title: 'New Dispute Assigned',
          body: 'You have been assigned as mediator for dispute "${dispute.title}"',
          disputeId: dispute.id!,
          type: 'new_assignment',
        );
      }
    } catch (e) {
      throw 'Failed to send mediator assignment notifications: $e';
    }
  }
}