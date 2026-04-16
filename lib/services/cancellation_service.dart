import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Cancellation rules:
/// - 24+ hours before slot: Full refund (no penalty)
/// - 6-24 hours before slot: 50% penalty
/// - <6 hours before slot: No refund (100% penalty)
/// - Already started/completed: Cannot cancel
class CancellationService {
  static final _db = FirebaseFirestore.instance;

  static const _fullRefundHours = 24;
  static const _halfRefundHours = 6;

  /// Policy check karo — returns CancellationResult
  static CancellationResult checkPolicy(String date, String slot) {
    final slotStart = _parseSlotStart(date, slot);
    if (slotStart == null) {
      return CancellationResult(
        canCancel: true,
        refundPercent: 100,
        message: 'Full refund applicable.',
        hoursLeft: null,
      );
    }

    final now = DateTime.now();
    final diff = slotStart.difference(now);
    final hours = diff.inHours;

    if (diff.isNegative) {
      return CancellationResult(
        canCancel: false,
        refundPercent: 0,
        message: 'Slot has already started. Cannot cancel.',
        hoursLeft: 0,
      );
    }

    if (hours >= _fullRefundHours) {
      return CancellationResult(
        canCancel: true,
        refundPercent: 100,
        message: 'Full refund — cancelling $hours hours before slot.',
        hoursLeft: hours,
      );
    } else if (hours >= _halfRefundHours) {
      return CancellationResult(
        canCancel: true,
        refundPercent: 50,
        message: '50% refund — cancelling $hours hours before slot.',
        hoursLeft: hours,
      );
    } else {
      return CancellationResult(
        canCancel: true,
        refundPercent: 0,
        message: 'No refund — cancelling less than $_halfRefundHours hours before slot.',
        hoursLeft: hours,
      );
    }
  }

  /// Booking cancel karo with policy record
  static Future<bool> cancelBooking({
    required String bookingId,
    required String date,
    required String slot,
    required int? paidPrice,
  }) async {
    try {
      final policy = checkPolicy(date, slot);
      if (!policy.canCancel) return false;

      final refundAmount = paidPrice != null
          ? ((paidPrice * policy.refundPercent) / 100).round()
          : null;

      await _db.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'refundPercent': policy.refundPercent,
        if (refundAmount != null) 'refundAmount': refundAmount,
        'cancellationNote': policy.message,
      });
      return true;
    } catch (e) {
      debugPrint('CancellationService ERROR: $e');
      return false;
    }
  }

  /// Slot start time parse karo from "date" (yyyy-MM-dd) + "slot" (e.g. "9am-10am")
  static DateTime? _parseSlotStart(String date, String slot) {
    try {
      final parts = date.split('-');
      if (parts.length != 3) return null;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      final slotLower = slot.toLowerCase().trim();
      int hour = 9;

      if (slotLower.startsWith('full')) {
        hour = 6;
      } else {
        final startPart = slotLower.split(RegExp(r'[-–]')).first.trim();
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

class CancellationResult {
  final bool canCancel;
  final int refundPercent;
  final String message;
  final int? hoursLeft;

  const CancellationResult({
    required this.canCancel,
    required this.refundPercent,
    required this.message,
    required this.hoursLeft,
  });

  String get refundLabel {
    if (refundPercent == 100) return 'Full Refund';
    if (refundPercent == 50) return '50% Refund';
    return 'No Refund';
  }

  Color get refundColor {
    if (refundPercent == 100) return const Color(0xFF34C759);
    if (refundPercent == 50) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }
}
