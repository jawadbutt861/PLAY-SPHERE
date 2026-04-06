import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class BookingService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'bookings';

  /// New booking save karo Firestore mein
  static Future<String?> createBooking({
    required String groundId,
    required String groundName,
    required String groundCategory,
    required String managerId,
    required String userId,
    required String userEmail,
    required String userName,
    required String date,
    required String slot,
    required String payment,
    required List<String> imageUrls,
    int? price,
    String? tournamentId,
    String? tournamentName,
  }) async {
    try {
      final doc = await _db.collection(_col).add({
        'groundId': groundId,
        'groundName': groundName,
        'groundCategory': groundCategory,
        'managerId': managerId,
        'userId': userId,
        'userEmail': userEmail,
        'userName': userName,
        'date': date,
        'slot': slot,
        'payment': payment,
        'imageUrls': imageUrls,
        'status': 'confirmed',
        if (price != null) 'price': price,
        if (tournamentId != null) 'tournamentId': tournamentId,
        if (tournamentName != null) 'tournamentName': tournamentName,
        if (tournamentId != null) 'isTournament': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Tournament bookings ke liye individual notifications skip karo
      if (tournamentId == null) {
        // Manager ko notification bhejo
        if (managerId.isNotEmpty) {
          await NotificationService.sendBookingNotification(
            managerId: managerId,
            groundName: groundName,
            userName: userName.isNotEmpty ? userName : userEmail,
            date: date,
            slot: slot,
          );
        }
        // User ko booking confirm notification bhejo
        if (userId.isNotEmpty) {
          await NotificationService.sendBookingConfirmedNotification(
            userId: userId,
            groundName: groundName,
            date: date,
            slot: slot,
          );
        }
      }

      return doc.id;
    } catch (e) {
      debugPrint('BookingService ERROR: $e');
      return null;
    }
  }

  /// Ground data ko booking mein merge karo (live update)
  static Future<void> _mergeGroundData(List<Map<String, dynamic>> bookings) async {
    // Unique groundIds collect karo
    final groundIds = bookings
        .map((b) => b['groundId'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    if (groundIds.isEmpty) return;

    // Har ground ka latest data fetch karo
    final groundMap = <String, Map<String, dynamic>>{};
    for (final gid in groundIds) {
      try {
        final doc = await _db.collection('grounds').doc(gid).get();
        if (doc.exists) groundMap[gid] = {...doc.data()!, 'id': doc.id};
      } catch (_) {}
    }

    // Bookings mein merge karo
    for (final b in bookings) {
      final gid = b['groundId'] as String? ?? '';
      final ground = groundMap[gid];
      if (ground != null) {
        b['groundName'] = ground['name'] ?? b['groundName'];
        b['groundCategory'] = ground['category'] ?? b['groundCategory'];
        b['imageUrls'] = ground['imageUrls'] ?? b['imageUrls'];
      }
    }
  }

  /// Manager ke grounds ki bookings (real-time) — client-side sort to avoid composite index
  static Stream<List<Map<String, dynamic>>> getManagerBookings(String managerId) {
    return _db
        .collection(_col)
        .where('managerId', isEqualTo: managerId)
        .snapshots()
        .asyncMap((s) async {
      final list = s.docs.map((d) => {...d.data(), 'id': d.id}).toList();
      list.sort((a, b) {
        final ta = a['createdAt'];
        final tb = b['createdAt'];
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        try {
          return (tb as dynamic).toDate().compareTo((ta as dynamic).toDate());
        } catch (_) { return 0; }
      });
      await _mergeGroundData(list);
      _markExpiredInList(list);
      return list;
    });
  }

  /// Aaj ki bookings for manager (confirmed + completed)
  static Stream<List<Map<String, dynamic>>> getTodayBookings(String managerId) {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return _db
        .collection(_col)
        .where('managerId', isEqualTo: managerId)
        .where('date', isEqualTo: dateStr)
        .snapshots()
        .asyncMap((s) async {
      final list = s.docs
          .map((d) => {...d.data(), 'id': d.id})
          .where((b) => b['status'] != 'cancelled')
          .toList();
      await _mergeGroundData(list);
      _markExpiredInList(list);
      return list;
    });
  }

  /// User ki bookings
  static Stream<List<Map<String, dynamic>>> getUserBookings(String userId) {
    return _db
        .collection(_col)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((s) async {
      final list = s.docs.map((d) => {...d.data(), 'id': d.id}).toList();
      list.sort((a, b) {
        final ta = a['createdAt'];
        final tb = b['createdAt'];
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        try {
          return (tb as dynamic).toDate().compareTo((ta as dynamic).toDate());
        } catch (_) { return 0; }
      });
      await _mergeGroundData(list);
      _markExpiredInList(list);
      return list;
    });
  }

  /// Kisi bhi booking list mein expired confirmed bookings ko Firestore mein complete mark karo
  static void _markExpiredInList(List<Map<String, dynamic>> list) {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    for (final b in list) {
      if (b['status'] != 'confirmed') continue;
      final date = b['date'] as String? ?? '';
      final slot = b['slot'] as String? ?? '';
      final id = b['id'] as String? ?? '';
      if (id.isEmpty) continue;

      bool shouldComplete = false;

      if (date.isNotEmpty && date.compareTo(today) < 0) {
        // Purani date — directly complete
        shouldComplete = true;
      } else if (date == today) {
        final endTime = _slotEndTime(date, slot);
        if (endTime != null && now.isAfter(endTime)) {
          shouldComplete = true;
        }
      }

      if (shouldComplete) {
        // Firestore mein update karo (fire and forget)
        _db.collection(_col).doc(id).update({'status': 'completed'}).catchError(
            (e) => debugPrint('markExpired ERROR: $e'));
        // Local list mein bhi update karo taake UI turant reflect kare
        b['status'] = 'completed';
      }
    }
  }

  /// Ek ground ke booked slots fetch karo (confirmed + completed)
  static Future<List<String>> getBookedSlots(String groundId, String date) async {
    try {
      final snap = await _db
          .collection(_col)
          .where('groundId', isEqualTo: groundId)
          .where('date', isEqualTo: date)
          .get();
      return snap.docs
          .map((d) => d.data())
          .where((d) => d['status'] == 'confirmed' || d['status'] == 'completed')
          .map((d) => d['slot'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Booking cancel karo
  static Future<void> cancelBooking(String bookingId) async {
    await _db.collection(_col).doc(bookingId).update({'status': 'cancelled'});
  }

  /// Booking delete karo (cancelled/completed)
  static Future<void> deleteBooking(String bookingId) async {
    await _db.collection(_col).doc(bookingId).delete();
  }

  /// Slot ka start time parse karo
  static DateTime? _slotStartTime(String date, String slot) {
    try {
      final parts = date.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      int startHour = 0;

      if (slot == '9am to 2pm' || slot == 'Full-day') {
        startHour = 9;
      } else if (slot == '2pm to 6pm') {
        startHour = 14;
      } else {
        final dashIdx = slot.indexOf('-');
        if (dashIdx == -1) return null;
        final startPart = slot.substring(0, dashIdx).trim().toLowerCase();
        if (startPart.endsWith('am')) {
          startHour = int.parse(startPart.replaceAll('am', ''));
        } else if (startPart.endsWith('pm')) {
          final h = int.parse(startPart.replaceAll('pm', ''));
          startHour = h == 12 ? 12 : h + 12;
        } else {
          return null;
        }
      }
      return DateTime(year, month, day, startHour, 0);
    } catch (_) {
      return null;
    }
  }

  /// Slot ka end time parse karo — returns DateTime or null (public)
  static DateTime? slotEndTime(String date, String slot) => _slotEndTime(date, slot);
  static DateTime? _slotEndTime(String date, String slot) {
    try {
      // date format: yyyy-MM-dd
      final parts = date.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      int endHour = 0;

      // Cricket special slots
      if (slot == '9am to 2pm') {
        endHour = 14;
      } else if (slot == '2pm to 6pm') {
        endHour = 18;
      } else if (slot == 'Full-day') {
        endHour = 18;
      } else {
        // Format: "9am-10am", "1pm-2pm", "11pm-12am" etc
        final dashIdx = slot.indexOf('-');
        if (dashIdx == -1) return null;
        final endPart = slot.substring(dashIdx + 1).trim().toLowerCase();

        if (endPart == '12am') {
          endHour = 24; // midnight
        } else if (endPart.endsWith('am')) {
          endHour = int.parse(endPart.replaceAll('am', ''));
        } else if (endPart.endsWith('pm')) {
          final h = int.parse(endPart.replaceAll('pm', ''));
          endHour = h == 12 ? 12 : h + 12;
        } else {
          return null;
        }
      }

      if (endHour == 24) {
        return DateTime(year, month, day + 1, 0, 0);
      }
      return DateTime(year, month, day, endHour, 0);
    } catch (_) {
      return null;
    }
  }

  /// App start pe ya periodic check — expire hue confirmed bookings ko completed mark karo
  static Future<void> autoCompleteExpiredBookings() async {
    try {
      // Auth check — agar user logged in nahi to skip
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Sirf is user ki bookings check karo (permission ke andar)
      final snap = await _db
          .collection(_col)
          .where('userId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'confirmed')
          .get();

      final batch = _db.batch();
      int count = 0;

      for (final doc in snap.docs) {
        final data = doc.data();
        final date = data['date'] as String? ?? '';
        final slot = data['slot'] as String? ?? '';

        if (date.compareTo(today) < 0) {
          batch.update(doc.reference, {'status': 'completed'});
          count++;
          continue;
        }

        if (date == today) {
          final endTime = _slotEndTime(date, slot);
          if (endTime != null && now.isAfter(endTime)) {
            batch.update(doc.reference, {'status': 'completed'});
            count++;
          }

          final startTime = _slotStartTime(date, slot);
          if (startTime != null &&
              now.isAfter(startTime) &&
              data['slotNotified'] != true) {
            final userId = data['userId'] as String? ?? '';
            final groundName = data['groundName'] as String? ?? '';
            if (userId.isNotEmpty) {
              await NotificationService.sendSlotStartNotification(
                userId: userId,
                groundName: groundName,
                date: date,
                slot: slot,
              );
              batch.update(doc.reference, {'slotNotified': true});
            }
          }
        }
      }

      if (count > 0) {
        await batch.commit();
        debugPrint('BookingService: $count bookings marked as completed');
      }
    } catch (e) {
      debugPrint('BookingService autoComplete ERROR: $e');
    }
  }
}
