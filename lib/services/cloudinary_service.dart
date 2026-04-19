import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = "dkqwbh8nq";
  final String uploadPreset = "unsigned_upload"; // create this in Cloudinary

  /// Upload profile image
  Future<String?> uploadProfileImage(File file) async {
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
}