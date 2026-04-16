import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ReviewService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'reviews';

  /// Review submit karo (ek user ek ground pe ek baar)
  static Future<bool> submitReview({
    required String groundId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    try {
      // Duplicate check — same user same ground
      final existing = await _db
          .collection(_col)
          .where('groundId', isEqualTo: groundId)
          .where('userId', isEqualTo: userId)
          .get();

      final data = {
        'groundId': groundId,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (existing.docs.isNotEmpty) {
        // Update existing review
        await existing.docs.first.reference.update(data);
      } else {
        await _db.collection(_col).add(data);
      }

      // Ground ka average rating update karo
      await _updateGroundRating(groundId);
      return true;
    } catch (e) {
      debugPrint('ReviewService ERROR: $e');
      return false;
    }
  }

  /// Ground ki reviews stream
  static Stream<List<Map<String, dynamic>>> getGroundReviews(String groundId) {
    return _db
        .collection(_col)
        .where('groundId', isEqualTo: groundId)
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

  /// Check karo user ne is ground pe booking ki hai (completed)
  static Future<bool> hasCompletedBooking(
      String userId, String groundId) async {
    final snap = await _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('groundId', isEqualTo: groundId)
        .where('status', isEqualTo: 'completed')
        .get();
    return snap.docs.isNotEmpty;
  }

  /// Check karo user ne already review diya hai
  static Future<Map<String, dynamic>?> getUserReview(
      String userId, String groundId) async {
    final snap = await _db
        .collection(_col)
        .where('userId', isEqualTo: userId)
        .where('groundId', isEqualTo: groundId)
        .get();
    if (snap.docs.isEmpty) return null;
    return {...snap.docs.first.data(), 'id': snap.docs.first.id};
  }

  /// Ground ka average rating recalculate karo
  static Future<void> _updateGroundRating(String groundId) async {
    final snap = await _db
        .collection(_col)
        .where('groundId', isEqualTo: groundId)
        .get();
    if (snap.docs.isEmpty) return;
    final total = snap.docs.fold<double>(
        0, (acc, d) => acc + ((d.data()['rating'] as num?)?.toDouble() ?? 0));
    final avg = total / snap.docs.length;
    await _db.collection('grounds').doc(groundId).update({
      'avgRating': double.parse(avg.toStringAsFixed(1)),
      'reviewCount': snap.docs.length,
    });
  }
}
