/// Document model for the Land Disputes Management System

import 'package:cloud_firestore/cloud_firestore.dart';

enum DocumentType { titleDeed, surveyPlan, idCard, agreement, courtOrder, photograph, other }

class DocumentModel {
  final String? id;
  final String disputeId;
  final String uploadedBy; // User ID
  final DocumentType documentType;
  final String fileName;
  final String fileUrl;
  final String? fileType;
  final int? fileSize;
  final String description;
  final DateTime createdAt;
  final bool isVerified;
  final String? verifiedBy;
  final DateTime? verifiedAt;

  DocumentModel({
    this.id,
    required this.disputeId,
    required this.uploadedBy,
    this.documentType = DocumentType.other,
    required this.fileName,
    required this.fileUrl,
    this.fileType,
    this.fileSize,
    this.description = '',
    DateTime? createdAt,
    this.isVerified = false,
    this.verifiedBy,
    this.verifiedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'disputeId': disputeId,
      'uploadedBy': uploadedBy,
      'documentType': _typeToString(documentType),
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSize': fileSize,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'isVerified': isVerified,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
    };
  }

  factory DocumentModel.fromJson(String? id, Map<String, dynamic> json) {
    return DocumentModel(
      id: id,
      disputeId: json['disputeId'] ?? '',
      uploadedBy: json['uploadedBy'] ?? '',
      documentType: _typeFromString(json['documentType'] ?? 'other'),
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileType: json['fileType'],
      fileSize: json['fileSize'],
      description: json['description'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: json['isVerified'] ?? false,
      verifiedBy: json['verifiedBy'],
      verifiedAt: (json['verifiedAt'] as Timestamp?)?.toDate(),
    );
  }

  DocumentModel copyWith({
    String? id,
    String? disputeId,
    String? uploadedBy,
    DocumentType? documentType,
    String? fileName,
    String? fileUrl,
    String? fileType,
    int? fileSize,
    String? description,
    DateTime? createdAt,
    bool? isVerified,
    String? verifiedBy,
    DateTime? verifiedAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      disputeId: disputeId ?? this.disputeId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      documentType: documentType ?? this.documentType,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  static String _typeToString(DocumentType type) {
    switch (type) {
      case DocumentType.titleDeed:
        return 'title_deed';
      case DocumentType.surveyPlan:
        return 'survey_plan';
      case DocumentType.idCard:
        return 'id_card';
      case DocumentType.agreement:
        return 'agreement';
      case DocumentType.courtOrder:
        return 'court_order';
      case DocumentType.photograph:
        return 'photograph';
      case DocumentType.other:
        return 'other';
    }
  }

  static DocumentType _typeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'title_deed':
        return DocumentType.titleDeed;
      case 'survey_plan':
        return DocumentType.surveyPlan;
      case 'id_card':
        return DocumentType.idCard;
      case 'agreement':
        return DocumentType.agreement;
      case 'court_order':
        return DocumentType.courtOrder;
      case 'photograph':
        return DocumentType.photograph;
      case 'other':
      default:
        return DocumentType.other;
    }
  }

  // Format file size for display
  String get formattedFileSize {
    if (fileSize == null) return 'Unknown';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  String toString() {
    return 'DocumentModel(id: $id, fileName: $fileName, type: $documentType)';
  }
}