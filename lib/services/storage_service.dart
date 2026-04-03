import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/firebase_consts.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile({
    required String path,
    required File file,
    Map<String, String>? metadata,
    Function(double)? onProgress,
  }) async {
    try {
      Reference ref = _storage.ref().child(path);
      
      SettableMetadata? settableMetadata;
      if (metadata != null) {
        settableMetadata = SettableMetadata(
          contentType: metadata['contentType'],
          customMetadata: metadata,
        );
      }
      
      UploadTask uploadTask = ref.putFile(file, settableMetadata);
      
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload file: $e';
    }
  }

  Future<String?> uploadDocumentForDispute({
    required String disputeId,
    required PlatformFile file,
    Function(double)? onProgress,
  }) async {
    String path = '${FirebaseConsts.documentsFolder}/$disputeId/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    File localFile = File(file.path!);
    
    return uploadFile(
      path: path,
      file: localFile,
      metadata: {
        'contentType': file.extension != null ? _getContentType(file.extension!) : 'application/octet-stream',
        'originalName': file.name,
        'disputeId': disputeId,
      },
      onProgress: onProgress,
    );
  }

  Future<void> deleteFile(String filePath) async {
    try {
      Reference ref = _storage.ref().child(filePath);
      await ref.delete();
    } catch (e) {
      throw 'Failed to delete file: $e';
    }
  }

  Future<String?> getDownloadUrl(String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to get download URL: $e';
    }
  }

  Future<String?> uploadProfilePicture({
    required String userId,
    required File file,
  }) async {
    String path = '${FirebaseConsts.profilePictureFolder}/$userId/profile.jpg';
    return uploadFile(path: path, file: file);
  }

  Future<PlatformFile?> pickFile({
    List<String>? allowedExtensions,
    int maxSizeInBytes = 10 * 1024 * 1024,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );
      
      if (result != null) {
        PlatformFile file = result.files.first;
        if (file.size > maxSizeInBytes) {
          throw 'File size exceeds maximum allowed size (${maxSizeInBytes ~/ (1024 * 1024)}MB)';
        }
        return file;
      }
      return null;
    } catch (e) {
      throw 'Failed to pick file: $e';
    }
  }

  Future<List<String>> uploadMultipleFiles({
    required String disputeId,
    required List<PlatformFile> files,
    Function(double, int)? onProgress,
  }) async {
    List<String> urls = [];
    for (int i = 0; i < files.length; i++) {
      String? url = await uploadDocumentForDispute(
        disputeId: disputeId,
        file: files[i],
        onProgress: (progress) {
          if (onProgress != null) {
            onProgress(progress, i);
          }
        },
      );
      if (url != null) {
        urls.add(url);
      }
    }
    return urls;
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf': return 'application/pdf';
      case 'jpg': case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      case 'doc': return 'application/msword';
      case 'docx': return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default: return 'application/octet-stream';
    }
  }
}