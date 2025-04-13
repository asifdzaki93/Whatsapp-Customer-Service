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
  List<Contact>? _filteredContacts;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchContacts();
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchContacts() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
        _filteredContacts =
            contacts; // Set filtered contacts to all contacts initially
        _isLoading = false;
      });
    } else if (status.isDenied) {
      status = await Permission.contacts.request();
      if (status.isGranted) {
        final contacts =
            await FlutterContacts.getContacts(withProperties: true);
        setState(() {
          _contacts = contacts;
          _filteredContacts = contacts; // Set filtered contacts to all contacts
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

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts?.where((contact) {
        return contact.displayName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontak Perangkat'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari kontak...',
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContacts == null || _filteredContacts!.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada kontak',
                          style: TextStyle(color: theme.colorScheme.tertiary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredContacts!.length,
                        itemBuilder: (context, index) {
                          final contact = _filteredContacts![index];
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
          ),
        ],
      ),
    );
  }
}
