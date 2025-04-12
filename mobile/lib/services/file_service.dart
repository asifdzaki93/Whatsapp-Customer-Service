import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/file.dart';
import '../models/upload_file.dart';
import '../config/api_config.dart';

class FileService {
  late SharedPreferences _storage;

  FileService() {
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storage = await SharedPreferences.getInstance();
  }

  Future<List<File>> getFiles({String? searchParam, int page = 1}) async {
    try {
      final token = _storage.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      final queryParams = {
        if (searchParam != null) 'searchParam': searchParam,
        'pageNumber': page.toString(),
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/files',
      ).replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final files =
            (data['files'] as List).map((file) => File.fromJson(file)).toList();
        return files;
      } else {
        throw Exception('Gagal mengambil data file: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<File> createFile(
    String name,
    String message,
    List<Map<String, dynamic>> options,
  ) async {
    try {
      final token = _storage.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/files'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'message': message,
          'options': options,
        }),
      );

      if (response.statusCode == 200) {
        return File.fromJson(json.decode(response.body));
      } else {
        throw Exception('Gagal membuat file: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> uploadFile(int fileId, List<UploadFile> files) async {
    try {
      final token = _storage.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/files/uploadList/$fileId'),
      );

      request.headers.addAll({'Authorization': 'Bearer $token'});

      for (var file in files) {
        request.files.add(
          await http.MultipartFile.fromPath('files', file.path),
        );
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode != 200) {
        throw Exception('Gagal mengupload file: $jsonResponse');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteFile(int fileId) async {
    try {
      final token = _storage.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/files/$fileId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus file: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
