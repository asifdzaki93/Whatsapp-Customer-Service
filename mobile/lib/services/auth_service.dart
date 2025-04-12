import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _storage = const FlutterSecureStorage();
  User? _currentUser;

  Future<User> login({required String email, required String password}) async {
    try {
      print('=== Login Debug ===');
      print('Attempting login for: $email');

      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Saving token: ${data['token']}');
        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'refreshToken', value: data['refreshToken']);
        print('Token saved successfully');

        // Simpan data user dari response login
        _currentUser = User.fromJson(data['user']);
        print('User data saved: ${_currentUser?.toJson()}');
        return _currentUser!;
      } else {
        print('Login failed: ${response.statusCode}');
        throw Exception('Email atau kata sandi salah');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Gagal masuk: $e');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.register),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.envToken}',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'profile': 'admin',
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal mendaftar');
      }
    } catch (e) {
      throw Exception('Gagal mendaftar: $e');
    }
  }

  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'password', value: password);
  }

  Future<Map<String, String?>> getCredentials() async {
    final email = await _storage.read(key: 'email');
    final password = await _storage.read(key: 'password');
    return {'email': email, 'password': password};
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'password');
  }

  Future<void> logout() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token != null) {
        await http.post(
          Uri.parse(ApiConfig.baseUrl + ApiConfig.logout),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      }
    } finally {
      await _storage.deleteAll();
      _currentUser = null;
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }

  Future<User?> getCurrentUser() async {
    // Jika sudah ada data user, gunakan itu
    if (_currentUser != null) {
      print('Using cached user data: ${_currentUser?.toJson()}');
      return _currentUser;
    }

    final token = await _storage.read(key: 'token');
    print('=== Auth Debug ===');
    print('Token: $token');

    if (token == null) {
      print('Token is null');
      return null;
    }

    // Decode token untuk mendapatkan data user
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print('Invalid token format');
        return null;
      }

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      _currentUser = User(
        id: payload['id'],
        name: payload['username'],
        email: payload['email'] ?? '',
        profile: payload['profile'],
        companyId: payload['companyId'],
        online: false,
      );

      print('User data from token: ${_currentUser?.toJson()}');
      return _currentUser;
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refreshToken');
  }

  Future<dynamic> getCurrentUserFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      return json.decode(userJson);
    }
    return null;
  }

  Future<String?> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return null;
      }

      print('Mencoba refresh token...');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refreshToken}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      print('Refresh token response status: ${response.statusCode}');
      print('Refresh token response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newToken = data['token'];
        final newRefreshToken = data['refreshToken'];

        // Simpan token baru
        await _storage.write(key: 'token', value: newToken);
        await _storage.write(key: 'refreshToken', value: newRefreshToken);

        print('Token berhasil diperbarui');
        return newToken;
      } else {
        print('Gagal refresh token: ${response.statusCode}');
        // Hapus token yang tidak valid
        await _storage.delete(key: 'token');
        await _storage.delete(key: 'refreshToken');
        return null;
      }
    } catch (e) {
      print('Error saat refresh token: $e');
      return null;
    }
  }
}
