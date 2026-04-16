import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../main.dart';
import '../../../services/booking_service.dart';
import '../../../services/cancellation_service.dart';

class Booked extends StatefulWidget {
  const Booked({super.key});

  @override
  State<Booked> createState() => _BookedState();
}

class _BookedState extends State<Booked> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _firestoreBookings = [];
  StreamSubscription? _sub;
  final Set<String> _expandedTournaments = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (_uid != null) {
      _sub = BookingService.getUserBookings(_uid).listen((bookings) {
        if (mounted) {
          final now = DateTime.now();
          final active = bookings.where((b) {
            final status = b['status'] as String? ?? '';
            // Cancelled bookings hide karo
            if (status == 'cancelled') return false;
            // Tournament bookings hamesha dikhao (jab tak cancelled nahi)
            if (b['isTournament'] == true) return true;
            // Regular bookings: expired slot remove karo
            final endTime = BookingService.slotEndTime(
                b['date'] as String? ?? '', b['slot'] as String? ?? '');
            if (endTime == null) return true;
            return now.isBefore(endTime);
          }).toList();
          setState(() => _firestoreBookings = active);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sub?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> get _regularBookings =>
      _firestoreBookings.where((b) => b['isTournament'] != true).toList();

  List<Map<String, dynamic>> get _tournamentBookings =>
      _firestoreBookings.where((b) => b['isTournament'] == true).toList();

  /// Tournament bookings ko tournamentId ke hisaab se group karo
  Map<String, List<Map<String, dynamic>>> get _groupedTournamentBookings {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final b in _tournamentBookings) {
      final tid = b['tournamentId'] as String? ?? 'Unknown Tournament';
      map.putIfAbsent(tid, () => []).add(b);
    }
    return map;
  }
  Future<void> _deleteBooking(Map<String, dynamic> booking) async {
    final date = booking['date'] as String? ?? '';
    final slot = booking['slot'] as String? ?? '';
    final price = (booking['price'] as num?)?.toInt();
    final policy = CancellationService.checkPolicy(date, slot);

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
            if (!policy.canCancel)
              Text(policy.message,
                  style: const TextStyle(color: Colors.red))
            else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: policy.refundColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: policy.refundColor.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  Icon(Icons.info_outline_rounded,
                      color: policy.refundColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(policy.refundLabel,
                            style: TextStyle(
                                color: policy.refundColor,
                                fontWeight: FontWeight.bold)),
                        Text(policy.message,
                            style: const TextStyle(fontSize: 12)),
                        if (price != null && policy.refundPercent > 0)
                          Text(
                            'Refund: Rs. ${((price * policy.refundPercent) / 100).round()}',
                            style: TextStyle(
                                color: policy.refundColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              const Text('Are you sure you want to cancel?'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('No', style: TextStyle(color: Colors.grey[600])),
          ),
          if (policy.canCancel)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cancel Booking'),
            ),
        ],
      ),
    );

    if (confirmed != true) return;
    final id = booking['id'] as String?;
    if (id != null && id.isNotEmpty) {
      await CancellationService.cancelBooking(
        bookingId: id,
        date: date,
        slot: slot,
        paidPrice: price,
      );
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 48),
        child: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text('My Bookings',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: [
                Tab(
                  icon: const Icon(Icons.event_available_rounded),
                  text: 'Bookings (${_regularBookings.length})',
                ),
                Tab(
                  icon: const Icon(Icons.emoji_events_rounded),
                  text: 'Tournament (${_tournamentBookings.length})',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRegularList(),
          _buildTournamentList(),
        ],
      ),
    );
  }

  // ── Regular bookings flat list ──────────────────────────
  Widget _buildRegularList() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bookings = _regularBookings;

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
  Widget _buildTournamentList() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final grouped = _groupedTournamentBookings;

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
    final status = booking['status'] as String? ?? 'confirmed';
    final isCancelled = status == 'cancelled';
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
                    errorBuilder: (_, __, ___) => _placeholder(colorScheme))
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
                      color: isCancelled
                          ? AppTheme.errorColor.withValues(alpha: 0.15)
                          : AppTheme.successColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isCancelled ? 'Cancelled' : 'Confirmed',
                      style: TextStyle(
                        color: isCancelled
                            ? AppTheme.errorColor
                            : AppTheme.successColor,
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
        if (canCancel && !isCancelled)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              onPressed: () => _confirmCancel(booking),
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
