import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../config/api_config.dart';
import '../utils/api.dart';

class MessageService {
  Future<List<Message>> getMessages(
    int ticketId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('\n=== DEBUG: GET MESSAGES ===');
      print(
        'Request URL: ${ApiConfig.baseUrl}/messages/$ticketId?page=$page&limit=$limit',
      );

      final headers = await Api.getHeaders();
      print('Request Headers: $headers');

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/messages/$ticketId?page=$page&limit=$limit',
        ),
        headers: headers,
      );

      print('\nResponse Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Raw Response Body: ${response.body}');

      final handledResponse = await Api.handleResponse(response);

      if (handledResponse.statusCode == 200) {
        final data = json.decode(handledResponse.body);
        print('\nParsed Response Data:');
        print(JsonEncoder.withIndent('  ').convert(data));

        if (data['messages'] == null) {
          print('No messages found in response');
          return [];
        }

        final List<dynamic> messagesJson = data['messages'];
        print('\nFound ${messagesJson.length} messages');

        // Log raw data untuk setiap pesan
        messagesJson.asMap().forEach((index, message) {
          print('\n=== Message $index Raw Data ===');
          print(JsonEncoder.withIndent('  ').convert(message));

          // Log field-field penting
          print('\nImportant Fields:');
          print('ID: ${message['id']}');
          print('Body: ${message['body']}');
          print('FromMe: ${message['fromMe']}');
          print('Ack: ${message['ack']}');
          print('Read: ${message['read']}');
          print('Delivered: ${message['delivered']}');
          print('MediaType: ${message['mediaType']}');
          print('Status: ${message['status']}');

          // Log dataJson jika ada
          if (message['dataJson'] != null) {
            try {
              final dataJson = json.decode(message['dataJson']);
              print('\nDataJson Parsed:');
              print(JsonEncoder.withIndent('  ').convert(dataJson));

              // Log informasi dokumen jika ada
              if (dataJson['message']?['documentMessage'] != null) {
                final doc = dataJson['message']['documentMessage'];
                print('\nDocument Info:');
                print('FileName: ${doc['fileName']}');
                print('MimeType: ${doc['mimetype']}');
                print('FileLength: ${doc['fileLength']}');
                print('URL: ${doc['url']}');
              }
            } catch (e) {
              print('Error parsing dataJson: $e');
            }
          }
        });

        return messagesJson.map((json) {
          // Pastikan semua field yang diperlukan ada
          json['mediaType'] = json['mediaType'] ?? 'text';
          json['mediaUrl'] = ApiConfig.fixMediaUrl(json['mediaUrl']);
          json['mediaName'] = json['mediaName'] ?? '';
          json['mediaSize'] = json['mediaSize'] ?? '';
          json['mediaDuration'] = json['mediaDuration'] ?? '';
          json['locationName'] = json['locationName'] ?? '';
          json['fromMe'] = json['fromMe'] ?? false;
          json['read'] = json['read'] ?? false;
          json['isDeleted'] = json['isDeleted'] ?? false;
          json['isEdited'] = json['isEdited'] ?? false;
          json['status'] = json['status'] ?? 'SENT';

          // Parse dataJson untuk mendapatkan informasi tambahan
          if (json['dataJson'] != null) {
            try {
              final dataJson = json.decode(json['dataJson']);

              // Update mediaType berdasarkan mime type jika ada
              if (dataJson['message']?['documentMessage'] != null) {
                final doc = dataJson['message']['documentMessage'];
                json['mediaName'] = doc['fileName'] ?? json['mediaName'];
                json['mediaType'] = _getMediaTypeFromMime(doc['mimetype']);
                json['mediaSize'] = doc['fileLength'] ?? json['mediaSize'];
                json['mediaUrl'] = doc['url'] ?? json['mediaUrl'];
              }
            } catch (e) {
              print('Error parsing dataJson: $e');
            }
          }

          // Pastikan contact ada jika diperlukan
          if (json['contact'] == null) {
            json['contact'] = {
              'id': null,
              'name': null,
              'email': null,
              'number': null,
              'profilePicUrl': null,
              'ignoreMessages': false,
            };
          }

          return Message.fromJson(json);
        }).toList();
      } else {
        print('\nError Response:');
        print('Status Code: ${handledResponse.statusCode}');
        print('Response Body: ${handledResponse.body}');
        throw Exception(
          'Failed to load messages: ${handledResponse.statusCode}',
        );
      }
    } catch (e) {
      print('\nError in getMessages:');
      print(e);
      rethrow;
    } finally {
      print('\n=== END DEBUG: GET MESSAGES ===\n');
    }
  }

  // Helper function untuk menentukan media type dari mime type
  String _getMediaTypeFromMime(String? mimeType) {
    if (mimeType == null) return 'text';

    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType.startsWith('video/')) return 'video';
    if (mimeType.startsWith('audio/')) return 'audio';

    // Handle dokumen
    if (mimeType.contains('pdf')) return 'application/pdf';
    if (mimeType.contains('word') || mimeType.contains('docx'))
      return 'application/msword';
    if (mimeType.contains('excel') || mimeType.contains('xlsx'))
      return 'application/vnd.ms-excel';
    if (mimeType.contains('powerpoint') || mimeType.contains('pptx'))
      return 'application/vnd.ms-powerpoint';
    if (mimeType.contains('text/')) return 'text/plain';

    return 'application/octet-stream';
  }

  Future<Message> sendMessage(int ticketId, String content) async {
    try {
      print('\n=== DEBUG: SEND MESSAGE ===');
      print('Ticket ID: $ticketId');
      print('Content: $content');

      final headers = await Api.getHeaders();
      print('Request Headers: $headers');

      final requestBody = {
        'body': content,
        'fromMe': true,
        'mediaType': null,
        'ticketId': ticketId,
        'read': false,
        'delivered': false,
        'isDeleted': false,
        'isEdited': false,
        'remoteJid': null,
        'participant': null,
        'ack': 0,
        'mediaName': '',
        'mediaSize': '',
        'mediaDuration': '',
        'locationName': '',
        'status': 'PENDING',
        'dataJson': json.encode({
          'key': {
            'remoteJid': null,
            'fromMe': true,
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
          },
          'message': {'conversation': content},
        }),
      };

      print('\nRequest Body:');
      print(JsonEncoder.withIndent('  ').convert(requestBody));

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/messages/$ticketId'),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('\nResponse Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Jika response kosong, buat message baru dari request body
        if (response.body.isEmpty) {
          print('\nResponse body is empty, creating message from request body');
          final messageData = {
            ...requestBody,
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'contact': {
              'id': null,
              'name': null,
              'email': null,
              'number': null,
              'profilePicUrl': null,
              'ignoreMessages': false,
            },
          };

          print('\nCreated Message Data:');
          print(JsonEncoder.withIndent('  ').convert(messageData));

          return Message.fromJson(messageData);
        }

        // Jika ada response body, parse seperti biasa
        final data = json.decode(response.body);
        print('\nParsed Response Data:');
        print(JsonEncoder.withIndent('  ').convert(data));

        // Log field-field penting
        print('\nImportant Fields:');
        print('ID: ${data['id']}');
        print('Body: ${data['body']}');
        print('FromMe: ${data['fromMe']}');
        print('Ack: ${data['ack']}');
        print('Read: ${data['read']}');
        print('Delivered: ${data['delivered']}');
        print('MediaType: ${data['mediaType']}');
        print('Status: ${data['status']}');
        print('DataJson: ${data['dataJson']}');

        // Pastikan semua field yang diperlukan ada
        data['mediaType'] = data['mediaType'] ?? 'text';
        data['mediaUrl'] = ApiConfig.fixMediaUrl(data['mediaUrl']);
        data['mediaName'] = data['mediaName'] ?? '';
        data['mediaSize'] = data['mediaSize'] ?? '';
        data['mediaDuration'] = data['mediaDuration'] ?? '';
        data['locationName'] = data['locationName'] ?? '';
        data['fromMe'] = data['fromMe'] ?? true;
        data['read'] = data['read'] ?? false;
        data['delivered'] = data['delivered'] ?? false;
        data['isDeleted'] = data['isDeleted'] ?? false;
        data['isEdited'] = data['isEdited'] ?? false;
        data['ack'] = data['ack'] ?? 0;
        data['status'] = data['status'] ?? 'SENT';

        // Pastikan contact ada jika diperlukan
        if (data['contact'] == null) {
          data['contact'] = {
            'id': null,
            'name': null,
            'email': null,
            'number': null,
            'profilePicUrl': null,
            'ignoreMessages': false,
          };
        }

        return Message.fromJson(data);
      } else {
        print('\nError Response:');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('\nError in sendMessage:');
      print(e);
      rethrow;
    } finally {
      print('\n=== END DEBUG: SEND MESSAGE ===\n');
    }
  }

  Future<void> markAsRead(int messageId) async {
    try {
      final headers = await Api.getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/messages/$messageId/read'),
        headers: headers,
        body: json.encode({'status': 'READ'}),
      );

      final handledResponse = await Api.handleResponse(response);

      if (handledResponse.statusCode != 200) {
        throw Exception(
          'Failed to mark message as read: ${handledResponse.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error marking message as read: $e');
    }
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      final headers = await Api.getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/messages/$messageId'),
        headers: headers,
      );

      final handledResponse = await Api.handleResponse(response);

      if (handledResponse.statusCode != 200) {
        throw Exception(
          'Failed to delete message: ${handledResponse.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }

  Future<void> markAsDelivered(int messageId) async {
    try {
      final headers = await Api.getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/messages/$messageId/delivered'),
        headers: headers,
        body: json.encode({'status': 'DELIVERED'}),
      );

      final handledResponse = await Api.handleResponse(response);

      if (handledResponse.statusCode != 200) {
        throw Exception(
          'Failed to mark message as delivered: ${handledResponse.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error marking message as delivered: $e');
    }
  }
}
