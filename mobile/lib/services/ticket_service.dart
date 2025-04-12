import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ticket.dart' as ticket_model;
import '../models/queue.dart' as queue_model;
import '../models/user.dart' as user_model;
import '../models/whatsapp.dart' as whatsapp_model;
import '../config/api_config.dart';
import 'auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketService {
  final AuthService _authService = AuthService();
  final String baseUrl = ApiConfig.baseUrl;
  late SharedPreferences _storage;

  TicketService() {
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storage = await SharedPreferences.getInstance();
  }

  Future<List<ticket_model.Ticket>> getTickets({
    int page = 1,
    String search = '',
    String status = '',
    DateTime? dateFrom,
    DateTime? dateTo,
    int? queueId,
    bool showAll = false,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final queryParams = {
        'page': page.toString(),
        'limit': '20',
        if (search.isNotEmpty) 'searchParam': search,
        if (status.isNotEmpty) 'status': status,
        if (dateFrom != null) 'dateFrom': dateFrom.toIso8601String(),
        if (dateTo != null) 'dateTo': dateTo.toIso8601String(),
        if (queueId != null) 'queueIds': queueId.toString(),
        'showAll': showAll.toString(),
      };

      final uri = Uri.parse(
        '$baseUrl/tickets',
      ).replace(queryParameters: queryParams);
      print('Requesting tickets from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('=== Ticket Data Debug ===');
        print('Raw data: $data');
        print('Tickets array: ${data['tickets']}');

        final List<dynamic> ticketsJson = data['tickets'] ?? [];
        print('Parsed tickets JSON: $ticketsJson');

        final tickets =
            ticketsJson
                .map((json) => ticket_model.Ticket.fromJson(json))
                .toList();
        print('Converted tickets: ${tickets.length} items');
        print(
          'First ticket: ${tickets.isNotEmpty ? tickets.first.toJson() : "No tickets"}',
        );
        print('=====================');

        return tickets;
      } else {
        throw Exception('Gagal mengambil data tiket: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getTickets: $e');
      rethrow;
    }
  }

  Future<ticket_model.Ticket> getTicketById(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.get(
        Uri.parse('$baseUrl/tickets/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ticket_model.Ticket.fromJson(data);
      } else {
        throw Exception('Gagal mengambil detail tiket: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getTicketById: $e');
      rethrow;
    }
  }

  Future<ticket_model.Ticket> updateTicketStatus(int id, String status) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.put(
        Uri.parse('$baseUrl/tickets/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ticket_model.Ticket.fromJson(data);
      } else {
        throw Exception(
          'Gagal mengupdate status tiket: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in updateTicketStatus: $e');
      rethrow;
    }
  }

  Future<ticket_model.Ticket> createTicket(Map<String, dynamic> data) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ticket_model.Ticket.fromJson(data);
      } else {
        throw Exception('Gagal membuat tiket baru: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in createTicket: $e');
      rethrow;
    }
  }

  Future<void> deleteTicket(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.delete(
        Uri.parse('$baseUrl/tickets/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus tiket: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in deleteTicket: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> getTicketCounts() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      // Ambil tiket dengan status open
      final openResponse = await http.get(
        Uri.parse('$baseUrl/tickets?status=open&showAll=false'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Ambil tiket dengan status pending
      final pendingResponse = await http.get(
        Uri.parse('$baseUrl/tickets?status=pending&showAll=false'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Ambil tiket dengan status closed
      final closedResponse = await http.get(
        Uri.parse('$baseUrl/tickets?status=closed&showAll=false'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (openResponse.statusCode == 200 &&
          pendingResponse.statusCode == 200 &&
          closedResponse.statusCode == 200) {
        final openData = json.decode(openResponse.body);
        final pendingData = json.decode(pendingResponse.body);
        final closedData = json.decode(closedResponse.body);

        return {
          'open': openData['count'] ?? 0,
          'pending': pendingData['count'] ?? 0,
          'closed': closedData['count'] ?? 0,
        };
      } else {
        throw Exception(
          'Gagal mengambil jumlah tiket: ${openResponse.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getTicketCounts: $e');
      rethrow;
    }
  }

  Future<String> uploadFile(String filePath, int ticketId) async {
    try {
      print('\n=== Upload File Debug ===');
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final file = File(filePath);
      final fileName = file.path.split('/').last;
      final fileSize = await file.length();

      print('File details:');
      print('Name: $fileName');
      print('Size: $fileSize bytes');
      print('Path: $filePath');

      // Get ticket details first to get companyId and other required data
      print('\nFetching ticket details...');
      final ticketResponse = await http.get(
        Uri.parse('$baseUrl/tickets/$ticketId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Ticket response status: ${ticketResponse.statusCode}');
      print('Ticket response body: ${ticketResponse.body}');

      if (ticketResponse.statusCode != 200) {
        throw Exception(
          'Gagal mendapatkan detail tiket: ${ticketResponse.statusCode}',
        );
      }

      final ticketData = jsonDecode(ticketResponse.body);
      final companyId = ticketData['companyId'];
      final contactId = ticketData['contactId'];
      final userId = ticketData['userId'];

      if (companyId == null || contactId == null || userId == null) {
        throw Exception('Data tiket tidak lengkap');
      }

      print('Company ID: $companyId');
      print('Contact ID: $contactId');
      print('User ID: $userId');

      // First create schedule to get ID
      print('\nCreating schedule first...');
      final scheduleResponse = await http.post(
        Uri.parse('$baseUrl/schedules'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'body': 'Temporary message for file upload',
          'sendAt': DateTime.now().toIso8601String(),
          'ticketId': ticketId,
          'contactId': contactId,
          'userId': userId,
          'companyId': companyId,
        }),
      );

      print('Schedule response status: ${scheduleResponse.statusCode}');
      print('Schedule response body: ${scheduleResponse.body}');

      if (scheduleResponse.statusCode != 200) {
        throw Exception(
          'Gagal membuat schedule: ${scheduleResponse.statusCode}',
        );
      }

      final scheduleData = jsonDecode(scheduleResponse.body);
      final scheduleId = scheduleData['id'];

      print('Schedule created with ID: $scheduleId');

      // Now upload the file
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/schedules/$scheduleId/media-upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      print('\nSending upload request...');
      print('Upload URL: ${request.url}');
      final response = await request.send();
      print('Response status: ${response.statusCode}');

      final responseData = await response.stream.bytesToString();
      print('Response body: $responseData');

      if (response.statusCode == 200) {
        print('Upload successful');
        return scheduleId.toString(); // Return schedule ID for later use
      } else {
        print('Upload failed with status: ${response.statusCode}');
        throw Exception('Gagal mengupload file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in uploadFile: $e');
      throw Exception('Gagal mengupload file: $e');
    }
  }

  Future<void> scheduleMessage(
    int ticketId,
    String message,
    DateTime scheduledDate, {
    List<String>? attachments,
  }) async {
    try {
      print('\n=== Schedule Message Debug ===');
      print('Ticket ID: $ticketId');
      print('Message: $message');
      print('Scheduled Date: ${scheduledDate.toIso8601String()}');
      print('Attachments: $attachments');

      final token = await _authService.getToken();
      print('Token: ${token != null ? 'Found' : 'Not found'}');

      if (token == null) throw Exception('Token tidak ditemukan');

      // Get ticket details first to get contactId
      print('\nFetching ticket details...');
      final ticketResponse = await http.get(
        Uri.parse('$baseUrl/tickets/$ticketId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Ticket response status: ${ticketResponse.statusCode}');
      print('Ticket response body: ${ticketResponse.body}');

      if (ticketResponse.statusCode != 200) {
        throw Exception('Gagal mendapatkan detail tiket');
      }

      final ticketData = jsonDecode(ticketResponse.body);
      final contactId = ticketData['contactId'];
      final userId = ticketData['userId'];

      print('Contact ID: $contactId');
      print('User ID: $userId');

      if (contactId == null || userId == null) {
        throw Exception('Data tiket tidak lengkap');
      }

      print('\nSending schedule request...');
      final response = await http.post(
        Uri.parse('$baseUrl/schedules'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'body': message,
          'sendAt': scheduledDate.toIso8601String(),
          'ticketId': ticketId,
          'contactId': contactId,
          'userId': userId,
          'attachments': attachments,
        }),
      );

      print('Schedule response status: ${response.statusCode}');
      print('Schedule response body: ${response.body}');

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ??
              errorData['message'] ??
              'Gagal menjadwalkan pesan',
        );
      }
      print('=== End Schedule Message Debug ===\n');
    } catch (e) {
      print('\nError in scheduleMessage: $e');
      print('=== End Schedule Message Debug ===\n');
      throw Exception('Gagal menjadwalkan pesan: $e');
    }
  }

  Future<List<user_model.User>> searchUsers(String query) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      print('\n=== Search Users Debug ===');
      print('Query: $query');
      print('Token: ${token.substring(0, 10)}...');
      print('Base URL: $baseUrl');

      final uri = Uri.parse('$baseUrl/users/list');
      print('Full URL: $uri');

      print('\nSending request...');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('\nResponse received:');
      print('Status code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        print('\nParsing response...');
        final List<dynamic> data = jsonDecode(response.body);
        print('Raw data: $data');

        print('\nConverting to User objects...');
        final allUsers =
            data.map((json) {
              print('\nProcessing user JSON: $json');
              try {
                final user = user_model.User.fromJson(json);
                print('Successfully created user: ${user.toJson()}');
                return user;
              } catch (e) {
                print('Error creating user: $e');
                rethrow;
              }
            }).toList();

        // Filter users based on query
        final filteredUsers =
            query.isEmpty
                ? allUsers
                : allUsers.where((user) {
                  final queryLower = query.toLowerCase();
                  return user.name.toLowerCase().contains(queryLower) ||
                      user.email.toLowerCase().contains(queryLower);
                }).toList();

        print('\nResults:');
        print('Total users found: ${filteredUsers.length}');
        if (filteredUsers.isNotEmpty) {
          print('First user: ${filteredUsers.first.toJson()}');
        }
        print('=== End Search Users Debug ===\n');

        return filteredUsers;
      } else {
        print('\nError: Request failed with status ${response.statusCode}');
        print('Response body: ${response.body}');
        print('=== End Search Users Debug ===\n');
        throw Exception('Gagal mencari pengguna: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('\nError in searchUsers:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('=== End Search Users Debug ===\n');
      rethrow;
    }
  }

  Future<List<queue_model.Queue>> getQueues() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      print('Fetching queues from: $baseUrl/queue');

      final response = await http.get(
        Uri.parse('$baseUrl/queue'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Queues response status: ${response.statusCode}');
      print('Queues response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Parsed queues data: $data');

        final queues =
            data.map((json) => queue_model.Queue.fromJson(json)).toList();
        print('Converted queues: ${queues.length} items');
        print(
          'First queue: ${queues.isNotEmpty ? queues.first.toJson() : "No queues"}',
        );

        return queues;
      } else {
        throw Exception('Failed to get queues: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getQueues: $e');
      rethrow;
    }
  }

  Future<void> transferTicket(
    int ticketId,
    int userId,
    int queueId,
    int whatsappId,
  ) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/tickets/$ticketId/transfer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'queueId': queueId,
          'whatsappId': whatsappId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to transfer ticket');
      }
    } catch (e) {
      throw Exception('Error transferring ticket: $e');
    }
  }

  Future<void> deleteTicketById(int ticketId) async {
    try {
      final token = await _authService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/tickets/$ticketId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete ticket');
      }
    } catch (e) {
      throw Exception('Error deleting ticket: $e');
    }
  }

  Future<List<whatsapp_model.Whatsapp>> getWhatsappConnections() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      print('Fetching WhatsApp connections from: $baseUrl/whatsapp');

      final response = await http.get(
        Uri.parse('$baseUrl/whatsapp'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('WhatsApp connections response status: ${response.statusCode}');
      print('WhatsApp connections response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Parsed WhatsApp connections data: $data');

        final connections =
            data.map((json) => whatsapp_model.Whatsapp.fromJson(json)).toList();
        print('Converted WhatsApp connections: ${connections.length} items');
        print(
          'First connection: ${connections.isNotEmpty ? connections.first.toJson() : "No connections"}',
        );

        return connections;
      } else {
        throw Exception(
          'Failed to get WhatsApp connections: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getWhatsappConnections: $e');
      rethrow;
    }
  }
}
