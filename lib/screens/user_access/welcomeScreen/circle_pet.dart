import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:simpa/firebase/models/pet_model.dart';
import 'package:simpa/screens/user_access/pets/profile/pet_profile.dart';
import 'package:simpa/screens/user_access/stylesAndDec/dec.dart';

class CirclePet extends StatefulWidget {
  final auth.User user;
  const CirclePet({super.key, required this.user});

  @override
  State<CirclePet> createState() => _CirclePetState();
}

class _CirclePetState extends State<CirclePet> {
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
      width: double.infinity,
      padding: EdgeInsets.all(16),
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

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: pets.map((pet) {
                return GestureDetector(
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          // height: 60,
                          decoration: BoxDecoration(
                            color: Color(0xFFB2B2B2),
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            'assets/images/${pet.petType}.jpeg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.pets,
                                size: 30,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          pet.petName,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          pet.petType,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
