import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TournamentService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'tournaments';

  /// Tournament Firestore mein save karo
  static Future<String?> createTournament(Map<String, dynamic> data) async {
    try {
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

      final fixtures = (data['fixtures'] as List? ?? []).map((f) {
        final row = (f as List).cast<String>();
        return {
          'team1': row.isNotEmpty ? row[0] : '',
          'team2': row.length > 1 ? row[1] : '',
          'round': row.length > 2 ? row[2] : '',
          'matchType': row.length > 3 ? row[3] : 'regular',
        };
      }).toList();

      final matches = (data['matches'] as List? ?? []).map((m) {
        final map = Map<String, dynamic>.from(m as Map);
        map.remove('ground');
        return map;
      }).toList();

      // Initialize points table for all teams
      final teamNames = (data['teamNames'] as List?)?.cast<String>() ?? [];
      final pointsTable = <String, dynamic>{};
      for (final team in teamNames) {
        if (team != 'BYE') {
          pointsTable[team] = {
            'played': 0, 'won': 0, 'drawn': 0, 'lost': 0,
            'abandoned': 0, 'goalsFor': 0, 'goalsAgainst': 0, 'points': 0,
          };
        }
      }

      final doc = await _db.collection(_col).add({
        ...data,
        'bookedGrounds': bookedGrounds,
        'fixtures': fixtures,
        'matches': matches,
        'pointsTable': pointsTable,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('TournamentService: Created ${doc.id}');
      return doc.id;
    } catch (e) {
      debugPrint('TournamentService ERROR: $e');
      return null;
    }
  }

  /// User ke tournaments (real-time)
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
          return (tb as dynamic).toDate().compareTo((ta as dynamic).toDate());
        } catch (_) {
          return tb.toString().compareTo(ta.toString());
        }
      });
      return list;
    });
  }

  /// Match result update karo — Firestore mein points bhi update karo
  static Future<void> updateMatchResult({
    required String tournamentId,
    required int matchIndex,
    required String result, // 'team1' | 'team2' | 'draw' | 'abandoned'
    required String team1,
    required String team2,
    int? team1Score,
    int? team2Score,
  }) async {
    try {
      final docRef = _db.collection(_col).doc(tournamentId);
      final doc = await docRef.get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final matches = List<Map<String, dynamic>>.from(
          (data['matches'] as List? ?? []).map((m) => Map<String, dynamic>.from(m as Map)));

      if (matchIndex >= matches.length) return;

      // Update match
      final match = matches[matchIndex];
      match['status'] = 'completed';
      match['result'] = result;
      match['completedAt'] = DateTime.now().toIso8601String();
      if (team1Score != null) match['team1Score'] = team1Score;
      if (team2Score != null) match['team2Score'] = team2Score;

      String? winner;
      if (result == 'team1') { winner = team1; match['winner'] = team1; }
      else if (result == 'team2') { winner = team2; match['winner'] = team2; }

      // Determine loser
      final loser = winner == team1 ? team2 : (winner == team2 ? team1 : null);

      // Update points table
      final pointsTable = Map<String, dynamic>.from(data['pointsTable'] as Map? ?? {});

      void updateTeam(String team, {bool won = false, bool drawn = false, bool lost = false, bool abandoned = false, int gf = 0, int ga = 0}) {
        if (team == 'BYE' || team.isEmpty) return;
        final entry = Map<String, dynamic>.from(pointsTable[team] as Map? ?? {
          'played': 0, 'won': 0, 'drawn': 0, 'lost': 0,
          'abandoned': 0, 'goalsFor': 0, 'goalsAgainst': 0, 'points': 0,
        });
        entry['played'] = (entry['played'] as int? ?? 0) + 1;
        if (won) { entry['won'] = (entry['won'] as int? ?? 0) + 1; entry['points'] = (entry['points'] as int? ?? 0) + 3; }
        if (drawn) { entry['drawn'] = (entry['drawn'] as int? ?? 0) + 1; entry['points'] = (entry['points'] as int? ?? 0) + 1; }
        if (lost) { entry['lost'] = (entry['lost'] as int? ?? 0) + 1; }
        if (abandoned) { entry['abandoned'] = (entry['abandoned'] as int? ?? 0) + 1; entry['points'] = (entry['points'] as int? ?? 0) + 1; }
        entry['goalsFor'] = (entry['goalsFor'] as int? ?? 0) + gf;
        entry['goalsAgainst'] = (entry['goalsAgainst'] as int? ?? 0) + ga;
        pointsTable[team] = entry;
      }

      if (result == 'team1') {
        updateTeam(team1, won: true, gf: team1Score ?? 0, ga: team2Score ?? 0);
        updateTeam(team2, lost: true, gf: team2Score ?? 0, ga: team1Score ?? 0);
      } else if (result == 'team2') {
        updateTeam(team2, won: true, gf: team2Score ?? 0, ga: team1Score ?? 0);
        updateTeam(team1, lost: true, gf: team1Score ?? 0, ga: team2Score ?? 0);
      } else if (result == 'draw') {
        updateTeam(team1, drawn: true, gf: team1Score ?? 0, ga: team2Score ?? 0);
        updateTeam(team2, drawn: true, gf: team2Score ?? 0, ga: team1Score ?? 0);
      } else if (result == 'abandoned') {
        updateTeam(team1, abandoned: true);
        updateTeam(team2, abandoned: true);
      }

      // Fill TBD slots in subsequent matches
      // Find the next match that has 'TBD' and fill with winner/loser
      if (winner != null) {
        // Count how many matches in this round came before current match
        final currentRound = match['round'] as String? ?? '';
        final roundMatches = matches
            .where((m) => (m['round'] as String? ?? '') == currentRound)
            .toList();
        final posInRound = roundMatches.indexOf(match);

        // Find next round matches with TBD — fill winner
        int tbdFilled = 0;
        for (final m in matches) {
          if (m['status'] != 'scheduled') continue;
          if (m['team1'] == 'TBD' && tbdFilled == posInRound) {
            m['team1'] = winner;
            tbdFilled = -1;
            break;
          } else if (m['team2'] == 'TBD' && tbdFilled == posInRound) {
            m['team2'] = winner;
            tbdFilled = -1;
            break;
          }
          if (m['team1'] == 'TBD' || m['team2'] == 'TBD') tbdFilled++;
        }

        // Fill loser into LB TBD (for double elimination)
        if (loser != null) {
          for (final m in matches) {
            if (m['status'] != 'scheduled') continue;
            if ((m['round'] as String? ?? '').startsWith('LB') &&
                (m['team1'] == 'TBD' || m['team2'] == 'TBD')) {
              if (m['team1'] == 'TBD') { m['team1'] = loser; break; }
              if (m['team2'] == 'TBD') { m['team2'] = loser; break; }
            }
          }
        }
      }

      // Check if all current matches done
      final allDone = matches.every((m) => m['status'] == 'completed');

      // Round Robin: jab saare group matches done ho jayein, top 2 ka Final add karo
      final format = data['format'] as String? ?? '';
      bool finalAdded = false;
      if (allDone && format == 'Round Robin') {
        // Check if final already exists
        final finalExists = matches.any((m) =>
            (m['matchType'] as String? ?? '') == 'final');
        if (!finalExists) {
          // Sort pointsTable to get top 2
          final sortedTeams = pointsTable.entries.map((e) {
            final d = Map<String, dynamic>.from(e.value as Map? ?? {});
            return {
              'team': e.key,
              'points': d['points'] as int? ?? 0,
              'goalDifference': (d['goalsFor'] as int? ?? 0) - (d['goalsAgainst'] as int? ?? 0),
              'goalsFor': d['goalsFor'] as int? ?? 0,
            };
          }).toList()
            ..sort((a, b) {
              final pts = (b['points'] as int).compareTo(a['points'] as int);
              if (pts != 0) return pts;
              final gd = (b['goalDifference'] as int).compareTo(a['goalDifference'] as int);
              if (gd != 0) return gd;
              return (b['goalsFor'] as int).compareTo(a['goalsFor'] as int);
            });

          if (sortedTeams.length >= 2) {
            final top1 = sortedTeams[0]['team'] as String;
            final top2 = sortedTeams[1]['team'] as String;
            matches.add({
              'id': matches.length + 1,
              'team1': top1,
              'team2': top2,
              'round': 'Final',
              'matchType': 'final',
              'date': '',
              'time': '',
              'ground': '',
              'status': 'scheduled',
              'result': null,
              'winner': null,
              'createdAt': DateTime.now().toIso8601String(),
            });
            finalAdded = true;
          }
        }
      }

      await docRef.update({
        'matches': matches,
        'pointsTable': pointsTable,
        if (winner != null) 'currentLeader': winner,
        // Only mark completed if final also done (or not round robin)
        if (allDone && !finalAdded && format != 'Round Robin') 'status': 'completed',
        if (allDone && !finalAdded && format == 'Round Robin') 'status': 'completed',
      });
    } catch (e) {
      debugPrint('TournamentService updateMatchResult ERROR: $e');
      rethrow;
    }
  }

  /// Tournament update karo
  static Future<void> updateTournament(
      String tournamentId, Map<String, dynamic> data) async {
    await _db.collection(_col).doc(tournamentId).update(data);
  }

  /// Tournament delete karo aur uski saari bookings cancel karo
  static Future<void> deleteTournament(String tournamentId, String creatorUid) async {
    try {
      final bookingsSnap = await _db
          .collection('bookings')
          .where('tournamentId', isEqualTo: tournamentId)
          .where('userId', isEqualTo: creatorUid)
          .get();

      final batch = _db.batch();
      for (final doc in bookingsSnap.docs) {
        batch.update(doc.reference, {'status': 'cancelled'});
      }
      batch.delete(_db.collection(_col).doc(tournamentId));
      await batch.commit();
    } catch (e) {
      debugPrint('TournamentService deleteTournament ERROR: $e');
      rethrow;
    }
  }

  /// Single tournament real-time stream
  static Stream<Map<String, dynamic>> getTournamentStream(String tournamentId) {
    return _db.collection(_col).doc(tournamentId).snapshots().map((s) =>
        s.exists ? {...s.data()!, 'id': s.id} : <String, dynamic>{});
  }
}
