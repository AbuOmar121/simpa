import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:simpa/screens/user_access/settings/main/changePassword/changepassword.dart';
import 'package:simpa/screens/user_access/stylesAndDec/dec.dart';
import 'package:simpa/screens/user_access/stylesAndDec/style.dart';
import 'package:simpa/screens/user_access/user/edit_profile.dart';

class AccountSettings extends StatefulWidget {
  final auth.User user;
  final String email;
  const AccountSettings({super.key,required this.user,required this.email});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDec.style,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter Tight',
                color: Color(0xFFFF4081),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  StyledTile(
                    text: 'Edit Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditProfile(user: widget.user),
                        ),
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFFF4081),
                  ),
                  StyledTile(
                    text: 'Change Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangePassword(
                            email: widget.email,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
