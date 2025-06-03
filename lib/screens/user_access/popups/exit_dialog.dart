import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  final shouldExit = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Exit App?'),
      content: Text('Are you sure you want to close the app?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // Cancel
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () =>SystemNavigator.pop(),
          child: Text('Exit'),
        ),
      ],
    ),
  );
  return shouldExit ?? false;
}
