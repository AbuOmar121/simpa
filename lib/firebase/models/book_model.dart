import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String bid;
  final String reason;
  final String desc;
  final DateTime? date;
  final String status;
  final DateTime? createdAt;
  final String pid;
  final String uid;

  Book({
    required this.bid,
    required this.reason,
    required this.desc,
    this.date,
    this.status = 'pending',
    this.createdAt,
    required this.pid,
    required this.uid,
  });

  factory Book.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data()!;
    return Book(
      bid: snapshot.id,
      reason: data['reason'] ?? '',
      desc: data['desc'] ?? '',
      date: _parseTimestamp(data['dateTime']),
      createdAt: _parseTimestamp(data['created_at']),
      status: data['status'] ?? 'pending',
      pid: data['petId'] ?? '',
      uid: data['userId'] ?? '',
    );
  }

  factory Book.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.data() is Map<String, dynamic>) {
      return Book.fromFirestore(
        snapshot as DocumentSnapshot<Map<String, dynamic>>,
        null,
      );
    }
    throw ArgumentError('Document data is not a Map<String, dynamic>');
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'reason': reason,
      'desc': desc,
      'dateTime': date != null ? Timestamp.fromDate(date!) : null,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'status': status,
      'petId': pid,
      'userId': uid,
    };
  }
}
