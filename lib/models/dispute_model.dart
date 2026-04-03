/// Dispute model for the Land Disputes Management System

import 'package:cloud_firestore/cloud_firestore.dart';

enum DisputeStatus { pending, inProgress, resolved, rejected, onHold, closed }
enum DisputePriority { low, medium, high, urgent }
enum DisputeType { boundary, ownership, inheritance, lease, other }

class DisputeModel {
  final String? id;
  final String title;
  final String description;
  final String location;
  final String plotNumber;
  final DisputeType disputeType;
  final DisputePriority priority;
  final DisputeStatus status;
  final String submittedBy; // User ID
  final String? assignedOfficerId;
  final String? assignedMediatorId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final List<String> involvedParties; // User IDs
  final Map<String, dynamic>? additionalInfo;
  final bool isArchived;
  final List<String>? documentIds;

  DisputeModel({
    this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.plotNumber,
    this.disputeType = DisputeType.other,
    this.priority = DisputePriority.medium,
    this.status = DisputeStatus.pending,
    required this.submittedBy,
    this.assignedOfficerId,
    this.assignedMediatorId,
    DateTime? createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.involvedParties = const [],
    this.additionalInfo,
    this.isArchived = false,
    this.documentIds,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'plotNumber': plotNumber,
      'disputeType': _typeToString(disputeType),
      'priority': _priorityToString(priority),
      'status': _statusToString(status),
      'submittedBy': submittedBy,
      'assignedOfficerId': assignedOfficerId,
      'assignedMediatorId': assignedMediatorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'involvedParties': involvedParties,
      'additionalInfo': additionalInfo ?? {},
      'isArchived': isArchived,
      'documentIds': documentIds ?? [],
    };
  }

  factory DisputeModel.fromJson(String? id, Map<String, dynamic> json) {
    return DisputeModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      plotNumber: json['plotNumber'] ?? '',
      disputeType: _typeFromString(json['disputeType'] ?? 'other'),
      priority: _priorityFromString(json['priority'] ?? 'medium'),
      status: _statusFromString(json['status'] ?? 'pending'),
      submittedBy: json['submittedBy'] ?? '',
      assignedOfficerId: json['assignedOfficerId'],
      assignedMediatorId: json['assignedMediatorId'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      resolvedAt: (json['resolvedAt'] as Timestamp?)?.toDate(),
      involvedParties: List<String>.from(json['involvedParties'] ?? []),
      additionalInfo: json['additionalInfo'],
      isArchived: json['isArchived'] ?? false,
      documentIds: json['documentIds'] != null ? List<String>.from(json['documentIds']) : null,
    );
  }

  DisputeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? plotNumber,
    DisputeType? disputeType,
    DisputePriority? priority,
    DisputeStatus? status,
    String? submittedBy,
    String? assignedOfficerId,
    String? assignedMediatorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    List<String>? involvedParties,
    Map<String, dynamic>? additionalInfo,
    bool? isArchived,
    List<String>? documentIds,
  }) {
    return DisputeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      plotNumber: plotNumber ?? this.plotNumber,
      disputeType: disputeType ?? this.disputeType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      submittedBy: submittedBy ?? this.submittedBy,
      assignedOfficerId: assignedOfficerId ?? this.assignedOfficerId,
      assignedMediatorId: assignedMediatorId ?? this.assignedMediatorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      involvedParties: involvedParties ?? this.involvedParties,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      isArchived: isArchived ?? this.isArchived,
      documentIds: documentIds ?? this.documentIds,
    );
  }

  static String _statusToString(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending:
        return 'pending';
      case DisputeStatus.inProgress:
        return 'in_progress';
      case DisputeStatus.resolved:
        return 'resolved';
      case DisputeStatus.rejected:
        return 'rejected';
      case DisputeStatus.onHold:
        return 'on_hold';
      case DisputeStatus.closed:
        return 'closed';
    }
  }

  static DisputeStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return DisputeStatus.pending;
      case 'in_progress':
        return DisputeStatus.inProgress;
      case 'resolved':
        return DisputeStatus.resolved;
      case 'rejected':
        return DisputeStatus.rejected;
      case 'on_hold':
        return DisputeStatus.onHold;
      case 'closed':
        return DisputeStatus.closed;
      default:
        return DisputeStatus.pending;
    }
  }

  static String _priorityToString(DisputePriority priority) {
    switch (priority) {
      case DisputePriority.low:
        return 'low';
      case DisputePriority.medium:
        return 'medium';
      case DisputePriority.high:
        return 'high';
      case DisputePriority.urgent:
        return 'urgent';
    }
  }

  static DisputePriority _priorityFromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return DisputePriority.low;
      case 'medium':
        return DisputePriority.medium;
      case 'high':
        return DisputePriority.high;
      case 'urgent':
        return DisputePriority.urgent;
      default:
        return DisputePriority.medium;
    }
  }

  static String _typeToString(DisputeType type) {
    switch (type) {
      case DisputeType.boundary:
        return 'boundary';
      case DisputeType.ownership:
        return 'ownership';
      case DisputeType.inheritance:
        return 'inheritance';
      case DisputeType.lease:
        return 'lease';
      case DisputeType.other:
        return 'other';
    }
  }

  static DisputeType _typeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'boundary':
        return DisputeType.boundary;
      case 'ownership':
        return DisputeType.ownership;
      case 'inheritance':
        return DisputeType.inheritance;
      case 'lease':
        return DisputeType.lease;
      case 'other':
      default:
        return DisputeType.other;
    }
  }

  @override
  String toString() {
    return 'DisputeModel(id: $id, title: $title, status: $status, priority: $priority)';
  }
}