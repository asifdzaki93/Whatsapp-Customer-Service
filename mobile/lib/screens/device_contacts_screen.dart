import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class DeviceContactsScreen extends StatefulWidget {
  const DeviceContactsScreen({super.key});

  @override
  _DeviceContactsScreenState createState() => _DeviceContactsScreenState();
}

class _DeviceContactsScreenState extends State<DeviceContactsScreen> {
  List<Contact>? _contacts;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    // Memeriksa izin akses kontak
    if (await FlutterContacts.requestPermission()) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
      });
    } else {
      // Tampilkan pesan jika izin tidak diberikan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin akses kontak ditolak')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontak Perangkat'),
      ),
      body: _contacts == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _contacts!.length,
              itemBuilder: (context, index) {
                final contact = _contacts![index];
                return ListTile(
                  title: Text(contact.displayName),
                  subtitle: Text(contact.phones.isNotEmpty
                      ? contact.phones.first.number
                      : 'Tanpa Nomor Telepon'),
                );
              },
            ),
    );
  }
}
