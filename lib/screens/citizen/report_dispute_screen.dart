import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dispute_provider.dart';
import '../../models/dispute_model.dart';
import '../../services/storage_service.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ReportDisputeScreen extends StatefulWidget {
  const ReportDisputeScreen({super.key});

  @override
  State<ReportDisputeScreen> createState() => _ReportDisputeScreenState();
}

class _ReportDisputeScreenState extends State<ReportDisputeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _plotNumberController = TextEditingController();
  
  DisputeType _selectedType = DisputeType.other;
  DisputePriority _selectedPriority = DisputePriority.medium;
  List<PlatformFile> _selectedDocuments = [];
  final StorageService _storageService = StorageService();
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _plotNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    try {
      PlatformFile? file = await _storageService.pickFile(
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );
      if (file != null) {
        setState(() {
          _selectedDocuments.add(file);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _selectedDocuments.removeAt(index);
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate that at least one document is attached
    if (_selectedDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please attach at least one supporting document'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final disputeProvider = Provider.of<DisputeProvider>(context, listen: false);

    // First create dispute to get ID
    DisputeModel dispute = DisputeModel(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      plotNumber: _plotNumberController.text.trim(),
      disputeType: _selectedType,
      priority: _selectedPriority,
      submittedBy: authProvider.userUid!,
    );

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Submit dispute first to get document ID
    String? disputeId = await disputeProvider.createDisputeGetId(dispute);
    
    if (disputeId == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(disputeProvider.errorMessage ?? 'Failed to submit dispute'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Upload all documents
    List<String> documentUrls = await _storageService.uploadMultipleFiles(
      disputeId: disputeId,
      files: _selectedDocuments,
      onProgress: (progress, index) {
        setState(() {
          _uploadProgress = (index + progress) / _selectedDocuments.length;
        });
      },
    );

    // Update dispute with document urls
    dispute = dispute.copyWith(
      id: disputeId,
      documentIds: documentUrls,
    );

    bool success = await disputeProvider.updateDisputeDocuments(disputeId, documentUrls);

    if (!mounted) return;
    Navigator.of(context).pop(); // Hide loading

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dispute submitted successfully'),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.pop(context); // Go back
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(disputeProvider.errorMessage ?? 'Failed to submit dispute'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Dispute'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Dispute Title',
                hintText: 'Enter a brief title',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Title is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _locationController,
                label: 'Location',
                hintText: 'Enter dispute location',
                prefixIcon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Location is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _plotNumberController,
                label: 'Plot Number',
                hintText: 'Enter plot number',
                prefixIcon: Icons.numbers,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Plot number is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DisputeType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Dispute Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: DisputeType.boundary, child: Text('Boundary Dispute')),
                  DropdownMenuItem(value: DisputeType.ownership, child: Text('Ownership Dispute')),
                  DropdownMenuItem(value: DisputeType.inheritance, child: Text('Inheritance Dispute')),
                  DropdownMenuItem(value: DisputeType.lease, child: Text('Lease Dispute')),
                  DropdownMenuItem(value: DisputeType.other, child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DisputePriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: const [
                  DropdownMenuItem(value: DisputePriority.low, child: Text('Low')),
                  DropdownMenuItem(value: DisputePriority.medium, child: Text('Medium')),
                  DropdownMenuItem(value: DisputePriority.high, child: Text('High')),
                  DropdownMenuItem(value: DisputePriority.urgent, child: Text('Urgent')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedPriority = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the dispute in detail',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Description is required';
                  return null;
                },
               ),
               const SizedBox(height: 16),
               
               // Document Upload Section
               const Text(
                 'Supporting Documents *',
                 style: TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.bold,
                 ),
               ),
               const SizedBox(height: 8),
               const Text(
                 'Upload land title deeds, survey maps, agreements or any relevant documents',
                 style: TextStyle(color: AppColors.textLight, fontSize: 12),
               ),
               const SizedBox(height: 12),
               
               OutlinedButton.icon(
                 onPressed: _pickDocument,
                 icon: const Icon(Icons.attach_file),
                 label: const Text('Attach Document'),
                 style: OutlinedButton.styleFrom(
                   minimumSize: const Size(double.infinity, 50),
                 ),
               ),
               
               if (_selectedDocuments.isNotEmpty)
                 const SizedBox(height: 12),
               
               ..._selectedDocuments.asMap().entries.map((entry) {
                 int idx = entry.key;
                 PlatformFile file = entry.value;
                 return Card(
                   child: ListTile(
                     leading: const Icon(Icons.insert_drive_file),
                     title: Text(file.name),
                     subtitle: Text('${(file.size / 1024).toStringAsFixed(1)} KB'),
                     trailing: IconButton(
                       icon: const Icon(Icons.close, color: AppColors.errorColor),
                       onPressed: () => _removeDocument(idx),
                     ),
                   ),
                 );
               }),
               
               if (_isUploading)
                 Padding(
                   padding: const EdgeInsets.only(top: 12),
                   child: Column(
                     children: [
                       LinearProgressIndicator(value: _uploadProgress),
                       const SizedBox(height: 8),
                       Text('Uploading documents... ${(_uploadProgress * 100).toStringAsFixed(0)}%'),
                     ],
                   ),
                 ),
               
               const SizedBox(height: 24),
               CustomButton(
                 text: 'Submit Dispute',
                 onPressed: _isUploading ? null : _handleSubmit,
               ),
            ],
          ),
        ),
      ),
    );
  }
}