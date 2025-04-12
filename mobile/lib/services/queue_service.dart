import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/queue.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class QueueService {
  final AuthService _authService = AuthService();

  Future<List<Queue>> getQueues() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/queue'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Queue.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data antrian: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getQueues: $e');
      rethrow;
    }
  }
}
