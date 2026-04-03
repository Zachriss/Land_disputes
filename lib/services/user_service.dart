/// User service for managing user data in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../constants/firebase_consts.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConsts.usersCollection)
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return UserModel.fromJson(userId, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user: $e';
    }
  }

  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConsts.usersCollection)
          .get();
      
      return snapshot.docs.map((doc) {
        return UserModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to get users: $e';
    }
  }

  // Get users by role
  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConsts.usersCollection)
          .where('role', isEqualTo: _roleToString(role))
          .get();
      
      return snapshot.docs.map((doc) {
        return UserModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to get users by role: $e';
    }
  }

  // Get active users
  Future<List<UserModel>> getActiveUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConsts.usersCollection)
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs.map((doc) {
        return UserModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to get active users: $e';
    }
  }

  // Create new user
  Future<String?> createUser(UserModel user) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(FirebaseConsts.usersCollection)
          .add(user.toJson());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create user: $e';
    }
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(FirebaseConsts.usersCollection)
          .doc(userId)
          .update({
            ...data,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw 'Failed to update user: $e';
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      await _firestore
          .collection(FirebaseConsts.usersCollection)
          .doc(userId)
          .update({
            'role': _roleToString(role),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw 'Failed to update role: $e';
    }
  }

  // Activate/deactivate user
  Future<void> setUserActiveStatus(String userId, bool isActive) async {
    try {
      await _firestore
          .collection(FirebaseConsts.usersCollection)
          .doc(userId)
          .update({
            'isActive': isActive,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw 'Failed to update user status: $e';
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(FirebaseConsts.usersCollection)
          .doc(userId)
          .delete();
    } catch (e) {
      throw 'Failed to delete user: $e';
    }
  }

  // Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConsts.usersCollection)
          .where('fullName', isGreaterThanOrEqualTo: query)
          .where('fullName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      
      return snapshot.docs.map((doc) {
        return UserModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to search users: $e';
    }
  }

  // Helper method to convert UserRole to string
  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.citizen:
        return 'citizen';
      case UserRole.officer:
        return 'officer';
      case UserRole.mediator:
        return 'mediator';
      case UserRole.admin:
        return 'admin';
    }
  }
}