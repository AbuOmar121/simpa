import 'package:flutter/material.dart';

class StyledTile extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const StyledTile({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontSize: 18,
            letterSpacing: 0.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        dense: false,
        onTap: onTap,
      ),
    );
  }
}

class AppInfo extends StatelessWidget {
  final String info;
  final String det;

  const AppInfo({super.key, required this.info, required this.det});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          info,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontSize: 18,
            letterSpacing: 0.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        Text(
          det,
          style: TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF757575),
            fontSize: 18,
            letterSpacing: 0.0,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
