import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simpa/screens/authentication/loading_screen.dart';
import 'package:simpa/screens/user_access/settings/main/account_information.dart';
import 'package:simpa/screens/user_access/settings/main/changePassword/account_settings.dart';
import 'package:simpa/screens/user_access/stylesAndDec/dec.dart';
import 'package:simpa/splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpa/screens/user_access/stylesAndDec/style.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  final User user;
  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String appname = '';
  String version = '';

  //late Future<Map<String, dynamic>> _userDataFuture;
  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    // _userDataFuture = _fetchUserData();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appname = info.appName;
      version = info.version;
    });
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

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoadingScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign out')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE1E1),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Splash());
          }
          if (snapshot.hasError || snapshot.data?['error'] != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 50, color: Color(0xFFF44336)),
                  SizedBox(height: 16),
                  Text(
                    snapshot.data?['error'] ?? 'Error loading user data',
                    style: TextStyle(fontSize: 18, color: Color(0xFFFF4081)),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          }

          final userData = snapshot.data!;
          final firstName = userData['firstName'] as String? ?? '';
          final lastName = userData['lastName'] as String? ?? '';
          final email = userData['email'] as String? ?? '';
          final createdAt = userData['createdAt'] as Timestamp?;

          return SafeArea(
            top: true,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDec.style,
                        child: AccountInformation(
                          firstName: firstName,
                          lastName: lastName,
                          email: email,
                          lastUpdate: createdAt!.toDate().toLocal(),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    AccountSettings(user: widget.user, email: email),
                    SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      decoration: BoxDec.style,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Application Details',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter Tight',
                                color: Color(0xFFFF4081),
                              ),
                            ),
                            SizedBox(height: 32),
                            AppInfo(info: 'Version', det: version),
                            SizedBox(height: 16),
                            AppInfo(info: 'App name', det: appname),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    // ignore: sized_box_for_whitespace
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF50057),
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 32),
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
                    SizedBox(
                      height: 32,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}