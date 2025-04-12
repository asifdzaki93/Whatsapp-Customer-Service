import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';
import '../widgets/contact_list_item.dart';
import '../widgets/contact_form_modal.dart';
import '../widgets/confirmation_dialog.dart';
import 'dart:async';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _contactService = ContactService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<Contact> _contacts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _searchQuery = '';
  bool _isSearching = false;
  int _totalContacts = 0;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    if (!mounted || _isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _contactService.getContacts(
        page: _currentPage,
        search: _searchQuery,
        limit: 20,
      );

      if (!mounted) return;

      setState(() {
        if (_currentPage == 1) {
          _contacts = result['contacts'];
        } else {
          _contacts.addAll(result['contacts']);
        }
        _hasMore = result['hasMore'];
        _totalContacts = result['total'];
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat kontak: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadContacts();
    }
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query == _searchQuery) return;

    setState(() {
      _searchQuery = query;
      _currentPage = 1;
      _hasMore = true;
      _contacts = [];
      _isSearching = true;
    });

    await _loadContacts();

    if (mounted) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _handleAddContact() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) =>
              ContactFormModal(onClose: () => Navigator.of(context).pop(false)),
    );

    if (result == true) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _contacts = [];
      });
      await _loadContacts();
    }
  }

  Future<void> _handleEditContact(Contact contact) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => ContactFormModal(
            contact: contact,
            onClose: () => Navigator.of(context).pop(false),
          ),
    );

    if (result == true) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _contacts = [];
      });
      await _loadContacts();
    }
  }

  Future<void> _handleDeleteContact(Contact contact) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmationDialog(
            title: 'Hapus Kontak',
            message: 'Apakah Anda yakin ingin menghapus kontak ini?',
            onConfirm: () => Navigator.of(context).pop(true),
          ),
    );

    if (result == true) {
      try {
        await _contactService.deleteContact(contact.id);
        if (!mounted) return;

        setState(() {
          _contacts.removeWhere((c) => c.id == contact.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kontak berhasil dihapus')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus kontak: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleImportContacts() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmationDialog(
            title: 'Impor Kontak',
            message:
                'Apakah Anda yakin ingin mengimpor kontak dari WhatsApp? Proses ini mungkin memakan waktu beberapa menit.',
            onConfirm: () => Navigator.of(context).pop(true),
          ),
    );

    if (result == true) {
      try {
        // Tampilkan loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Text('Mengimpor Kontak'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 16.h),
                    Text(
                      'Mohon tunggu, sedang mengimpor kontak dari WhatsApp...',
                      style: TextStyle(fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
        );

        await _contactService.importContacts();

        // Tutup loading dialog
        if (mounted) {
          Navigator.of(context).pop(); // Tutup loading dialog

          // Refresh list kontak
          setState(() {
            _currentPage = 1;
            _hasMore = true;
            _contacts = [];
          });
          await _loadContacts();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kontak berhasil diimpor'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Tutup loading dialog
        if (mounted) {
          Navigator.of(context).pop(); // Tutup loading dialog

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengimpor kontak: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleExportContacts() async {
    try {
      // Tampilkan loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: const Text('Mengekspor Kontak'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 16.h),
                  Text(
                    'Mohon tunggu, sedang menyiapkan file CSV...',
                    style: TextStyle(fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
      );

      await _contactService.exportContacts(_contacts);

      // Tutup loading dialog
      if (mounted) {
        Navigator.of(context).pop(); // Tutup loading dialog
      }
    } catch (e) {
      // Tutup loading dialog
      if (mounted) {
        Navigator.of(context).pop(); // Tutup loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor kontak: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kontak'),
            Text(
              '$_totalContacts kontak',
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          // Tombol Export
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _handleExportContacts,
            tooltip: 'Ekspor Kontak',
          ),
          // Tombol Import (Sync)
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _handleImportContacts,
            tooltip: 'Sinkronisasi Kontak WhatsApp',
          ),
          // Tombol Add Contact
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _handleAddContact,
            tooltip: 'Tambah Kontak',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(8.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari kontak...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
              ),
              onChanged: (value) {
                _searchDebounce?.cancel();
                _searchDebounce = Timer(
                  const Duration(milliseconds: 500),
                  _handleSearch,
                );
              },
            ),
          ),
          // Contact List
          Expanded(
            child:
                _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _contacts.isEmpty && !_isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64.w,
                            color: theme.colorScheme.tertiary.withOpacity(0.5),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Tidak ada kontak',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: theme.colorScheme.tertiary.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      itemCount: _contacts.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _contacts.length) {
                          return Padding(
                            padding: EdgeInsets.all(16.w),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final contact = _contacts[index];
                        return ContactListItem(
                          key: ValueKey(contact.id),
                          contact: contact,
                          onEdit: () => _handleEditContact(contact),
                          onDelete: () => _handleDeleteContact(contact),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
