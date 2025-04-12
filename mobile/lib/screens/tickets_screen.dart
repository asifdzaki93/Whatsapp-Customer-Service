import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/ticket.dart';
import '../models/queue.dart' as queue_model;
import '../services/ticket_service.dart';
import '../services/queue_service.dart';
import '../widgets/ticket_card.dart';
import 'ticket_detail_screen.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final _ticketService = TicketService();
  final _queueService = QueueService();
  List<Ticket> _tickets = [];
  List<queue_model.Queue> _queues = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  final _scrollController = ScrollController();
  String _searchQuery = '';
  String _selectedStatus = 'pending';
  int _selectedTab = 1;
  bool _showAll = false;
  int? _selectedQueueId;
  bool _isLoadingMore = false;
  int _pendingCount = 0;
  int _openCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQueues();
    _loadTickets();
    _loadCounts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadQueues() async {
    try {
      final queues = await _queueService.getQueues();
      setState(() {
        _queues = queues;
      });
    } catch (e) {
      print('Error loading queues: $e');
    }
  }

  void _preloadProfileImages(List<Ticket> tickets) {
    for (var ticket in tickets) {
      if (ticket.contact?.profilePicUrl != null) {
        precacheImage(
          CachedNetworkImageProvider(ticket.contact!.profilePicUrl!),
          context,
        );
      }
    }
  }

  Future<void> _loadTickets({bool refresh = false}) async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 1;
        _tickets = [];
      }
    });

    try {
      final tickets = await _ticketService.getTickets(
        page: _currentPage,
        search: _searchQuery,
        status: _selectedStatus,
        queueId: _selectedQueueId,
        showAll: _showAll,
      );

      _preloadProfileImages(tickets);

      setState(() {
        if (refresh) {
          _tickets = tickets;
        } else {
          final newTickets =
              tickets
                  .where(
                    (ticket) =>
                        !_tickets.any(
                          (existingTicket) => existingTicket.id == ticket.id,
                        ),
                  )
                  .toList();
          _tickets.addAll(newTickets);
        }
        _hasMore = tickets.length == 20;
        _currentPage++;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _loadCounts() async {
    try {
      final counts = await _ticketService.getTicketCounts();
      setState(() {
        _pendingCount = counts['pending'] ?? 0;
        _openCount = counts['open'] ?? 0;
      });
    } catch (e) {
      print('Error loading counts: $e');
    }
  }

  Future<void> _reopenTicket(Ticket ticket) async {
    try {
      await _ticketService.updateTicketStatus(ticket.id, 'open');
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _tickets = [];
      });
      await _loadTickets(refresh: true);
      await _loadCounts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _closeTicket(Ticket ticket) async {
    try {
      await _ticketService.updateTicketStatus(ticket.id, 'closed');
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _tickets = [];
      });
      await _loadTickets(refresh: true);
      await _loadCounts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore && !_isLoading) {
        _loadTickets();
        _isLoadingMore = true;
      }
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTab = index;
      _currentPage = 1;
      _hasMore = true;
      _tickets = [];
      switch (index) {
        case 0:
          _selectedStatus = 'open';
          break;
        case 1:
          _selectedStatus = 'pending';
          break;
        case 2:
          _selectedStatus = 'closed';
          break;
      }
    });
    _loadTickets(refresh: true);
  }

  void _showQueueFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Antrian',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: ListTile(
                      title: Text('Semua Antrian'),
                      leading: Icon(Icons.list),
                      onTap: () {
                        setState(() {
                          _selectedQueueId = null;
                          _currentPage = 1;
                          _hasMore = true;
                          _tickets = [];
                        });
                        _loadTickets(refresh: true);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    constraints: BoxConstraints(maxHeight: 300.h),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _queues.length,
                      itemBuilder: (context, index) {
                        final queue = _queues[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: ListTile(
                            title: Text(queue.name),
                            leading: Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: Color(
                                  int.parse(
                                    queue.color.replaceAll('#', '0xFF'),
                                  ),
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedQueueId = queue.id;
                                _currentPage = 1;
                                _hasMore = true;
                                _tickets = [];
                              });
                              _loadTickets(refresh: true);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final ticketDate = DateTime(date.year, date.month, date.day);

    if (ticketDate == today) {
      return 'Hari ini';
    } else if (ticketDate == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat('EEEE, d MMMM y', 'id_ID').format(date);
    }
  }

  Widget _buildDateHeader(DateTime date) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          _getDateHeader(date),
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(int count, Color color) {
    if (count == 0) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      constraints: BoxConstraints(minWidth: 20.w, minHeight: 20.w),
      child: Center(
        child: Text(
          count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int count,
    required Color badgeColor,
  }) {
    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon),
          if (count > 0)
            Positioned(
              right: -8.w,
              top: -8.h,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2.w,
                  ),
                ),
                constraints: BoxConstraints(minWidth: 20.w, minHeight: 20.w),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      label: label,
    );
  }

  Widget _buildTicketsList() {
    if (_tickets.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64.w,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Tidak ada pesan',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
      );
    }

    DateTime? currentDate;
    List<Widget> items = [];

    for (int i = 0; i < _tickets.length; i++) {
      final ticket = _tickets[i];
      if (ticket.updatedAt != null) {
        final ticketDate = DateTime(
          ticket.updatedAt!.year,
          ticket.updatedAt!.month,
          ticket.updatedAt!.day,
        );

        if (currentDate == null || currentDate != ticketDate) {
          currentDate = ticketDate;
          items.add(_buildDateHeader(ticketDate));
        }
      }

      items.add(
        Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketDetailScreen(ticket: ticket),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28.r,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        child:
                            ticket.contact?.profilePicUrl != null
                                ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: ticket.contact!.profilePicUrl!,
                                    width: 56.w,
                                    height: 56.w,
                                    fit: BoxFit.cover,
                                    memCacheWidth: 112,
                                    memCacheHeight: 112,
                                    maxWidthDiskCache: 112,
                                    maxHeightDiskCache: 112,
                                    fadeInDuration: Duration(milliseconds: 200),
                                    fadeOutDuration: Duration(
                                      milliseconds: 200,
                                    ),
                                    imageBuilder:
                                        (context, imageProvider) => Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                    placeholder:
                                        (context, url) => Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                          ),
                                          child: Center(
                                            child: SizedBox(
                                              width: 20.w,
                                              height: 20.w,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.w,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Text(
                                          ticket.contact?.name
                                                  .substring(0, 1)
                                                  .toUpperCase() ??
                                              '?',
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                        ),
                                  ),
                                )
                                : Text(
                                  ticket.contact?.name
                                          .substring(0, 1)
                                          .toUpperCase() ??
                                      '?',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ticket.contact?.name ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _formatTime(ticket.updatedAt),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ticket.lastMessage ?? 'No message',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (ticket.status == 'pending')
                                  Container(
                                    width: 8.w,
                                    height: 8.w,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (ticket.status == 'closed')
                Positioned(
                  right: 8.w,
                  top: 18.h,
                  child: IconButton(
                    onPressed: () => _reopenTicket(ticket),
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18.sp,
                    ),
                    tooltip: 'Buka Ulang',
                    constraints: BoxConstraints(
                      minWidth: 24.w,
                      minHeight: 24.w,
                      maxWidth: 24.w,
                      maxHeight: 24.w,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              if (ticket.status == 'open')
                Positioned(
                  right: 8.w,
                  top: 18.h,
                  child: IconButton(
                    onPressed: () => _closeTicket(ticket),
                    icon: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18.sp,
                    ),
                    tooltip: 'Selesai',
                    constraints: BoxConstraints(
                      minWidth: 24.w,
                      minHeight: 24.w,
                      maxWidth: 24.w,
                      maxHeight: 24.w,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (_hasMore) {
      items.add(
        Center(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'open':
        return 'Dilayani';
      case 'closed':
        return 'Selesai';
      default:
        return status;
    }
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'No time';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // AppBar
          Container(
            color: theme.colorScheme.primary,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    Text(
                      'Antrian Pesan',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    Spacer(),
                    // Toggle Show All
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Semua',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: _showAll,
                              onChanged: (value) {
                                setState(() {
                                  _showAll = value;
                                  _currentPage = 1;
                                  _hasMore = true;
                                });
                                _loadTickets(refresh: true);
                              },
                              activeColor: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Search Bar and Filter
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: theme.colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari pesan...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.tertiary,
                          size: 20.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _currentPage = 1;
                          _hasMore = true;
                        });
                        _loadTickets(refresh: true);
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  height: 40.h,
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: theme.colorScheme.tertiary,
                      size: 20.sp,
                    ),
                    onPressed: _showQueueFilterDialog,
                  ),
                ),
              ],
            ),
          ),
          // Tickets List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadTickets(refresh: true);
              },
              child: _buildTicketsList(),
            ),
          ),
          // Bottom Navigation Bar
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedTab,
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor: theme.colorScheme.tertiary,
              items: [
                _buildBottomNavItem(
                  icon: Icons.headset_mic,
                  label: 'Dilayani',
                  count: _openCount,
                  badgeColor: Colors.green,
                ),
                _buildBottomNavItem(
                  icon: Icons.hourglass_empty,
                  label: 'Menunggu',
                  count: _pendingCount,
                  badgeColor: Colors.red,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle),
                  label: 'Selesai',
                ),
              ],
              onTap: _onTabChanged,
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 56.h),
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Create new ticket
          },
          child: Icon(Icons.message),
        ),
      ),
    );
  }
}
