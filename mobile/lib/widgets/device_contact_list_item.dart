import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DeviceContactListItem extends StatelessWidget {
  final Contact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DeviceContactListItem({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);

    if (contact.photo != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: contact.photo!.toString(), // Pastikan ini sesuai
          width: 40.w,
          height: 40.w,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 40.w,
            height: 40.w,
            color: theme.colorScheme.primary.withOpacity(0.1),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => _buildInitialsAvatar(theme),
        ),
      );
    }

    return _buildInitialsAvatar(theme);
  }

  Widget _buildInitialsAvatar(ThemeData theme) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          contact.displayName.isNotEmpty
              ? contact.displayName[0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  String _formatPhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[+\-\s]'), '');
    if (phoneNumber.startsWith('0')) {
      phoneNumber = '62' + phoneNumber.substring(1);
    }
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        // TODO: Navigate to message screen
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(context),
            SizedBox(width: 12.w),
            // Contact Info
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.displayName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    contact.phones.isNotEmpty
                        ? _formatPhoneNumber(contact.phones.first.number)
                        : 'Tanpa Nomor Telepon',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: theme.colorScheme.tertiary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // More Options Button
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.tertiary.withOpacity(0.5),
                size: 20.w,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'message':
                    // TODO: Navigate to message screen
                    break;
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'message',
                  child: Row(
                    children: [
                      Icon(Icons.message, color: Colors.green, size: 20.w),
                      SizedBox(width: 8.w),
                      Text('Kirim Pesan'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit,
                          color: theme.colorScheme.secondary, size: 20.w),
                      SizedBox(width: 8.w),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete,
                          color: theme.colorScheme.error, size: 20.w),
                      SizedBox(width: 8.w),
                      Text('Hapus'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
