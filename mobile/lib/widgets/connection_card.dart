import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/connection.dart';

class ConnectionCard extends StatelessWidget {
  final Connection connection;
  final VoidCallback? onRequestQrCode;
  final VoidCallback? onDisconnect;
  final VoidCallback? onDelete;
  final VoidCallback? onStartSession;
  final VoidCallback? onShowQrCode;
  final bool isLoading;

  const ConnectionCard({
    super.key,
    required this.connection,
    this.onRequestQrCode,
    this.onDisconnect,
    this.onDelete,
    this.onStartSession,
    this.onShowQrCode,
    this.isLoading = false,
  });

  IconData _getStatusIcon() {
    switch (connection.status) {
      case 'CONNECTED':
        return Icons.check_circle;
      case 'DISCONNECTED':
        return Icons.cancel;
      case 'qrcode':
        return Icons.qr_code;
      case 'OPENING':
        return Icons.hourglass_empty;
      case 'PENDING':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor() {
    switch (connection.status) {
      case 'CONNECTED':
        return Colors.green;
      case 'DISCONNECTED':
        return Colors.red;
      case 'qrcode':
        return Colors.blue;
      case 'OPENING':
        return Colors.orange;
      case 'PENDING':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 24.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        connection.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        connection.status,
                        style: TextStyle(fontSize: 12.sp, color: statusColor),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (connection.status == 'DISCONNECTED')
                  TextButton.icon(
                    onPressed: isLoading ? null : onStartSession,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Mulai'),
                  ),
                if (connection.status == 'qrcode')
                  TextButton.icon(
                    onPressed: isLoading ? null : onShowQrCode,
                    icon: const Icon(Icons.qr_code),
                    label: const Text('QR Code'),
                  ),
                if (connection.status == 'CONNECTED')
                  TextButton.icon(
                    onPressed: isLoading ? null : onDisconnect,
                    icon: const Icon(Icons.stop),
                    label: const Text('Putuskan'),
                  ),
                SizedBox(width: 8.w),
                IconButton(
                  onPressed: isLoading ? null : onDelete,
                  icon: const Icon(Icons.delete),
                  color: theme.colorScheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
