import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class StorageService {
  final String cloudName = "dkqwbh8nq";
  final String uploadPreset = "unsigned_upload"; // create this in Cloudinary

  /// =========================
  /// GENERIC UPLOAD FILE
  /// =========================
  Future<String?> uploadFile({
    required String path,
    required File file,
    Map<String, String>? metadata,
    Function(double)? onProgress,
  }) async {
    try {
      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      var request = http.MultipartRequest("POST", url);

      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final res = await response.stream.bytesToString();
        final data = json.decode(res);

        return data['secure_url']; // 🔥 THIS IS YOUR IMAGE URL
      } else {
        print("UPLOAD FAILED: ${response.statusCode}");
        print("Response body: ${await response.stream.bytesToString()}");
        return null;
      }
    } catch (e) {
      print("CLOUDINARY ERROR: $e");
      return null;
    }
  }

  /// =========================
  /// UPLOAD DISPUTE DOCUMENT
  /// =========================
  Future<String?> uploadDocumentForDispute({
    required String disputeId,
    required PlatformFile file,
    Function(double)? onProgress,
  }) async {
    try {
      if (file.path == null) throw "Invalid file path";

      final fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${file.name}";

      final localFile = File(file.path!);

      return await uploadFile(
        path: "documents/$disputeId/$fileName",
        file: localFile,
        metadata: {
          'contentType': _getContentType(file.extension),
          'originalName': file.name,
          'disputeId': disputeId,
        },
        onProgress: onProgress,
      );
    } catch (e) {
      print("DOCUMENT UPLOAD ERROR: $e");
      return null;
    }
  }

  /// =========================
  /// MULTIPLE FILE UPLOAD
  /// =========================
  Future<List<String>> uploadMultipleFiles({
    required String disputeId,
    required List<PlatformFile> files,
    Function(double progress, int index)? onProgress,
  }) async {
    List<String> urls = [];

    for (int i = 0; i < files.length; i++) {
      final url = await uploadDocumentForDispute(
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

  /// =========================
  /// PROFILE IMAGE UPLOAD
  /// =========================
  Future<String?> uploadProfilePicture({
    required String userId,
    required File file,
  }) async {
    return await uploadFile(
      path: "profile_pictures/$userId/profile.jpg",
      file: file,
      metadata: {
        'contentType': 'image/jpeg',
        'userId': userId,
      },
    );
  }

  /// =========================
  /// DELETE FILE
  /// =========================
  Future<void> deleteFile(String path) async {
    try {
      // Cloudinary doesn't support direct deletion via API
      // You would need to use Cloudinary's admin API for deletion
      print("DELETE FILE: Cloudinary doesn't support direct deletion via API");
    } catch (e) {
      print("DELETE ERROR: $e");
    }
  }

  /// =========================
  /// PICK FILE
  /// =========================
  Future<PlatformFile?> pickFile({
    List<String>? allowedExtensions,
    int maxSizeInBytes = 10 * 1024 * 1024,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        final file = result.files.first;

        if (file.size > maxSizeInBytes) {
          throw "File too large (Max ${maxSizeInBytes ~/ (1024 * 1024)}MB)";
        }

        return file;
      }

      return null;
    } catch (e) {
      print("FILE PICK ERROR: $e");
      return null;
    }
  }

  /// =========================
  /// CONTENT TYPE HELPER
  /// =========================
  String _getContentType(String? ext) {
    if (ext == null) return 'application/octet-stream';

    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}