import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/auth_service.dart';

class Api {
  static const _storage = FlutterSecureStorage();
  static final _authService = AuthService();

  static Future<Map<String, String>> getHeaders() async {
    try {
      final token = await _storage.read(key: 'token');
      print('DEBUG: Token saat ini: ${token != null ? 'Ada' : 'Tidak ada'}');

      if (token == null) {
        print('DEBUG: Token tidak ditemukan, mencoba refresh');
        final refreshed = await refreshToken();
        if (!refreshed) {
          print('DEBUG: Gagal refresh token');
          throw Exception('Token tidak ditemukan dan gagal memperbarui token');
        }
        // Ambil token baru setelah refresh
        final newToken = await _storage.read(key: 'token');
        if (newToken == null) {
          print('DEBUG: Gagal mendapatkan token baru setelah refresh');
          throw Exception('Gagal mendapatkan token baru');
        }
        print('DEBUG: Berhasil mendapatkan token baru');
        return {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $newToken',
        };
      }

      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      print('DEBUG: Error dalam getHeaders: $e');
      rethrow;
    }
  }

  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refreshToken');
      if (refreshToken == null) {
        print('DEBUG: Refresh token tidak ditemukan');
        return false;
      }

      print('DEBUG: Mencoba refresh token');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'refreshToken': refreshToken}),
      );

      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] == null) {
          print('DEBUG: Token tidak ada dalam response');
          return false;
        }

        await _storage.write(key: 'token', value: data['token']);
        if (data['refreshToken'] != null) {
          await _storage.write(
            key: 'refreshToken',
            value: data['refreshToken'],
          );
        }
        print('DEBUG: Token berhasil diperbarui');
        return true;
      }

      print('DEBUG: Gagal refresh token dengan status: ${response.statusCode}');
      return false;
    } catch (e) {
      print('DEBUG: Error saat refresh token: $e');
      return false;
    }
  }

  static Future<http.Response> handleResponse(http.Response response) async {
    print('DEBUG: Response status: ${response.statusCode}');

    if (response.statusCode == 401 || response.statusCode == 403) {
      print(
        'DEBUG: Token tidak valid (${response.statusCode}), mencoba refresh',
      );
      final refreshed = await refreshToken();
      if (refreshed) {
        // Retry the request with new token
        final headers = await getHeaders();
        final url = response.request?.url;
        if (url != null) {
          print('DEBUG: Mencoba request ulang ke: ${url.toString()}');
          return await http.get(Uri.parse(url.toString()), headers: headers);
        }
      }
      print(
        'DEBUG: Gagal refresh token, response tetap: ${response.statusCode}',
      );
    }
    return response;
  }
}
