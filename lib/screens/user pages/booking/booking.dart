import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../services/booking_service.dart';
import '../../../providers/bookings_provider.dart';
import '../../booking_chat_screen.dart';

class Booked extends StatefulWidget {
  const Booked({super.key});

  @override
  State<Booked> createState() => _BookedState();
}

class _BookedState extends State<Booked> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _expandedTournaments = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, List<Map<String, dynamic>>> _groupedTournamentBookings(
      List<Map<String, dynamic>> tournamentBookings) {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final b in tournamentBookings) {
      final tid = b['tournamentId'] as String? ?? 'Unknown Tournament';
      map.putIfAbsent(tid, () => []).add(b);
    }
    return map;
  }
  Future<void> _deleteBooking(Map<String, dynamic> booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.delete_outline_rounded, color: Colors.red),
          SizedBox(width: 10),
          Text('Remove Booking'),
        ]),
        content: const Text('Remove this booking from your list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('No', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final id = booking['id'] as String?;
    if (id != null && id.isNotEmpty) {
      await BookingService.deleteBooking(id);
    }
  }

  Future<void> _confirmCancel(Map<String, dynamic> booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.cancel_outlined, color: Colors.red),
          SizedBox(width: 10),
          Text('Cancel Booking'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this booking?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(booking['groundName'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Date: ${booking['date'] ?? ''}',
                    style: Theme.of(ctx).textTheme.bodySmall),
                Text('Slot: ${booking['slot'] ?? ''}',
                    style: Theme.of(ctx).textTheme.bodySmall),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('No, Keep it', style: TextStyle(color: Colors.grey[600])),
          ),
          GradientButton(
            text: 'Yes, Cancel',
            gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            textStyle: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final bookingId = booking['id'] as String?;
    if (bookingId != null && bookingId.isNotEmpty) {
      await BookingService.cancelBooking(bookingId);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Booking cancelled successfully'),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<BookingsProvider>();
    final regularBookings = provider.regularBookings;
    final tournamentBookings = provider.tournamentBookings;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: [
                Tab(
                  icon: const Icon(Icons.event_available_rounded),
                  text: 'Bookings (${regularBookings.length})',
                ),
                Tab(
                  icon: const Icon(Icons.emoji_events_rounded),
                  text: 'Tournament (${tournamentBookings.length})',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRegularList(regularBookings),
                _buildTournamentList(tournamentBookings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Regular bookings flat list ──────────────────────────
  Widget _buildRegularList(List<Map<String, dynamic>> bookings) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded,
                size: 64, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No bookings yet',
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Book a venue to see it here',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (_, i) => _bookingCard(bookings[i], canCancel: true),
    );
  }

  // ── Tournament bookings grouped + collapsible ──────────
  Widget _buildTournamentList(List<Map<String, dynamic>> tournamentBookings) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final grouped = _groupedTournamentBookings(tournamentBookings);

    if (grouped.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined,
                size: 64, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No tournament bookings',
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Create a tournament to book grounds',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        final tid = entry.key;
        final tBookings = entry.value;
        final tournamentName = tBookings.first['tournamentName'] as String? ??
            tBookings.first['tournamentId'] as String? ??
            'Tournament';
        final sport = tBookings.first['groundCategory'] as String? ?? '';
        final cancelled = tBookings.every((b) => b['status'] == 'cancelled');
        final isExpanded = _expandedTournaments.contains(tid);

        return ModernCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Collapsible header
              InkWell(
                borderRadius: isExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(20))
                    : BorderRadius.circular(20),
                onTap: () => setState(() {
                  if (isExpanded) { _expandedTournaments.remove(tid); }
                  else { _expandedTournaments.add(tid); }
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: cancelled
                        ? const LinearGradient(
                            colors: [Color(0xFF9E9E9E), Color(0xFF757575)])
                        : AppTheme.primaryGradient,
                    borderRadius: isExpanded
                        ? const BorderRadius.vertical(
                            top: Radius.circular(20))
                        : BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    const Icon(Icons.emoji_events_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tournamentName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          if (sport.isNotEmpty)
                            Text(sport,
                                style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.85),
                                    fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cancelled
                            ? 'Cancelled'
                            : '${tBookings.length} slot${tBookings.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.white),
                  ]),
                ),
              ),
              // Expanded booking cards
              if (isExpanded)
                ...tBookings.map((b) {
                  final bStatus = b['status'] as String? ?? '';
                  final canDelete = bStatus == 'cancelled' || bStatus == 'completed';
                  return Stack(
                    children: [
                      _bookingCard(b, canCancel: false),
                      if (canDelete)
                        Positioned(
                          top: 6, right: 6,
                          child: GestureDetector(
                            onTap: () => _deleteBooking(b),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Single booking card ─────────────────────────────────
  Widget _bookingCard(Map<String, dynamic> booking, {required bool canCancel}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final groundName = booking['groundName'] as String? ?? '';
    final groundCategory = booking['groundCategory'] as String? ?? '';
    final imageUrls =
        (booking['imageUrls'] as List?)?.cast<String>() ?? [];
    final status = booking['status'] as String? ?? 'pending';
    final isCancelled = status == 'cancelled';
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';

    Color statusColor;
    String statusLabel;
    if (isPending) {
      statusColor = AppTheme.warningColor;
      statusLabel = 'Pending';
    } else if (isRejected) {
      statusColor = AppTheme.errorColor;
      statusLabel = 'Rejected';
    } else if (isCancelled) {
      statusColor = AppTheme.errorColor;
      statusLabel = 'Cancelled';
    } else if (status == 'completed') {
      statusColor = AppTheme.primaryColor;
      statusLabel = 'Completed';
    } else {
      statusColor = AppTheme.successColor;
      statusLabel = 'Confirmed';
    }
    final price = booking['price'];

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      child: Row(children: [
        ClipRRect(
          borderRadius:
              const BorderRadius.horizontal(left: Radius.circular(20)),
          child: SizedBox(
            width: 85,
            height: 115,
            child: imageUrls.isNotEmpty
                ? Image.network(imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(colorScheme))
                : _placeholder(colorScheme),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(groundName,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 2),
                if (groundCategory.isNotEmpty)
                  _infoRow(Icons.category_outlined, groundCategory, theme),
                _infoRow(Icons.calendar_today_outlined,
                    booking['date'] ?? '', theme),
                _infoRow(Icons.access_time_outlined,
                    booking['slot'] ?? '', theme),
                _infoRow(Icons.payment_outlined,
                    booking['payment'] ?? '', theme),
                if (price != null)
                  _infoRow(Icons.attach_money_rounded, 'PKR $price', theme,
                      color: const Color(0xFF34C759)),
              ],
            ),
          ),
        ),
        if (canCancel && status == 'confirmed')
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              onPressed: () => _confirmCancel(booking),
            ),
          ),
        // Chat button
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded,
                color: AppTheme.primaryColor),
            onPressed: () {
              final id = booking['id'] as String? ?? '';
              if (id.isEmpty) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingChatScreen(
                    bookingId: id,
                    booking: booking,
                    isManager: false,
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _placeholder(ColorScheme c) => Container(
      color: c.surfaceContainerHighest,
      child: Icon(Icons.sports, color: c.onSurfaceVariant, size: 36));

  Widget _infoRow(IconData icon, String text, ThemeData theme,
          {Color? color}) =>
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(children: [
          Icon(icon, size: 12, color: color ?? AppTheme.primaryColor),
          const SizedBox(width: 4),
          Expanded(
              child: Text(text,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontSize: 11, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        ]),
      );
}
