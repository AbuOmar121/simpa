import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String pid;
  final String petName;
  final String petType;
  final String petBreed;
  final String petGender;
  final DateTime? birthdate;
  final String uid;

  Pet({
    required this.pid,
    required this.petName,
    required this.petType,
    required this.petBreed,
    required this.petGender,
    required this.birthdate,
    required this.uid,
  });

  String get age {
    if (birthdate == null) return 'Unknown';

    final now = DateTime.now();
    int years = now.year - birthdate!.year;
    int months = now.month - birthdate!.month;
    int days = now.day - birthdate!.day;

    if (days < 0) {
      months -= 1;
      days += DateTime(now.year, now.month, 0).day; // days in previous month
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    if (years > 0) return '$years year${years > 1 ? 's' : ''}';
    if (months > 0) return '$months month${months > 1 ? 's' : ''}';
    return '$days day${days > 1 ? 's' : ''}';
  }

  factory Pet.fromFirestore(Map<String, dynamic> data, String pid, String uid) {
    return Pet(
      pid: pid,
      petName: data['name'] ?? '',
      petType: data['type'] ?? '',
      petBreed: data['breed'] ?? '',
      petGender: data['gender'] ?? '',
      birthdate: (data['birthDate'] as Timestamp?)?.toDate(),
      uid: uid,
    );
  }

  factory Pet.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pet.fromFirestore(data, doc.id, data['ownerId'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {
      'name': petName,
      'type': petType,
      'breed': petBreed,
      'gender': petGender,
      'birthDate': birthdate != null ? Timestamp.fromDate(birthdate!) : null,
      'ownerId': uid,
    };
  }
}
