import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

/// Booking reminders — slot se 1 hour pehle in-app notification
class ReminderService {
  static Timer? _checkTimer;

  /// User login ke baad start karo — har 15 min mein check
  static void startChecking(String userId) {
    _checkTimer?.cancel();
    _checkBookings(userId);
    _checkTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _checkBookings(userId),
    );
  }

  static void stopChecking() {
    _checkTimer?.cancel();
  }

  static Future<void> _checkBookings(String userId) async {
    try {
      final now = DateTime.now();
      final snap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'confirmed')
          .get();

      for (final doc in snap.docs) {
        final data = doc.data();
        final date = data['date'] as String? ?? '';
        final slot = data['slot'] as String? ?? '';
        final groundName = data['groundName'] as String? ?? 'Your venue';
        final reminded = data['reminded'] as bool? ?? false;

        if (reminded) continue;

        final slotStart = _parseSlotStart(date, slot);
        if (slotStart == null) continue;

        final diff = slotStart.difference(now);
        // 45–75 min window before slot
        if (diff.inMinutes >= 45 && diff.inMinutes <= 75) {
          // In-app notification bhejo
          await NotificationService.sendSlotStartNotification(
            userId: userId,
            groundName: groundName,
            date: date,
            slot: slot,
          );
          await doc.reference.update({'reminded': true});
        }
      }
    } catch (e) {
      debugPrint('ReminderService error: $e');
    }
  }

  static DateTime? _parseSlotStart(String date, String slot) {
    try {
      final parts = date.split('-');
      if (parts.length != 3) return null;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      final s = slot.toLowerCase().trim();
      int hour = 9;
      if (s.startsWith('full')) {
        hour = 6;
      } else {
        final startPart = s.split(RegExp(r'[-–]')).first.trim();
        if (startPart.endsWith('am')) {
          hour = int.tryParse(startPart.replaceAll('am', '').trim()) ?? 9;
        } else if (startPart.endsWith('pm')) {
          final h = int.tryParse(startPart.replaceAll('pm', '').trim()) ?? 12;
          hour = h == 12 ? 12 : h + 12;
        }
      }
      return DateTime(year, month, day, hour);
    } catch (_) {
      return null;
    }
  }
}
