import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showAddUserDialog(
  BuildContext context, {
  String? userId,
  String? initialFirstName,
  String? initialLastName,
  String? initialEmail,
  String? initialRole,
}) {
  final firstNameController =
      TextEditingController(text: initialFirstName ?? '');
  final lastNameController = TextEditingController(text: initialLastName ?? '');
  final emailController = TextEditingController(text: initialEmail ?? '');
  String selectedRole = initialRole ?? 'user';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          userId != null ? 'Edit User' : 'Add New User',
          style: TextStyle(
            color: Color(0xFF0D16B2),
            fontFamily: 'Mikhak',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              _styledTextField('First Name', firstNameController),
              SizedBox(height: 16),
              _styledTextField('Last Name', lastNameController),
              SizedBox(height: 16),
              _styledTextField('Email', emailController),
              SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedRole,
                onChanged: (value) {
                  if (value != null) {
                    selectedRole = value;
                  }
                },
                items: ['admin', 'vet', 'user']
                    .map((role) =>
                        DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF0D16B2),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0D16B2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () async {
              final firstName = firstNameController.text.trim();
              final lastName = lastNameController.text.trim();
              final email = emailController.text.trim();

              if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final userData = {
                'firstName': firstName,
                'lastName': lastName,
                'email': email,
                'role': selectedRole,
              };

              if (userId != null) {
                // Editing existing user
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update(userData);
              } else {
                // Adding new user
                await FirebaseFirestore.instance
                    .collection('users')
                    .add(userData);
              }

              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            },
            child: Text(
              userId != null ? 'Update' : 'Add',
            ),
          ),
        ],
      );
    },
  );
}

Widget _styledTextField(String label, TextEditingController controller,
    {bool isNumber = false}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF0D16B2)),
        borderRadius: BorderRadius.circular(25),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
      ),
    ),
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
  );
}
