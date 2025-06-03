import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications{
  final String nid;
  final String nTitle;
  final String nContent;
  final String uid;
  final DateTime? timestamp;
  late final bool isRead;

  Notifications({
    required this.nid,
    required this.nTitle,
    required this.nContent,
    required this.uid,
    this.timestamp,
    this.isRead = false,
  });

  factory Notifications.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data()!;
    return Notifications(
      nid: snapshot.id,
      nTitle: data['title'] ?? '',
      nContent: data['content'] ?? '',
      uid: data['userId'] ?? '',
      timestamp: data['timestamp']?.toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  factory Notifications.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.data() is! Map<String, dynamic>) {
      throw ArgumentError('Document ${snapshot.id} does not contain valid notification data');
    }
    return Notifications.fromFirestore(
      snapshot as DocumentSnapshot<Map<String, dynamic>>,
      null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': nTitle,  // Must match rules
      'content': nContent,
      'userId': uid,    // Must match rules
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}