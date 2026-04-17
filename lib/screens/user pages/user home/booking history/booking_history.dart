import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../main.dart';
import '../../../../services/booking_service.dart';

class BookingHistory extends StatefulWidget {
  const BookingHistory({super.key});

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _sub = BookingService.getUserBookings(_uid).listen((list) {
        if (mounted) {
          // Completed aur cancelled — history mein dikhao
          final history = list
              .where((b) =>
                  b['status'] == 'completed' || b['status'] == 'cancelled')
              .toList();
          setState(() {
            _bookings = history;
            _loading = false;
          });
        }
      }, onError: (_) {
        if (mounted) setState(() => _loading = false);
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const ModernAppBar(title: 'Booking History'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded,
                          size: 64, color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text('No booking history',
                          style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Text('Your past bookings will appear here',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    final imageUrls =
                        (booking['imageUrls'] as List?)?.cast<String>() ?? [];
                    final status = booking['status'] as String? ?? 'completed';
                    final isCancelled = status == 'cancelled';

                    return ModernCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(20)),
                            child: SizedBox(
                              width: 90,
                              height: 100,
                              child: imageUrls.isNotEmpty
                                  ? Image.network(imageUrls.first,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _placeholder(colorScheme))
                                  : _placeholder(colorScheme),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking['groundName'] ?? 'Unknown Venue',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  _row(Icons.category_outlined,
                                      booking['groundCategory'] ?? '', theme),
                                  _row(Icons.calendar_today_outlined,
                                      booking['date'] ?? '', theme),
                                  _row(Icons.access_time_outlined,
                                      booking['slot'] ?? '', theme),
                                  _row(Icons.payment_outlined,
                                      booking['payment'] ?? '', theme),
                                  if (booking['price'] != null)
                                    _row(Icons.attach_money_rounded,
                                        'PKR ${booking['price']}', theme,
                                        color: const Color(0xFF34C759)),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isCancelled
                                  ? AppTheme.errorColor.withValues(alpha: 0.15)
                                  : AppTheme.primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isCancelled ? 'Cancelled' : 'Completed',
                              style: TextStyle(
                                color: isCancelled
                                    ? AppTheme.errorColor
                                    : AppTheme.primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _placeholder(ColorScheme c) => Container(
      color: c.surfaceContainerHighest,
      child: Icon(Icons.sports, color: c.onSurfaceVariant, size: 36));

  Widget _row(IconData icon, String text, ThemeData theme, {Color? color}) =>
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(children: [
          Icon(icon, size: 13, color: color ?? AppTheme.primaryColor),
          const SizedBox(width: 4),
          Expanded(
              child: Text(text,
                  style:
                      theme.textTheme.bodySmall?.copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        ]),
      );
}
