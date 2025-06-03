// ignore_for_file: deprecated_member_use
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simpa/screens/authentication/loading_screen.dart';
import 'package:simpa/screens/doctor_access/book_management/book_manage.dart';
import 'package:simpa/screens/doctor_access/doc_chatting/choose_user.dart';
import 'package:simpa/screens/user_access/popups/exit_dialog.dart';

class DoctorWelcome extends StatefulWidget {
  final User user;
  const DoctorWelcome({super.key, required this.user});

  @override
  State<DoctorWelcome> createState() => _DoctorWelcomeState();
}

class _DoctorWelcomeState extends State<DoctorWelcome> {
  @override
  Widget build(BuildContext context) {
    Future<void> signOut() async {
      try {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (_) => LoadingScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to sign out')),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFFB9DEDE),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Vet Site',
          style: TextStyle(
            fontSize: 26,
            fontFamily: 'Mikhak',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0D16B2),
      ),
      body: WillPopScope(
        onWillPop: () => showExitConfirmationDialog(context),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                height: 16,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChooseUser(user: widget.user,),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0D16B2),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Direct Messages',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookManagement(user:widget.user),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0D16B2),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Manage Books',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0D16B2),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
