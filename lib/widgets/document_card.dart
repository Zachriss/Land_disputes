import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../constants/colors.dart';

class DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getFileTypeColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getFileTypeIcon(), color: Colors.white),
        ),
        title: Text(
          document.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getDocumentTypeLabel()),
            if (document.fileSize != null)
              Text(document.formattedFileSize),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (document.isVerified)
              const Icon(Icons.verified, color: AppColors.successColor, size: 20),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.errorColor),
                onPressed: onDelete,
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getFileTypeIcon() {
    final name = document.fileName.toLowerCase();
    if (name.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png')) {
      return Icons.image;
    }
    if (name.endsWith('.doc') || name.endsWith('.docx')) return Icons.description;
    return Icons.insert_drive_file;
  }

  Color _getFileTypeColor() {
    final name = document.fileName.toLowerCase();
    if (name.endsWith('.pdf')) return Colors.red;
    if (name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png')) {
      return Colors.blue;
    }
    if (name.endsWith('.doc') || name.endsWith('.docx')) return Colors.indigo;
    return Colors.grey;
  }

  String _getDocumentTypeLabel() {
    switch (document.documentType) {
      case DocumentType.titleDeed: return 'Title Deed';
      case DocumentType.surveyPlan: return 'Survey Plan';
      case DocumentType.idCard: return 'ID Card';
      case DocumentType.agreement: return 'Agreement';
      case DocumentType.courtOrder: return 'Court Order';
      case DocumentType.photograph: return 'Photograph';
      case DocumentType.other: return 'Other Document';
    }
  }
}