import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simpa/firebase/models/pet_model.dart';
import 'package:simpa/screens/user_access/pets/details.dart';
import 'package:simpa/screens/user_access/welcomeScreen/welcome.dart';
import 'package:simpa/screens/user_access/popups/edit_popup.dart';

class PetsProfile extends StatefulWidget {
  final User user;
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
    final currentUser = FirebaseAuth.instance.currentUser;

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
      Navigator.push(
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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Pet Profile',
          style: TextStyle(
            fontSize: 26,
            fontFamily: 'Inter Tight',
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFFF4F81),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xFFFFFFFF),
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        child: SingleChildScrollView(
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
                    image: Image.asset('assets/images/animal.jpeg').image,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color(0x33000000),
                      offset: Offset(
                        0,
                        2,
                      ),
                    )
                  ],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE91E63),
                    width: 3,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 4),
                child: Text(
                  petName,
                  style: TextStyle(
                    fontFamily: 'Inter Tight',
                    fontSize: 30,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: 500,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailBar(
                          icon: Icons.male,
                          detail: 'Gender',
                          data: petGender,
                        ),
                        Divider(),
                        DetailBar(
                          icon: Icons.calendar_month,
                          detail: 'Birth date',
                          data: petBirth != null
                              ? petBirth.toLocal().toString().split(' ')[0]
                              : 'Unknown',
                        ),
                        Divider(),
                        DetailBar(
                          icon: Icons.pets,
                          detail: 'pet type',
                          data: petType,
                        ),
                        Divider(),
                        DetailBar(
                          icon: Icons.vertical_distribute_outlined,
                          detail: 'breed',
                          data: petBreed,
                        ),
                        Divider(),
                        DetailBar(
                          icon: Icons.yard_outlined,
                          detail: 'Age',
                          data: pet.age,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 32, 0, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        showEditPetPopup(
                          context, // <== positional argument
                          pet: widget.pet,
                          onPetUpdated: () {
                            setState(() {
                              // You likely intended to navigate, not just rebuild
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Welcome(user: widget.user),
                                ),
                              );
                            });
                          },
                        );
                      },

                      /* */
                      icon: Icon(
                        Icons.edit,
                        color: const Color(0xFFFFFFFF),
                        size: 20,
                      ),
                      label: Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontFamily: 'Inter Tight',
                          color: Color(0xFFFFFFFF),
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
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'are you sure?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to delete this pet?',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Color(0xFFE91E63),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(true); // Close the dialog
                                    deletePet(widget
                                        .pet.pid); // Then execute the action
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Color(0xB3F7F5F5),
                                      ),
                                      child: Text(
                                        'Confirm',
                                        style: TextStyle(
                                          color: Color(0xFFE91E63),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
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
            ],
          ),
        ),
      ),
    );
  }
}
