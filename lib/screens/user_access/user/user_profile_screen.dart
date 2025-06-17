import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart' as st;
import 'package:simpa/screens/project_app_bar.dart';
import 'package:simpa/screens/user_access/user/edit_profile.dart';
import 'package:simpa/splash.dart';

class UserProfileScreen extends StatefulWidget {
  final auth.User user;
  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      final doc = await st.FirebaseFirestore.instance
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
      // appBar: ProjectAppBar(title: 'My Profile'),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Splash());
          }

          if (snapshot.hasError || snapshot.data?['error'] != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    snapshot.data?['error'] ?? 'An error occurred',
                    style: Theme.of(context).textTheme.bodyLarge,
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

          final userData = snapshot.data!;
          final createdAt = userData['createdAt'] as st.Timestamp?;
          final firstName = userData['firstName'] as String? ?? '';
          final lastName = userData['lastName'] as String? ?? '';
          final phone = userData['phone'] as String? ?? 'Not provided';
          final email = userData['email'] as String? ?? '';
          final lastUpdate = userData['updatedAt'] as st.Timestamp;

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0xFFFF4081),
                            child: Text(
                              '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '$firstName $lastName',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    Divider(),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Container(
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
                          padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailTile(
                                icon: Icons.calendar_month,
                                title: 'joined at',
                                value: createdAt != null
                                    ? createdAt
                                        .toDate()
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0]
                                    : 'Unknown',
                              ),
                              Divider(),
                              _buildDetailTile(
                                icon: Icons.email,
                                title: 'Email',
                                value: email,
                              ),
                              Divider(),
                              _buildDetailTile(
                                icon: Icons.phone,
                                title: 'phone number',
                                value: phone,
                              ),
                              Divider(),
                              _buildDetailTile(
                                icon: Icons.abc,
                                title: 'last profile update',
                                value: lastUpdate
                                    .toDate()
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0],
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditProfile(user: widget.user),
                                ),
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
                              backgroundColor: Color(0xFFFF4081),
                              foregroundColor: Color(0xFFFFFFFF),
                              minimumSize: Size(300, 50),
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
                    SizedBox(
                      height: 64,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFFFF4081),),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
