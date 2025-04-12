import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class DashboardService {
  final _authService = AuthService();

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Format tanggal sesuai dengan yang diharapkan backend
      final dateFrom = startOfDay.toIso8601String().split('T')[0];
      final dateTo = endOfDay.toIso8601String().split('T')[0];

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/dashboard',
      ).replace(queryParameters: {'date_from': dateFrom, 'date_to': dateTo});

      print('Requesting dashboard data from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Raw API Response: $data');

        // Pastikan data counters ada
        if (data['counters'] == null) {
          print('Warning: counters data is null');
          data['counters'] = {};
        }

        // Pastikan ticketsPerHour ada dan memiliki 24 jam data
        List<dynamic> ticketsPerHour = List.generate(24, (index) => 0);
        if (data['counters']['ticketsPerHour'] != null) {
          final List<dynamic> rawTickets = data['counters']['ticketsPerHour'];
          for (int i = 0; i < 24 && i < rawTickets.length; i++) {
            ticketsPerHour[i] = rawTickets[i] ?? 0;
          }
        }

        // Buat objek counters dengan nilai default
        final counters = {
          'ticketsPerHour': ticketsPerHour,
          'avgSupportTime': data['counters']?['avgSupportTime'] ?? 0,
          'avgWaitTime': data['counters']?['avgWaitTime'] ?? 0,
          'supportPending': data['counters']?['supportPending'] ?? 0,
          'supportHappening': data['counters']?['supportHappening'] ?? 0,
          'supportFinished': data['counters']?['supportFinished'] ?? 0,
          'leads': data['counters']?['leads'] ?? 0,
        };

        print('Processed counters: $counters');

        return {
          'counters': counters,
          'attendants': data['attendants'] ?? [],
          'companyDueDate':
              data['companyDueDate'] != null
                  ? DateTime.parse(data['companyDueDate'])
                  : null,
        };
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        // Coba parse error message dari response
        try {
          final errorData = json.decode(response.body);
          throw Exception(
            errorData['error'] ?? 'Gagal mengambil data dashboard',
          );
        } catch (e) {
          throw Exception(
            'Gagal mengambil data dashboard: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Dashboard Service Error: $e');
      throw Exception('Error: ${e.toString()}');
    }
  }
}
