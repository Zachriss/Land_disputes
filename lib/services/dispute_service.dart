/// Dispute service for managing disputes in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dispute_model.dart';
import '../constants/firebase_consts.dart';

class DisputeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get dispute by ID
  Future<DisputeModel?> getDisputeById(String disputeId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConsts.disputesCollection)
          .doc(disputeId)
          .get();
      
      if (doc.exists) {
        return DisputeModel.fromJson(disputeId, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to get dispute: $e';
    }
  }

  // Get all disputes
  Future<List<DisputeModel>> getAllDisputes() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConsts.disputesCollection)
          .orderBy(FirebaseConsts.defaultOrderBy, descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        return DisputeModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to get disputes: $e';
    }
  }

  // Get disputes by status
  Future<List<DisputeModel>> getDisputesByStatus(DisputeStatus status) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConsts.disputesCollection)
          .where('status', isEqualTo: _statusToString(status))
          .orderBy(FirebaseConsts.defaultOrderBy, descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        return DisputeModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to get disputes by status: $e';
    }
  }

  // Get disputes by priority
  Future<List<DisputeModel>> getDisputesByPriority(DisputePriority priority) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConsts.disputesCollection)
          .where('priority', isEqualTo: _priorityToString(priority))
          .orderBy(FirebaseConsts.defaultOrderBy, descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        return DisputeModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to get disputes by priority: $e';
    }
  }

  // Get disputes by submitted by (user ID)
  Future<List<DisputeModel>> getDisputesByUser(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConsts.disputesCollection)
          .where('submittedBy', isEqualTo: userId)
          .orderBy(FirebaseConsts.defaultOrderBy, descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        return DisputeModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to get disputes by user: $e';
    }
  }

  // Get disputes assigned to officer
  Future<List<DisputeModel>> getDisputesByOfficer(String officerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConsts.disputesCollection)
          .where('assignedOfficerId', isEqualTo: officerId)
          .orderBy(FirebaseConsts.defaultOrderBy, descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        return DisputeModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to get disputes by officer: $e';
    }
  }

  // Get disputes assigned to mediator
  Future<List<DisputeModel>> getDisputesByMediator(String mediatorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConsts.disputesCollection)
          .where('assignedMediatorId', isEqualTo: mediatorId)
          .orderBy(FirebaseConsts.defaultOrderBy, descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        return DisputeModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to get disputes by mediator: $e';
    }
  }

  // Submit new dispute
  Future<String?> submitDispute(DisputeModel dispute) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(FirebaseConsts.disputesCollection)
          .add(dispute.toJson());
      return docRef.id;
    } catch (e) {
      throw 'Failed to submit dispute: $e';
    }
  }

  // Update dispute
  Future<void> updateDispute(String disputeId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(FirebaseConsts.disputesCollection)
          .doc(disputeId)
          .update({
            ...data,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw 'Failed to update dispute: $e';
    }
  }

  // Update dispute status
  Future<void> updateDisputeStatus(String disputeId, DisputeStatus status) async {
    try {
      Map<String, dynamic> data = {
        'status': _statusToString(status),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Set resolvedAt if status is resolved or closed
      if (status == DisputeStatus.resolved || status == DisputeStatus.closed) {
        data['resolvedAt'] = FieldValue.serverTimestamp();
      }
      
      await _firestore
          .collection(FirebaseConsts.disputesCollection)
          .doc(disputeId)
          .update(data);
    } catch (e) {
      throw 'Failed to update dispute status: $e';
    }
  }

  // Assign officer to dispute
  Future<void> assignOfficer(String disputeId, String officerId) async {
    try {
      await _firestore
          .collection(FirebaseConsts.disputesCollection)
          .doc(disputeId)
          .update({
            'assignedOfficerId': officerId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw 'Failed to assign officer: $e';
    }
  }

  // Assign mediator to dispute
  Future<void> assignMediator(String disputeId, String mediatorId) async {
    try {
      await _firestore
          .collection(FirebaseConsts.disputesCollection)
          .doc(disputeId)
          .update({
            'assignedMediatorId': mediatorId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw 'Failed to assign mediator: $e';
    }
  }

  // Delete dispute
  Future<void> deleteDispute(String disputeId) async {
    try {
      await _firestore
          .collection(FirebaseConsts.disputesCollection)
          .doc(disputeId)
          .delete();
    } catch (e) {
      throw 'Failed to delete dispute: $e';
    }
  }

  // Stream of all disputes
  Stream<List<DisputeModel>> disputesStream() {
    return _firestore
        .collection(FirebaseConsts.disputesCollection)
        .orderBy(FirebaseConsts.defaultOrderBy, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DisputeModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Helper methods
  String _statusToString(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending: return 'pending';
      case DisputeStatus.inProgress: return 'in_progress';
      case DisputeStatus.resolved: return 'resolved';
      case DisputeStatus.rejected: return 'rejected';
      case DisputeStatus.onHold: return 'on_hold';
      case DisputeStatus.closed: return 'closed';
    }
  }

  String _priorityToString(DisputePriority priority) {
    switch (priority) {
      case DisputePriority.low: return 'low';
      case DisputePriority.medium: return 'medium';
      case DisputePriority.high: return 'high';
      case DisputePriority.urgent: return 'urgent';
    }
  }

  String _typeToString(DisputeType type) {
    switch (type) {
      case DisputeType.boundary: return 'boundary';
      case DisputeType.ownership: return 'ownership';
      case DisputeType.inheritance: return 'inheritance';
      case DisputeType.lease: return 'lease';
      case DisputeType.other: return 'other';
    }
  }
}