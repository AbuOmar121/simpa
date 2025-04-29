import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simpa/firebase/models/user_model.dart';
import 'package:simpa/screens/user_access/user/edit_field.dart';

class EditProfile extends StatefulWidget {
  final User user;
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
    // Initialize controllers with empty values first
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();

    _userDataFuture = _fetchUserData().then((userData) {
      if (mounted) {
        setState(() {
          firstNameController.text = widget.user.firstName ?? '';
          lastNameController.text = widget.user.lastName ?? '';
          phoneController.text = userData['phone']?.toString() ?? '';
          emailController.text = widget.user.email ?? '';
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
                          Text(
                            'Testing',
                            style: TextStyle(
                              fontSize: 22,
                              color: Color(0xff000000),
                            ),
                          ),
                          SizedBox(height: 16),
                          TxtField(
                            controller: firstNameController,
                            tag: 'First Name',
                          ),
                          SizedBox(height: 16),
                          TxtField(
                            controller: lastNameController,
                            tag: 'Last Name',
                          ),
                          SizedBox(height: 16),
                          TxtField(
                            controller: phoneController,
                            tag: 'Phone',
                          ),
                          SizedBox(height: 16),
                          TxtField(
                            controller: emailController,
                            tag: 'Email',
                          ),
                          SizedBox(height: 16),
                          Text(
                            firstNameController.text,
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xff000000),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
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
