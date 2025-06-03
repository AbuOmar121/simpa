import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:simpa/firebase/models/pet_model.dart';
import 'package:simpa/screens/user_access/pets/profile/pet_profile.dart';
import 'package:simpa/screens/user_access/stylesAndDec/dec.dart';

class GetPets extends StatefulWidget {
  final auth.User user;
  const GetPets({super.key, required this.user});

  @override
  State<GetPets> createState() => _GetPetsState();
}

class _GetPetsState extends State<GetPets> {
  Stream<List<Pet>> _petStream() {
    return FirebaseFirestore.instance
        .collection('pets')
        .where('ownerId', isEqualTo: widget.user.uid)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Pet.fromDocumentSnapshot(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDec.style,
      child: StreamBuilder<List<Pet>>(
        stream: _petStream(),
        builder: (context, petsSnapshot) {
          if (petsSnapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: Colors.pink),
              ),
            );
          }

          if (petsSnapshot.hasError || petsSnapshot.data == null) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Failed to load pets',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(31, 31, 31, 1),
                  ),
                ),
              ),
            );
          }

          final pets = petsSnapshot.data!;
          if (pets.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'There are no pets',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(31, 31, 31, 1),
                  ),
                ),
              ),
            );
          }

          return Column(
            children: pets.map((pet) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PetsProfile(
                            pet: pet,
                            user: widget.user,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFFB2B2B2),
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/${pet.petType}.jpeg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.pets,
                                      size: 60, color: Colors.grey);
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pet.petName,
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(31, 31, 31, 1),
                                    ),
                                  ),
                                  Text(
                                    pet.petType,
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 14,
                                      color: Color.fromRGBO(31, 31, 31, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Color.fromRGBO(31, 31, 31, 1),
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: Color(0xFFFA9DBC),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
