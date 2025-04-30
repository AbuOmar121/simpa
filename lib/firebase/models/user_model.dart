import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class User {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromFirestore(Map<String, dynamic> data, String uid) {
    return User(
      uid: uid,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  factory User.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User.fromFirestore(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  factory User.fromFirebase(auth.User user) {
    return User(
      uid: user.uid,
      firstName: "",
      lastName: "",
      email: user.email ?? "",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
