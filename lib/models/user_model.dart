import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles for users in the system
enum UserRole { citizen, officer, mediator, admin }

/// UserModel for Land Disputes Management System
class UserModel {
  final String? id; // Firestore document ID (same as Firebase UID)
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? nationalId;
  final UserRole role;
  final String? address;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? profilePictureUrl;
  final Map<String, dynamic>? metadata;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.nationalId,
    this.role = UserRole.citizen,
    this.address,
    DateTime? createdAt,
    this.updatedAt,
    this.isActive = true,
    this.profilePictureUrl,
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'nationalId': nationalId,
      'role': _roleToString(role),
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'isActive': isActive,
      'profilePictureUrl': profilePictureUrl,
      'metadata': metadata ?? {},
    };
  }

  /// Alias for toJson() for compatibility
  Map<String, dynamic> toMap() => toJson();

  /// Create UserModel from Firestore JSON
  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    return UserModel(
      id: id,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      nationalId: json['nationalId'],
      role: _roleFromString(json['role'] ?? 'citizen'),
      address: json['address'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      isActive: json['isActive'] ?? true,
      profilePictureUrl: json['profilePictureUrl'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// Copy with method for updates
  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? nationalId,
    UserRole? role,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? profilePictureUrl,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nationalId: nationalId ?? this.nationalId,
      role: role ?? this.role,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert role enum to string
  static String _roleToString(UserRole role) {
    return role.name; // Dart >= 2.15 supports enum.name
  }

  /// Convert string to role enum
  static UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'officer':
        return UserRole.officer;
      case 'mediator':
        return UserRole.mediator;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.citizen;
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UserModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}