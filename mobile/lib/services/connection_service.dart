import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/connection.dart';
import 'auth_service.dart';

class ConnectionService {
  final String baseUrl;
  final AuthService _authService;
  IO.Socket? _socket;
  final List<Function(Map<String, dynamic>)> _socketListeners = [];

  ConnectionService({required this.baseUrl, required AuthService authService})
      : _authService = authService;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> connectSocket() async {
    if (_socket != null) return;

    print('=== DEBUG: Mencoba koneksi socket ===');
    print('Base URL: $baseUrl');

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({
            'Authorization': 'Bearer ${_authService.getToken()}',
          })
          .setTimeout(30000)
          .build(),
    );

    final completer = Completer<void>();

    _socket?.onConnect((_) {
      print('=== DEBUG: Socket berhasil terhubung ===');
      completer.complete();
    });

    _socket?.onConnectError((error) {
      print('=== DEBUG: Socket connection error ===');
      print('Error: $error');
      completer.completeError(error);
    });

    _socket?.onDisconnect((_) {
      print('=== DEBUG: Socket terputus ===');
    });

    _socket?.onError((error) {
      print('=== DEBUG: Socket error ===');
      print('Error: $error');
    });

    _socket?.on('whatsappSession', (data) {
      print('=== DEBUG: Socket whatsappSession event ===');
      print('Data: $data');
      for (final listener in _socketListeners) {
        listener(data);
      }
    });

    return completer.future;
  }

  void addSocketListener(Function(Map<String, dynamic>) listener) {
    _socketListeners.add(listener);
  }

  void removeSocketListener(Function(Map<String, dynamic>) listener) {
    _socketListeners.remove(listener);
  }

  Future<List<Connection>> getConnections() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/whatsapp'), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 401 || response.statusCode == 403) {
        final newToken = await _authService.refreshToken();
        if (newToken != null) {
          final newHeaders = await _getHeaders();
          final retryResponse = await http
              .get(Uri.parse('$baseUrl/whatsapp'), headers: newHeaders)
              .timeout(const Duration(seconds: 30));
          if (retryResponse.statusCode == 200) {
            final List<dynamic> data = json.decode(retryResponse.body);
            return data.map((json) => Connection.fromJson(json)).toList();
          }
        }
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else if (response.statusCode != 200) {
        throw Exception(
          'Gagal mendapatkan daftar koneksi. Status: ${response.statusCode}',
        );
      }

      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Connection.fromJson(json)).toList();
    } catch (e) {
      print('Error saat mendapatkan daftar koneksi: $e');
      rethrow;
    }
  }

  Future<Connection> addConnection(String name) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/whatsapp'),
            headers: headers,
            body: json.encode({'name': name}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 401 || response.statusCode == 403) {
        final newToken = await _authService.refreshToken();
        if (newToken != null) {
          final newHeaders = await _getHeaders();
          final retryResponse = await http
              .post(
                Uri.parse('$baseUrl/whatsapp'),
                headers: newHeaders,
                body: json.encode({'name': name}),
              )
              .timeout(const Duration(seconds: 30));
          if (retryResponse.statusCode == 200) {
            return Connection.fromJson(json.decode(retryResponse.body));
          }
        }
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else if (response.statusCode != 200) {
        throw Exception(
          'Gagal menambah koneksi. Status: ${response.statusCode}',
        );
      }

      return Connection.fromJson(json.decode(response.body));
    } catch (e) {
      print('Error saat menambah koneksi: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestQrCode(String whatsAppId) async {
    print('===========================');
    print('=== DEBUG: Memulai request QR code ===');
    print('WhatsApp ID: $whatsAppId');

    // Pastikan socket terhubung
    if (_socket == null || !_socket!.connected) {
      print('=== DEBUG: Socket belum terhubung, mencoba koneksi ulang ===');
      await connectSocket();
    }

    final completer = Completer<Map<String, dynamic>>();
    bool qrCodeReceived = false;
    Timer? timeoutTimer;

    try {
      // Setup socket listener untuk QR code
      _socket?.on('whatsappSession', (data) {
        print('=== DEBUG: Socket whatsappSession event ===');
        print('Data: $data');

        if (data['action'] == 'update' && data['session'] != null) {
          final session = data['session'];
          print('=== DEBUG: Session Update ===');
          print('Session ID: ${session['id']}');
          print('Session Status: ${session['status']}');
          print('Session QR Code: ${session['qrcode']}');
          print('Session Data Lengkap: $session');

          // Jika status DISCONNECTED, batalkan request
          if (session['status'] == 'DISCONNECTED') {
            print('=== DEBUG: Status DISCONNECTED, membatalkan request ===');
            if (!qrCodeReceived) {
              qrCodeReceived = true;
              completer.completeError('Koneksi terputus. Silakan coba lagi.');
            }
            return;
          }

          // Jika QR code tersedia dan valid, selesaikan
          if (session['qrcode'] != null &&
              session['qrcode'].toString().isNotEmpty &&
              session['qrcode'].toString().startsWith('2@')) {
            print('=== DEBUG: QR code valid diterima ===');
            if (!qrCodeReceived) {
              qrCodeReceived = true;
              final qrData = {
                'qrcode': session['qrcode'],
                'status': session['status'],
              };
              print('=== DEBUG: Mengirim data QR code ===');
              print('QR Data: $qrData');
              completer.complete(qrData);
            }
          }
        }
      });

      // Kirim request ke server
      print('=== DEBUG: Mengirim request ke server ===');
      print('URL: $baseUrl/whatsappsession/$whatsAppId');
      final headers = await _getHeaders();
      print('Headers: $headers');

      final response = await http.put(
        Uri.parse('$baseUrl/whatsappsession/$whatsAppId'),
        headers: headers,
      );

      print('=== DEBUG: Response dari server ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Set timeout timer
      timeoutTimer = Timer(const Duration(seconds: 30), () {
        if (!qrCodeReceived) {
          print('=== DEBUG: Timeout setelah 30 detik ===');
          completer.completeError('Waktu tunggu habis. Silakan coba lagi.');
        }
      });

      // Tunggu QR code
      return await completer.future;
    } catch (e) {
      print('=== DEBUG: Error ===');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      rethrow;
    } finally {
      timeoutTimer?.cancel();
      // Hapus listener socket
      _socket?.off('whatsappSession');
    }
  }

  Future<void> disconnect(String whatsAppId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('$baseUrl/whatsappsession/$whatsAppId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 401 || response.statusCode == 403) {
        final newToken = await _authService.refreshToken();
        if (newToken != null) {
          final newHeaders = await _getHeaders();
          final retryResponse = await http
              .delete(
                Uri.parse('$baseUrl/whatsappsession/$whatsAppId'),
                headers: newHeaders,
              )
              .timeout(const Duration(seconds: 30));
          if (retryResponse.statusCode != 200) {
            throw Exception(
              'Gagal memutus koneksi. Status: ${retryResponse.statusCode}',
            );
          }
        } else {
          throw Exception('Sesi telah berakhir. Silakan login kembali.');
        }
      } else if (response.statusCode != 200) {
        throw Exception(
          'Gagal memutus koneksi. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error saat memutus koneksi: $e');
      rethrow;
    }
  }

  Future<void> deleteConnection(String whatsAppId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(Uri.parse('$baseUrl/whatsapp/$whatsAppId'), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 401 || response.statusCode == 403) {
        final newToken = await _authService.refreshToken();
        if (newToken != null) {
          final newHeaders = await _getHeaders();
          final retryResponse = await http
              .delete(
                Uri.parse('$baseUrl/whatsapp/$whatsAppId'),
                headers: newHeaders,
              )
              .timeout(const Duration(seconds: 30));
          if (retryResponse.statusCode != 200) {
            throw Exception(
              'Gagal menghapus koneksi. Status: ${retryResponse.statusCode}',
            );
          }
        } else {
          throw Exception('Sesi telah berakhir. Silakan login kembali.');
        }
      } else if (response.statusCode != 200) {
        throw Exception(
          'Gagal menghapus koneksi. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error saat menghapus koneksi: $e');
      rethrow;
    }
  }

  void dispose() {
    _socket?.disconnect();
    _socket = null;
    _socketListeners.clear();
  }
}
