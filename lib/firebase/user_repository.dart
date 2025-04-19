import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile(User user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true)); // Merge if exists
  }

  Future<User?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return User.fromDocumentSnapshot(doc);
    }
    return null;
  }

  Future<void> updateUserProfile(User user) async {
    await _firestore.collection('users').doc(user.uid).update({
      ...user.toMap(),
      'updated_at': FieldValue.serverTimestamp(), // Ensure latest update time
    });
  }

  Future<void> deleteUserProfile(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }
}
