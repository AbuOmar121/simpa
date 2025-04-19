import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpa/firebase/models/pet_model.dart';
//import 'package:simpa/firebase/models/user_model.dart';

class PetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPetProfile(Pet pet) async {
    await _firestore
        .collection('pets')
        .doc(pet.pid)
        .set(pet.toMap(), SetOptions(merge: true));
  }

  Future<Pet?> getPetProfile(String pid) async {
    final doc = await _firestore.collection('pets').doc(pid).get();
    if (doc.exists) {
      return Pet.fromDocumentSnapshot(doc);
    }
    return null;
  }

  Future<List<Pet>> getPetsByUserId(String uid) async {
    final querySnapshot = await _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: uid)
        .get();

    return querySnapshot.docs
        .map((doc) => Pet.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<void> updatePetProfile(Pet pet) async {
    await _firestore.collection('pets').doc(pet.pid).update({
      ...pet.toMap(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePetProfile(String pid) async {
    await _firestore.collection('pets').doc(pid).delete();
  }
}
