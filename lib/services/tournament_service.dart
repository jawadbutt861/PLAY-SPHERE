import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TournamentService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'tournaments';

  /// Tournament Firestore mein save karo
  static Future<String?> createTournament(Map<String, dynamic> data) async {
    try {
      // bookedGrounds — nested ground object flatten karo
      final bookedGrounds = (data['bookedGrounds'] as List? ?? []).map((b) {
        final ground = b['ground'] as Map<String, dynamic>? ?? {};
        return {
          'groundId': ground['id'] ?? '',
          'groundName': ground['name'] ?? '',
          'groundCategory': ground['category'] ?? '',
          'imageUrls': (ground['imageUrls'] as List?)?.cast<String>() ?? [],
          'date': b['date'] ?? '',
          'slot': b['slot'] ?? '',
          'payment': b['payment'] ?? '',
        };
      }).toList();

      // fixtures: List<List<String>> → List<Map> (Firestore nested arrays support nahi karta)
      final fixtures = (data['fixtures'] as List? ?? []).map((f) {
        final row = (f as List).cast<String>();
        return {
          'team1': row.isNotEmpty ? row[0] : '',
          'team2': row.length > 1 ? row[1] : '',
          'round': row.length > 2 ? row[2] : '',
        };
      }).toList();

      // matches mein koi nested array nahi hona chahiye — safe cast
      final matches = (data['matches'] as List? ?? []).map((m) {
        final map = Map<String, dynamic>.from(m as Map);
        // Remove any non-serializable fields
        map.remove('ground'); // agar koi ground object ho
        return map;
      }).toList();

      final doc = await _db.collection(_col).add({
        ...data,
        'bookedGrounds': bookedGrounds,
        'fixtures': fixtures,
        'matches': matches,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('TournamentService: Created ${doc.id}');
      return doc.id;
    } catch (e) {
      debugPrint('TournamentService ERROR: $e');
      return null;
    }
  }

  /// User ke tournaments (real-time) — client-side sort to avoid composite index
  static Stream<List<Map<String, dynamic>>> getUserTournaments(String userId) {
    return _db
        .collection(_col)
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => {...d.data(), 'id': d.id}).toList();
      list.sort((a, b) {
        final ta = a['createdAt'];
        final tb = b['createdAt'];
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        try {
          // Firestore Timestamp
          return (tb as dynamic).toDate().compareTo((ta as dynamic).toDate());
        } catch (_) {
          // String fallback
          return tb.toString().compareTo(ta.toString());
        }
      });
      return list;
    });
  }

  /// Tournament update karo (match results etc)
  static Future<void> updateTournament(
      String tournamentId, Map<String, dynamic> data) async {
    await _db.collection(_col).doc(tournamentId).update(data);
  }

  /// Tournament delete karo aur uski saari bookings cancel karo
  static Future<void> deleteTournament(String tournamentId, String creatorUid) async {
    try {
      // Tournament ki bookings fetch karo — userId filter se (creator ne banai thi)
      final bookingsSnap = await _db
          .collection('bookings')
          .where('tournamentId', isEqualTo: tournamentId)
          .where('userId', isEqualTo: creatorUid)
          .get();

      final batch = _db.batch();
      for (final doc in bookingsSnap.docs) {
        batch.update(doc.reference, {'status': 'cancelled'});
      }
      // Tournament document delete karo
      batch.delete(_db.collection(_col).doc(tournamentId));
      await batch.commit();
      debugPrint('TournamentService: Deleted $tournamentId, cancelled ${bookingsSnap.docs.length} bookings');
    } catch (e) {
      debugPrint('TournamentService deleteTournament ERROR: $e');
      rethrow;
    }
  }
}
