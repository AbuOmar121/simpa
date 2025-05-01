import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simpa/screens/user_access/user/edit_field.dart';
import 'package:simpa/screens/user_access/user/user_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
// import 'package:simpa/screens/user_access/welcomeScreen/welcome.dart';

class EditProfile extends StatefulWidget {
  final auth.User user;
  const EditProfile({super.key, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late Future<Map<String, dynamic>> _userDataFuture;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();

    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();

    _userDataFuture = _fetchUserData().then((userData) {
      if (mounted) {
        setState(() {
          firstNameController.text = userData['firstName']?.toString() ?? '';
          lastNameController.text = userData['lastName']?.toString() ?? '';
          phoneController.text = userData['phone']?.toString() ?? '';
        });
      }
      return userData;
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
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

  void confirm() {
    Navigator.of(context).pop();
    setState(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserProfileScreen(user: widget.user),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE1E1),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Color(0xFFFF4F81),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            // AreYouSure(
            //   title: 'Discard?',
            //   content: 'Are you sure you want to cancel editing your account?',
            //   onConfirm: () => print('test'),
            // );
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: 'Inter Tight',
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data?['error'] != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Color(0xFFF44336), size: 48),
                  SizedBox(height: 16),
                  Text(
                    snapshot.data?['error'] ?? 'An error occurred',
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _userDataFuture = _fetchUserData();
                      });
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.all(18),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Text(
                    'Edit your Details',
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xFF000000),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Color.fromRGBO(0, 0, 0, 0.125),
                          offset: Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 16),
                          Text(
                            'Testing',
                            style: TextStyle(
                              fontSize: 22,
                              color: Color(0xff000000),
                            ),
                          ),
                          SizedBox(height: 32),
                          TxtField(
                            controller: firstNameController,
                            tag: 'First Name',
                          ),
                          SizedBox(height: 32),
                          TxtField(
                            controller: lastNameController,
                            tag: 'Last Name',
                          ),
                          SizedBox(height: 32),
                          TxtField(
                            controller: phoneController,
                            tag: 'Phone',
                          ),
                          SizedBox(height: 32),
                        ],
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
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.user.uid)
                                  .update({
                                'firstName': firstNameController.text.trim(),
                                'lastName': lastNameController.text.trim(),
                                'phone': phoneController.text.trim(),
                              });

                              if (context.mounted) {
                                confirm();
                              }
                            } catch (e) {}
                          },
                          icon: Icon(
                            Icons.check,
                            color: const Color(0xFFFFFFFF),
                            size: 24,
                          ),
                          label: Text(
                            'Confirm Edits',
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
