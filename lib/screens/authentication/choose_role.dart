import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:simpa/screens/admin_access/welcome/welcome_admin.dart';
import 'package:simpa/screens/doctor_access/doctor_welcome.dart';
import 'package:simpa/screens/user_access/welcomeScreen/welcome.dart';
import 'package:simpa/splash.dart';

class ChooseRole extends StatefulWidget {
  final auth.User user;
  const ChooseRole({super.key, required this.user});

  @override
  State<ChooseRole> createState() => _ChooseRoleState();
}

class _ChooseRoleState extends State<ChooseRole> {
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      if (!doc.exists) {
        return {'error': 'User data not found'};
      }

      return doc.data()!;
    } catch (e) {
      return {'error': 'Failed to load user data'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Color(0xFFFFE1E1),
            body: Center(
              child: Splash(),
            ),
          );
        }

        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.containsKey('error')) {
          return Scaffold(
            backgroundColor: Color(0xFFFFE1E1),
            body: Center(
              child: Text('Failed to load user data'),
            ),
          );
        }

        final role = snapshot.data!['role'] ?? 'user';

        if (role == 'admin') {
          return WelcomeAdmin(user: widget.user);
        }
        if (role == 'vet') {
          return DoctorWelcome(user: widget.user);
        }
        return Welcome(user: widget.user);
      },
    );
  }
}
