import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'notifications';

  // ─── MANAGER ───────────────────────────────────────────

  /// Booking hone par manager ko notification bhejo
  static Future<void> sendBookingNotification({
    required String managerId,
    required String groundName,
    required String userName,
    required String date,
    required String slot,
  }) async {
    try {
      await _db.collection(_col).add({
        'type': 'manager',
        'managerId': managerId,
        'title': 'New Booking!',
        'body': '"$groundName" has been booked\n$userName • $date • $slot',
        'groundName': groundName,
        'userName': userName,
        'date': date,
        'slot': slot,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('NotificationService sendBooking ERROR: $e');
    }
  }

  /// Manager ki notifications — index ki zaroorat nahi (type filter)
  static Stream<List<Map<String, dynamic>>> getManagerNotifications(
      String managerId) {
    return _db
        .collection(_col)
        .where('managerId', isEqualTo: managerId)
        .where('type', isEqualTo: 'manager')
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => {...d.data(), 'id': d.id}).toList();
      // Client-side sort — createdAt descending
      list.sort((a, b) {
        final ta = a['createdAt'];
        final tb = b['createdAt'];
        if (ta == null || tb == null) return 0;
        try {
          return (tb as dynamic).toDate().compareTo((ta as dynamic).toDate());
        } catch (_) {
          return 0;
        }
      });
      return list;
    });
  }

  /// Manager unread count
  static Stream<int> getUnreadCount(String managerId) {
    return _db
        .collection(_col)
        .where('managerId', isEqualTo: managerId)
        .where('type', isEqualTo: 'manager')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  // ─── USER ───────────────────────────────────────────────

  /// Slot start hone par user ko notification bhejo
  static Future<void> sendSlotStartNotification({
    required String userId,
    required String groundName,
    required String date,
    required String slot,
  }) async {
    try {
      await _db.collection(_col).add({
        'type': 'user',
        'userId': userId,
        'title': 'Your slot has started!',
        'body': 'Your slot at "$groundName" has started\n$date • $slot',
        'groundName': groundName,
        'date': date,
        'slot': slot,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('NotificationService sendSlot ERROR: $e');
    }
  }

  /// Booking confirm hone par user ko notification
  static Future<void> sendBookingConfirmedNotification({
    required String userId,
    required String groundName,
    required String date,
    required String slot,
  }) async {
    try {
      await _db.collection(_col).add({
        'type': 'user',
        'userId': userId,
        'title': 'Booking Confirmed!',
        'body': '"$groundName" has been successfully booked\n$date • $slot',
        'groundName': groundName,
        'date': date,
        'slot': slot,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('NotificationService sendConfirmed ERROR: $e');
    }
  }

  /// User ki notifications
  static Stream<List<Map<String, dynamic>>> getUserNotifications(
      String userId) {
    return _db
        .collection(_col)
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'user')
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => {...d.data(), 'id': d.id}).toList();
      list.sort((a, b) {
        final ta = a['createdAt'];
        final tb = b['createdAt'];
        if (ta == null || tb == null) return 0;
        try {
          return (tb as dynamic).toDate().compareTo((ta as dynamic).toDate());
        } catch (_) {
          return 0;
        }
      });
      return list;
    });
  }

  /// User unread count
  static Stream<int> getUserUnreadCount(String userId) {
    return _db
        .collection(_col)
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'user')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  /// Tournament create hone par ek summary notification bhejo
  static Future<void> sendTournamentBookingNotification({
    required String managerId,
    required String userId,
    required String tournamentName,
    required String creatorName,
    required int slotCount,
  }) async {
    try {
      // Manager ko — ek notification
      if (managerId.isNotEmpty) {
        await _db.collection(_col).add({
          'type': 'manager',
          'managerId': managerId,
          'title': 'Tournament Booking!',
          'body': '"$tournamentName" tournament — $slotCount slot${slotCount == 1 ? '' : 's'} booked by $creatorName',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      // User ko — ek confirmation
      if (userId.isNotEmpty) {
        await _db.collection(_col).add({
          'type': 'user',
          'userId': userId,
          'title': 'Tournament Created!',
          'body': '"$tournamentName" has been created successfully — $slotCount slot${slotCount == 1 ? '' : 's'} booked.',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('NotificationService sendTournament ERROR: $e');
    }
  }

  /// Manager ko notify karo k venue ki price set karo
  static Future<void> sendPriceNotSetNotification({
    required String managerId,
    required String groundName,
  }) async {
    try {
      // Duplicate avoid karo — agar already unread price notification hai to skip
      final existing = await _db
          .collection(_col)
          .where('managerId', isEqualTo: managerId)
          .where('type', isEqualTo: 'manager')
          .where('notifType', isEqualTo: 'price_not_set')
          .where('groundName', isEqualTo: groundName)
          .where('isRead', isEqualTo: false)
          .get();
      if (existing.docs.isNotEmpty) return;

      await _db.collection(_col).add({
        'type': 'manager',
        'notifType': 'price_not_set',
        'managerId': managerId,
        'title': 'Set Your Price!',
        'body': '"$groundName" day/night price is not set yet. Go to Venues and set the price.',
        'groundName': groundName,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('NotificationService sendPriceNotSet ERROR: $e');
    }
  }

  // ─── COMMON ─────────────────────────────────────────────

  static Future<void> markAsRead(String notificationId) async {
    await _db.collection(_col).doc(notificationId).update({'isRead': true});
  }

  static Future<void> markAllAsRead(String field, String id) async {
    final snap = await _db
        .collection(_col)
        .where(field, isEqualTo: id)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// All notifications delete karo (clear all)
  static Future<void> clearAll(String field, String id) async {
    final snap = await _db
        .collection(_col)
        .where(field, isEqualTo: id)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
