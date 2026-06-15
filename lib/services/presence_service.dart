import 'package:cloud_firestore/cloud_firestore.dart';

class PresenceService {
  static final _firestore =
      FirebaseFirestore.instance;

  static Future<void> setOnline(
    String uid,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> setOffline(
    String uid,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
      'isOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
}