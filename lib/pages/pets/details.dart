import 'package:flutter/material.dart';

class DetailBar extends StatefulWidget {
  final IconData icon;
  final String detail;
  final String data;

  const DetailBar({
    super.key,
    required this.icon,
    required this.detail,
    required this.data,
  });

  @override
  State<DetailBar> createState() => _DetailBarState();
}

class _DetailBarState extends State<DetailBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              widget.icon,
              color: const Color(0xFFE91E63),
              size: 24,
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.detail,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: Color.fromARGB(153, 0, 0, 0),
                    ),
                  ),
                  Text(
                    widget.data,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 8,
        ),
      ],
    );
  }
}
