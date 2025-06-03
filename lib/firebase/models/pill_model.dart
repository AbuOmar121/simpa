import 'package:cloud_firestore/cloud_firestore.dart';

class Pill {
  final String piId;
  final String name;
  final int exp;
  final String type;
  final String dosage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pill({
    required this.piId,
    required this.name,
    required this.exp,
    required this.type,
    required this.dosage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pill.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pill(
      piId: doc.id,
      name: data['name'] ?? '',
      exp: data['exp'] ?? 0,
      type: data['type'] ?? '',
      dosage: data['dosage'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'exp': exp,
      'type': type,
      'dosage': dosage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Pill &&
              runtimeType == other.runtimeType &&
              piId == other.piId;

  @override
  int get hashCode => piId.hashCode;
}
