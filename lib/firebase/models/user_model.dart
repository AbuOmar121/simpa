import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class User {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String role;

  User({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
    required this.role,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory User.fromFirestore(Map<String, dynamic> data, String uid) {
    return User(
      uid: uid,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      role: data['role'] ?? 'user',
    );
  }

  factory User.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User.fromFirestore(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'role': role,
    };
  }

  factory User.fromFirebase(auth.User user) {
    return User(
      uid: user.uid,
      firstName: "",
      lastName: "",
      phone: "",
      email: user.email ?? "",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      role: "user",
    );
  }
}
