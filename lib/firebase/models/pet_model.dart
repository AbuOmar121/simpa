//import 'package:simpa/firebase/models/pet_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String pid;
  final String petName;
  final String petType;
  final String petBreed;
  final String petGender;
  final DateTime? birthdate;
  final String uid; //forign key

  Pet({
    required this.pid,
    required this.petName,
    required this.petType,
    required this.petBreed,
    required this.petGender,
    required this.birthdate,
    required this.uid, //forign key
  });

  factory Pet.fromFirestore(Map<String, dynamic> data, String pid, String uid) {
    return Pet(
      pid: pid,
      petName: data['name'] ?? '',
      petType: data['type'] ?? '',
      petBreed: data['breed'] ?? '',
      petGender: data['gender'] ?? '',
      birthdate: (data['birthDate'] as Timestamp).toDate(),
      uid: uid, //forign key
    );
  }

  factory Pet.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pet.fromFirestore(data, doc.id, doc.id);
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
