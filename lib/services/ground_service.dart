import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class GroundService {
  static final _db = FirebaseFirestore.instance;
  static const _collection = 'grounds';

  /// Manager signup ke waqt ground create karo
  static Future<String?> createGround({
    required String managerId,
    required String managerName,
    required String managerEmail,
    required String venueName,
    required String venueLocation,
    required String category,
    required List<String> imageUrls,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Name ka pehla letter capital karo
      final capitalizedName = venueName.isNotEmpty
          ? venueName[0].toUpperCase() + venueName.substring(1)
          : venueName;
      final data = {
        'managerId': managerId,
        'managerName': managerName,
        'managerEmail': managerEmail,
        'name': capitalizedName,
        'location': venueLocation,
        'category': category,
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        if (latitude != null && longitude != null) ...{
          'latitude': latitude,
          'longitude': longitude,
        },
      };
      debugPrint('GroundService: Creating ground with data: $data');
      final doc = await _db.collection(_collection).add(data);
      debugPrint('GroundService: Ground created with ID: ${doc.id}');
      return doc.id;
    } catch (e, stack) {
      debugPrint('GroundService ERROR creating ground: $e');
      debugPrint('Stack: $stack');
      return null;
    }
  }

  /// Category ke hisaab se grounds fetch karo (real-time stream)
  static Stream<List<Map<String, dynamic>>> getGroundsByCategory(String category) {
    debugPrint('GroundService: Fetching grounds for category: $category');
    Query<Map<String, dynamic>> query = _db.collection(_collection);
    if (category != 'ALL') {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map((snap) {
      debugPrint('GroundService: Got ${snap.docs.length} grounds from Firestore');
      return snap.docs.map((doc) {
        final data = doc.data();
        return {...data, 'id': doc.id};
      }).toList();
    });
  }

  /// Ground update karo (name, images, location)
  static Future<bool> updateGround(String groundId, Map<String, dynamic> data) async {
    try {
      // Name ka pehla letter capital karo
      if (data.containsKey('name') && (data['name'] as String).isNotEmpty) {
        final n = data['name'] as String;
        data['name'] = n[0].toUpperCase() + n.substring(1);
      }
      await _db.collection(_collection).doc(groundId).update(data);
      return true;
    } catch (e) {
      debugPrint('GroundService update ERROR: $e');
      return false;
    }
  }
  static Stream<List<Map<String, dynamic>>> getManagerGrounds(String managerId) {
    return _db
        .collection(_collection)
        .where('managerId', isEqualTo: managerId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              return {...data, 'id': doc.id};
            }).toList());
  }

  /// Check karo koi ground hai jis mein price set nahi
  static Future<bool> hasGroundWithoutPrice(String managerId) async {
    final snap = await _db
        .collection(_collection)
        .where('managerId', isEqualTo: managerId)
        .get();
    for (final doc in snap.docs) {
      final data = doc.data();
      final dayPrice = data['dayPrice'];
      final nightPrice = data['nightPrice'];
      if (dayPrice == null || nightPrice == null) return true;
    }
    return false;
  }
}
