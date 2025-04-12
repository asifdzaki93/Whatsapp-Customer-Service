import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/contact.dart';

class ContactListItem extends StatelessWidget {
  final Contact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContactListItem({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);

    if (contact.profilePicUrl != null && contact.profilePicUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: contact.profilePicUrl!,
          width: 40.w,
          height: 40.w,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
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
          memCacheWidth: 80, // Optimasi ukuran cache
          memCacheHeight: 80,
          maxWidthDiskCache: 80,
          maxHeightDiskCache: 80,
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
          contact.name[0].toUpperCase(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        // TODO: Navigate to message screen
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => MessageScreen(contact: contact),
        //   ),
        // );
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
                    contact.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    contact.number,
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
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => MessageScreen(contact: contact),
                    //   ),
                    // );
                    break;
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder:
                  (BuildContext context) => [
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
                          Icon(
                            Icons.edit,
                            color: theme.colorScheme.secondary,
                            size: 20.w,
                          ),
                          SizedBox(width: 8.w),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: theme.colorScheme.error,
                            size: 20.w,
                          ),
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
