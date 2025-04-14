import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
//import 'package:fl_chart/fl_chart.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';
import 'contacts_screen.dart';
import 'tickets_screen.dart';
import 'files_screen.dart';
import 'connection_screen.dart';
import 'device_contacts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _dashboardService = DashboardService();
  User? _user;
  bool _isLoading = true;
  DateTime? _companyDueDate;
  Map<String, dynamic> _counters = {};
  List<Map<String, dynamic>> _attendants = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _authService.getCurrentUser();
      print('=== User Data Debug ===');
      print('User: ${user?.toJson()}');
      print('Name: ${user?.name}');
      print('Email: ${user?.email}');
      print('Company: ${user?.company?.name}');
      print('Profile: ${user?.profile}');
      print('=====================');

      final dashboardData = await _dashboardService.getDashboardData();

      print('=== Dashboard Data Debug ===');
      print('User: ${user?.toJson()}');
      print('Dashboard Data: $dashboardData');
      print('Counters: ${dashboardData['counters']}');
      print('Tickets Per Hour: ${dashboardData['counters']['ticketsPerHour']}');
      print('Attendants: ${dashboardData['attendants']}');
      print('Company Due Date: ${dashboardData['companyDueDate']}');
      print('===========================');

      if (mounted) {
        setState(() {
          _user = user;
          _counters = Map<String, dynamic>.from(dashboardData['counters']);
          _attendants = List<Map<String, dynamic>>.from(
            dashboardData['attendants'],
          );
          _companyDueDate = dashboardData['companyDueDate'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('=== Error Loading Dashboard ===');
      print('Error: $e');
      print('=============================');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Tickets
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const TicketsScreen()));
        break;
      case 1: // Contacts
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const ContactsScreen()));
        break;
      case 2: // Features
        _showFeaturesMenu(context);
        break;
      case 3: // More Menu
        _showMoreMenu(context);
        break;
    }
  }

  void _showFeaturesMenu(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.contacts),
              title: const Text('Kontak Perangkat'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DeviceContactsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Jadwal Pesan'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Message Schedule
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Pesan Cepat'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Quick Messages
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Laporan'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Reports
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Settings
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Menu Admin
            if (_user?.profile == 'admin') ...[
              ListTile(
                leading: const Icon(Icons.sync_alt),
                title: const Text('Koneksi'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConnectionScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('File'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FilesScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_tree),
                title: const Text('Antrian'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to Queues
                },
              ),
              ListTile(
                leading: const Icon(Icons.people_alt),
                title: const Text('Pengguna'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to Users
                },
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('API Pesan'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to Messages API
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Keuangan'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to Finance
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120.h,
                    floating: false,
                    pinned: true,
                    backgroundColor: theme.colorScheme.primary,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Navigate to Settings
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.person),
                                    title: const Text('Profil'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      // TODO: Navigate to Profile
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.help_outline,
                                    ),
                                    title: const Text('Bantuan'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      // TODO: Navigate to Help
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.logout),
                                    title: const Text('Keluar'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await _authService.logout();
                                      if (mounted) {
                                        Navigator.of(
                                          context,
                                        ).pushReplacementNamed('/login');
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 8.w),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.zero,
                      title: const SizedBox.shrink(),
                      centerTitle: false,
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            16.w,
                            40.h,
                            16.w,
                            16.h,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24.r,
                                backgroundColor: theme.colorScheme.onPrimary
                                    .withOpacity(0.2),
                                child: Icon(
                                  Icons.person,
                                  color: theme.colorScheme.onPrimary,
                                  size: 24.w,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selamat Datang,',
                                      style: TextStyle(
                                        color: theme.colorScheme.onPrimary
                                            .withOpacity(0.8),
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    Text(
                                      _user?.name ?? 'User',
                                      style: TextStyle(
                                        color: theme.colorScheme.onPrimary,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_user?.email != null) ...[
                                      SizedBox(height: 2.h),
                                      Text(
                                        _user!.email,
                                        style: TextStyle(
                                          color: theme.colorScheme.onPrimary
                                              .withOpacity(0.7),
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                      child: Row(
                        children: [
                          Text(
                            'Pelayanan Hari Ini',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('dd MMM yyyy').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 1.1,
                      ),
                      delegate: SliverChildListDelegate([
                        _buildStatCard(
                          context,
                          'Menunggu',
                          _counters['supportPending'] ?? 0,
                          Icons.hourglass_empty,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          context,
                          'Berlangsung',
                          _counters['supportHappening'] ?? 0,
                          Icons.play_circle_outline,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          context,
                          'Selesai',
                          _counters['supportFinished'] ?? 0,
                          Icons.check_circle_outline,
                          Colors.green,
                        ),
                        _buildStatCard(
                          context,
                          'Kontak Baru',
                          _counters['leads'] ?? 0,
                          Icons.person_add,
                          Colors.purple,
                        ),
                        _buildStatCard(
                          context,
                          'Waktu Layanan',
                          _formatTime(_counters['avgSupportTime'] ?? 0),
                          Icons.timer,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          context,
                          'Waktu Tunggu',
                          _formatTime(_counters['avgWaitTime'] ?? 0),
                          Icons.access_time,
                          Colors.orange,
                        ),
                      ]),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                      child: Text(
                        'Daftar CS',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(16.w),
                    sliver: SliverToBoxAdapter(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Column(
                            children: [
                              ..._attendants.map((attendant) {
                                final avgTime = attendant['avgTime'] ?? 0;
                                final status = attendant['status'] ?? 'offline';
                                final rating = attendant['rating'] ?? 0;
                                final statusColor = status == 'online'
                                    ? Colors.green
                                    : status == 'busy'
                                        ? Colors.orange
                                        : Colors.grey;

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16.r,
                                        backgroundColor:
                                            statusColor.withOpacity(0.1),
                                        child: Icon(
                                          Icons.person,
                                          size: 16.w,
                                          color: statusColor,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  attendant['name'] ??
                                                      'Unknown',
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: List.generate(5, (
                                                    index,
                                                  ) {
                                                    return Icon(
                                                      index < rating
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      size: 14.w,
                                                      color: Colors.amber,
                                                    );
                                                  }),
                                                ),
                                                SizedBox(width: 4.w),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6.w,
                                                    vertical: 2.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      12.r,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    rating.toString(),
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: Colors.amber,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.timer_outlined,
                                                      size: 12.w,
                                                      color: theme
                                                          .colorScheme.tertiary,
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Text(
                                                      _formatTime(avgTime),
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: theme.colorScheme
                                                            .tertiary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w,
                                                    vertical: 2.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: statusColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      12.r,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 6.w,
                                                        height: 6.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: statusColor,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      ),
                                                      SizedBox(width: 4.w),
                                                      Text(
                                                        status == 'online'
                                                            ? 'Online'
                                                            : status == 'busy'
                                                                ? 'Sibuk'
                                                                : 'Offline',
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: statusColor,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.tertiary,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Kontak'),
          BottomNavigationBarItem(
            icon: Icon(Icons.featured_play_list),
            label: 'Fitur',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    dynamic value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18.w),
          SizedBox(height: 4.h),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: theme.colorScheme.tertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }
}
