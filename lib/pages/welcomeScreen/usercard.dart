import 'package:flutter/material.dart';

class UserCard extends StatefulWidget {
  final VoidCallback onPressed;
  final String firstname;
  final String lastname;
  final String email;
  final String phone;

  const UserCard({
    super.key,
    required this.onPressed,
    required this.firstname,
    required this.lastname,
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
        widget.onPressed();
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
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFFF3F3F),
                  child: Text(
                    '${widget.firstname.isNotEmpty ? widget.firstname[0] : ''}${widget.lastname.isNotEmpty ? widget.lastname[0] : ''}',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFFFFF),
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
