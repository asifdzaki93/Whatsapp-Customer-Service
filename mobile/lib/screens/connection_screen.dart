import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/connection.dart';
import '../services/connection_service.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';
import '../widgets/add_whatsapp_dialog.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/connection_card.dart';
import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  late final ConnectionService _connectionService;
  List<Connection> _connections = [];
  bool _isLoading = false;
  bool _isRequestingQr = false;
  String? _error;
  String? _currentQrConnectionId;
  Timer? _qrTimeoutTimer;

  @override
  void initState() {
    super.initState();
    _connectionService = ConnectionService(
      baseUrl: ApiConfig.baseUrl,
      authService: AuthService(),
    );
    _loadConnections();
  }

  @override
  void dispose() {
    _qrTimeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadConnections() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final connections = await _connectionService.getConnections();
      setState(() {
        _connections = connections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAddConnection() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddWhatsAppDialog(
        onAdd: (name) async {
          try {
            await _connectionService.addConnection(name);
            return true;
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menambah koneksi: $e')),
            );
            return false;
          }
        },
      ),
    );

    if (result == true) {
      await _loadConnections();
    }
  }

  Future<void> _handleRequestQrCode(Connection connection) async {
    if (_isRequestingQr) return;

    setState(() {
      _isRequestingQr = true;
      _currentQrConnectionId = connection.id.toString();
      _error = null;
    });

    try {
      print('=== DEBUG: Meminta QR code untuk koneksi ${connection.id} ===');
      final result =
          await _connectionService.requestQrCode(connection.id.toString());

      if (result['qrcode'] != null && result['qrcode'].toString().isNotEmpty) {
        print('=== DEBUG: Menampilkan QR code ===');
        setState(() {
          _isRequestingQr = false;
          _currentQrConnectionId = null;
          connection = connection.copyWith(qrCode: result['qrcode'].toString());
        });

        _showQrCodeDialog(connection);
      } else {
        print('=== DEBUG: QR code tidak tersedia ===');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR code tidak tersedia. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('=== DEBUG: Error saat meminta QR code ===');
      print('Error: $e');

      if (!mounted) return;

      if (e.toString().contains('Waktu tunggu habis')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waktu tunggu habis. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal meminta QR code: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingQr = false;
          _currentQrConnectionId = null;
        });
      }
    }
  }

  Future<void> _handleDisconnect(Connection connection) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Putuskan Koneksi',
        message: 'Apakah Anda yakin ingin memutuskan koneksi ini?',
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );

    if (result == true) {
      try {
        await _connectionService.disconnect(connection.id.toString());
        await _loadConnections();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memutus koneksi: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteConnection(Connection connection) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Hapus Koneksi',
        message: 'Apakah Anda yakin ingin menghapus koneksi ini?',
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );

    if (result == true) {
      try {
        await _connectionService.deleteConnection(connection.id.toString());
        await _loadConnections();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus koneksi: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'CONNECTED':
        return Icons.check_circle;
      case 'DISCONNECTED':
        return Icons.cancel;
      case 'OPENING':
        return Icons.sync;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CONNECTED':
        return Colors.green;
      case 'DISCONNECTED':
        return Colors.red;
      case 'OPENING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'CONNECTED':
        return 'Terhubung';
      case 'DISCONNECTED':
        return 'Terputus';
      case 'OPENING':
        return 'Membuka Koneksi';
      default:
        return status;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koneksi WhatsApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConnections,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 16.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadConnections,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _connections.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum ada koneksi WhatsApp',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: _handleAddConnection,
                            child: const Text('Tambah Koneksi'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadConnections,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16.r),
                        itemCount: _connections.length,
                        itemBuilder: (context, index) {
                          final connection = _connections[index];
                          final isRequestingQr = _isRequestingQr &&
                              _currentQrConnectionId ==
                                  connection.id.toString();

                          return Card(
                            margin: EdgeInsets.only(bottom: 16.h),
                            child: Padding(
                              padding: EdgeInsets.all(16.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getStatusIcon(connection.status),
                                        color:
                                            _getStatusColor(connection.status),
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          connection.name,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (connection.isDefault)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                          ),
                                          child: Text(
                                            'Default',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.green.shade800,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Status: ${_getStatusText(connection.status)}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Terakhir diperbarui: ${_formatDate(connection.lastUpdate?.toIso8601String() ?? '')}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (connection.status == 'DISCONNECTED')
                                        ElevatedButton(
                                          onPressed: isRequestingQr
                                              ? null
                                              : () => _handleRequestQrCode(
                                                  connection),
                                          child: isRequestingQr
                                              ? SizedBox(
                                                  width: 20.w,
                                                  height: 20.h,
                                                  child:
                                                      const CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Text('Coba Lagi'),
                                        ),
                                      if (connection.status == 'OPENING' &&
                                          connection.qrCode != null)
                                        ElevatedButton(
                                          onPressed: () =>
                                              _showQrCodeDialog(connection),
                                          child: const Text('Tampilkan QR'),
                                        ),
                                      if (connection.status == 'CONNECTED')
                                        ElevatedButton(
                                          onPressed: () =>
                                              _handleDisconnect(connection),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                          child: const Text('Putuskan'),
                                        ),
                                      SizedBox(width: 8.w),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        onPressed: () =>
                                            _handleDeleteConnection(connection),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddConnection,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showQrCodeDialog(Connection connection) {
    if (connection.qrCode == null || connection.qrCode!.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Scan QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: QrImageView(
                data: connection.qrCode!,
                version: QrVersions.auto,
                size: 250.0,
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            const Text(
              'Scan QR code ini dengan WhatsApp di perangkat lain untuk menghubungkan',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8.h),
            const CircularProgressIndicator(),
            SizedBox(height: 8.h),
            const Text(
              'Menunggu scan...',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadConnections();
            },
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
