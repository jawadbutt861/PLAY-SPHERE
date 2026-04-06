import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static final _db = FirebaseFirestore.instance;

  /// User register hone par Firestore mein save karo
  static Future<void> saveUser({
    required String uid,
    required String fullName,
    required String email,
    required String mobile,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Manager register hone par Firestore mein save karo
  static Future<void> saveManager({
    required String uid,
    required String fullName,
    required String email,
    required String mobile,
    required String cnic,
    required String venueName,
    required String venueLocation,
    required String category,
    List<String> imageUrls = const [],
    double? latitude,
    double? longitude,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'cnic': cnic,
      'venueName': venueName,
      'venueLocation': venueLocation,
      'category': category,
      'imageUrls': imageUrls,
      if (latitude != null && longitude != null) ...{
        'latitude': latitude,
        'longitude': longitude,
      },
      'role': 'manager',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// User ka data fetch karo
  static Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}
