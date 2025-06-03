import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:simpa/firebase/models/pet_model.dart';
import 'package:simpa/screens/project_app_bar.dart';
import 'package:simpa/screens/user_access/pets/profile/pet_data.dart';
import 'package:simpa/screens/user_access/pets/profile/profiles_buttons.dart';
import 'package:simpa/screens/user_access/popups/sure_for_delete.dart';
import 'package:simpa/screens/user_access/welcomeScreen/welcome.dart';

class PetsProfile extends StatefulWidget {
  final auth.User user;
  final Pet pet;

  const PetsProfile({
    super.key,
    required this.pet,
    required this.user,
  });

  @override
  State<PetsProfile> createState() => _PetsProfileState();
}

class _PetsProfileState extends State<PetsProfile> {
  Future<void> deletePet(String pid) async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    final uid = currentUser.uid;

    try {
      final petDoc =
          await FirebaseFirestore.instance.collection('pets').doc(pid).get();


      if (!petDoc.exists) {
        return;
      }

      final data = petDoc.data();
      if (data == null || data['ownerId'] != uid) {
        return;
      }

      await FirebaseFirestore.instance.collection('pets').doc(pid).delete();

      final bookings = await FirebaseFirestore.instance
          .collection('bookings')
          .where('petId', isEqualTo: pid)
          .get();

      for (var doc in bookings.docs) {
        await doc.reference.delete();
      }

      final pillPetDocs = await FirebaseFirestore.instance
          .collection('pillpet')
          .where('pid', isEqualTo: pid)
          .get();

      for (var doc in pillPetDocs.docs) {
        await doc.reference.delete();
      }

      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (_) => Welcome(user: widget.user),
        ),
      );
    } catch (e) {
      SnackBar(
        content: Text(
          'Error delete pet: $e',
        ),
      );
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> DeleteConfirm() async {
    Navigator.of(context).pop(true);
    deletePet(widget.pet.pid);

  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;

    final String petName = pet.petName;
    final String petBreed = pet.petBreed;
    final String petGender = pet.petGender;
    final String petType = pet.petType;
    final DateTime? petBirth = pet.birthdate;

    return Scaffold(
      backgroundColor: Color(0xFFFFE1E1),
      appBar: ProjectAppBar(title: 'Pet Profile'),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 32,
            ),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.asset('assets/images/${petType}.jpeg').image,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Color(0x33000000),
                    offset: Offset(
                      0,
                      2,
                    ),
                  ),
                ],
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE91E63),
                  width: 3,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                petName,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Mikhak',
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                ),
              ),
            ),
            PetData(
                petGender: petGender,
                petBirth: petBirth,
                petType: petType,
                petBreed: petBreed,
                age: pet.age),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 32, 0, 0),
              child: ProfilesButtons(pet: pet, user: widget.user),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showSureForDeleteDialog(
                          context, DeleteConfirm() as VoidCallback);
                    },
                    icon: Icon(
                      Icons.delete,
                      color: const Color(0xFFFFFFFF),
                      size: 20,
                    ),
                    label: Text(
                      'Delete Pet',
                      style: TextStyle(
                        fontFamily: 'Inter Tight',
                        color: const Color(0xFFFFFFFF),
                        fontSize: 16,
                        letterSpacing: 0.0,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE91E63),
                      foregroundColor: Color(0xFFFFFFFF),
                      minimumSize: Size(350, 50),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
