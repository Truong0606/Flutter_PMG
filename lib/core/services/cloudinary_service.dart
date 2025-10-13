import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CloudinaryService {
  final String cloudName;
  final String uploadPreset; // unsigned preset recommended for client-side

  CloudinaryService({required this.cloudName, required this.uploadPreset});

  Uri get _uploadUrl => Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  Future<String> uploadImage(File file) async {
    final request = http.MultipartRequest('POST', _uploadUrl)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('image', _guessExt(file.path)),
      ));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      // We only need secure_url
      final body = response.body;
      final match = RegExp(r'"secure_url"\s*:\s*"([^"]+)"').firstMatch(body);
      if (match != null) return match.group(1)!;
      throw Exception('Upload succeeded but secure_url missing');
    }
    throw Exception('Cloudinary upload failed (${response.statusCode}): ${response.body}');
  }

  String _guessExt(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    if (lower.endsWith('.gif')) return 'gif';
    return 'jpeg';
  }
}
