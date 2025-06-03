import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:simpa/firebase/models/pet_model.dart';
import 'package:simpa/screens/user_access/popups/edit_popup.dart';
import 'package:simpa/screens/user_access/welcomeScreen/welcome.dart';

class ProfilesButtons extends StatefulWidget {
  final auth.User user;
  final Pet pet;
  const ProfilesButtons({super.key,required this.user,required this.pet});

  @override
  State<ProfilesButtons> createState() => _ProfilesButtonsState();
}

class _ProfilesButtonsState extends State<ProfilesButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            showEditPetPopup(
              context,
              pet: widget.pet,
              onPetUpdated: () {
                setState(
                      () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Welcome(user: widget.user),
                      ),
                    );
                  },
                );
              },
            );
          },
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
    );
  }
}
