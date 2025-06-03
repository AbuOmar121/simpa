import 'package:flutter/material.dart';

Future<bool?> showSureForDeleteDialog(
    BuildContext context, VoidCallback onConfirm) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Are you sure?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this pet?',
          style: TextStyle(fontSize: 15),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFE91E63)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              onConfirm();
            },
            child: Text(
              'Confirm',
              style: TextStyle(color: Color(0xFFE91E63)),
            ),
          ),
        ],
      );
    },
  );
}