import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simpa/pages/settings.dart';

class UserCard extends StatefulWidget {
  final User user;
  final String firstname;
  final String email;
  final String phone;

  const UserCard({
    super.key,
    required this.user,
    required this.firstname,
    required this.email,
    required this.phone,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsScreen(user: widget.user),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF8F8F8),
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                color: Color.fromRGBO(0, 0, 0, 0.125),
                offset: Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(178, 178, 178, 1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/User.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, size: 60, color: Colors.grey);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${widget.firstname}!',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(31, 31, 31, 1),
                          ),
                        ),
                        Text(
                          '${widget.email} - ${widget.phone}',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            color: Color.fromRGBO(31, 31, 31, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Color.fromRGBO(31, 31, 31, 1),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
