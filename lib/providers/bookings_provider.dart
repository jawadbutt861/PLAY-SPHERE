import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/booking_service.dart';

/// User bookings stream + booked-slots cache.
/// Eliminates repeated Firestore calls when user opens booking dialog multiple times.
class BookingsProvider extends ChangeNotifier {
  final String uid;

  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;
  StreamSubscription? _sub;

  // Cache: groundId+date -> booked slots list
  final Map<String, List<String>> _slotsCache = {};

  List<Map<String, dynamic>> get bookings => _bookings;
  bool get loading => _loading;

  List<Map<String, dynamic>> get regularBookings =>
      _bookings.where((b) => b['isTournament'] != true).toList();

  List<Map<String, dynamic>> get tournamentBookings =>
      _bookings.where((b) => b['isTournament'] == true).toList();

  BookingsProvider({required this.uid}) {
    _listen();
  }

  void _listen() {
    _sub?.cancel();
    _loading = true;
    _sub = BookingService.getUserBookings(uid).listen(
      (bookings) {
        final now = DateTime.now();
        _bookings = bookings.where((b) {
          final status = b['status'] as String? ?? '';
          // cancelled aur rejected — history mein jayenge, active list mein nahi
          if (status == 'cancelled' || status == 'rejected') return false;
          if (b['isTournament'] == true) return true;
          // pending bookings hamesha dikhao
          if (status == 'pending') return true;
          final endTime = BookingService.slotEndTime(
              b['date'] as String? ?? '', b['slot'] as String? ?? '');
          if (endTime == null) return true;
          return now.isBefore(endTime);
        }).toList();
        _loading = false;
        notifyListeners();
      },
      onError: (_) {
        _loading = false;
        notifyListeners();
      },
    );
  }

  /// Returns cached booked slots, fetches from Firestore only on cache miss.
  Future<List<String>> getBookedSlots(String groundId, String date) async {
    final key = '$groundId|$date';
    if (_slotsCache.containsKey(key)) return _slotsCache[key]!;
    final slots = await BookingService.getBookedSlots(groundId, date);
    _slotsCache[key] = slots;
    return slots;
  }

  /// Invalidate cache for a ground+date after a new booking is made.
  void invalidateSlots(String groundId, String date) {
    _slotsCache.remove('$groundId|$date');
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
