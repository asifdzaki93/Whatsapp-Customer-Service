import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/api_config.dart';
import '../models/contact.dart';
import '../services/auth_service.dart';

class ContactService {
  /// Mengambil daftar kontak dengan pagination
  /// [page] - Nomor halaman (dimulai dari 1)
  /// [search] - Kata kunci pencarian (opsional)
  /// [limit] - Jumlah item per halaman (default: 20)
  Future<Map<String, dynamic>> getContacts({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final queryParams = {
        if (search != null && search.isNotEmpty) 'searchParam': search,
        'pageNumber': page.toString(),
        'limit': limit.toString(),
        'fields':
            'id,name,number,email,profilePicUrl', // Hanya ambil field yang diperlukan
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/contacts/',
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
        return {
          'contacts':
              (data['contacts'] as List)
                  .map((contact) => Contact.fromJson(contact))
                  .toList(),
          'hasMore': data['hasMore'] ?? false,
          'total': data['count'] ?? 0,
          'currentPage': page,
        };
      }
      throw Exception('Gagal mengambil data kontak');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<Contact> createContact(Map<String, dynamic> data) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/contacts/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return Contact.fromJson(json.decode(response.body));
      }
      throw Exception('Gagal membuat kontak');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<Contact> updateContact(int id, Map<String, dynamic> data) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/contacts/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return Contact.fromJson(json.decode(response.body));
      }
      throw Exception('Gagal mengupdate kontak');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<void> deleteContact(int id) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/contacts/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus kontak');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<void> importContacts() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/contacts/import'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal mengimpor kontak');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<void> exportContacts(List<Contact> contacts) async {
    try {
      // Buat data CSV
      List<List<dynamic>> csvData = [
        ['Nama', 'Nomor WhatsApp', 'Email'], // Header
        ...contacts.map(
          (contact) => [contact.name, contact.number, contact.email ?? ''],
        ),
      ];

      // Konversi ke string CSV
      String csv = const ListToCsvConverter().convert(csvData);

      // Dapatkan direktori temporary
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/kontak.csv';

      // Tulis file CSV
      final file = File(path);
      await file.writeAsString(csv);

      // Share file
      await Share.shareXFiles([XFile(path)], subject: 'Daftar Kontak');
    } catch (e) {
      throw Exception('Gagal mengekspor kontak: ${e.toString()}');
    }
  }
}
