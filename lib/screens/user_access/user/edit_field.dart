import 'package:flutter/material.dart';

class TxtField extends StatefulWidget {
  final TextEditingController controller;
  final String tag;

  const TxtField({super.key, required this.controller, required this.tag});

  @override
  State<TxtField> createState() => _TxtFieldState();
}

class _TxtFieldState extends State<TxtField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller, // Use the controller passed from parent
      decoration: InputDecoration(
        labelText: widget.tag,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.pink),
          borderRadius: BorderRadius.circular(25),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}
