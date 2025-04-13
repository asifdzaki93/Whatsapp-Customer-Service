import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/device_contact_list_item.dart';

class DeviceContactsScreen extends StatefulWidget {
  const DeviceContactsScreen({super.key});

  @override
  _DeviceContactsScreenState createState() => _DeviceContactsScreenState();
}

class _DeviceContactsScreenState extends State<DeviceContactsScreen> {
  List<Contact>? _contacts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } else if (status.isDenied) {
      status = await Permission.contacts.request();
      if (status.isGranted) {
        final contacts =
            await FlutterContacts.getContacts(withProperties: true);
        setState(() {
          _contacts = contacts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin akses kontak ditolak')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin akses kontak ditolak')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontak Perangkat'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts == null || _contacts!.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada kontak',
                    style: TextStyle(color: theme.colorScheme.tertiary),
                  ),
                )
              : ListView.builder(
                  itemCount: _contacts!.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts![index];
                    return DeviceContactListItem(
                      key: ValueKey(contact.id),
                      contact: contact,
                      onEdit: () {
                        // Tambahkan logika untuk mengedit kontak jika diperlukan
                      },
                      onDelete: () {
                        // Tambahkan logika untuk menghapus kontak jika diperlukan
                      },
                    );
                  },
                ),
    );
  }
}
