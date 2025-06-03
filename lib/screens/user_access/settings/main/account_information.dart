import 'package:flutter/material.dart';

class AccountInformation extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final DateTime? lastUpdate;

  const AccountInformation({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.lastUpdate,
  });

  @override
  State<AccountInformation> createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            'account information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter Tight',
              color: Color(0xFFFF4081),
            ),
          ),
          SizedBox(height: 16),
          // User profile picture and name
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFFF3F3F),
                child: Text(
                  '${widget.firstName.isNotEmpty ? widget.firstName[0].toUpperCase() : ''}${widget.lastName.isNotEmpty ? widget.lastName[0].toUpperCase() : ''}',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
              SizedBox(width: 16),

              // User information
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.firstName} ${widget.lastName}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                      ),
                    ),
                    Text(
                      widget.email,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF757575),
                        fontSize: 14,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                      child: Text(
                        'last Update ${widget.lastUpdate != null ? widget.lastUpdate.toString().split(' ')[0] : ''}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF757575),
                          fontSize: 12,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
