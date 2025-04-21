//import 'package:simpa/firebase/models/pet_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String pid;
  final String petName;
  final String petType;
  final String petBreed;
  final String petGender;
  final DateTime? birthdate;
  final String ownerId; //forign key

  Pet({
    required this.pid,
    required this.petName,
    required this.petType,
    required this.petBreed,
    required this.petGender,
    required this.birthdate,
    required this.ownerId, //forign key
  });

  factory Pet.fromFirestore(Map<String, dynamic> data, String pid, String uid) {
    return Pet(
      pid: pid,
      petName: data['name'] ?? '',
      petType: data['type'] ?? '',
      petBreed: data['breed'] ?? '',
      petGender: data['gender'] ?? '',
      birthdate: (data['birthDate'] as Timestamp).toDate(),
      ownerId: data['ownerId'] ?? '',
    );
  }

  factory Pet.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pet.fromFirestore(data, doc.id, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'pet_name': petName,
      'pet_type': petType,
      'pet_breed': petBreed,
      'ownerId': ownerId,
    };
  }
}
