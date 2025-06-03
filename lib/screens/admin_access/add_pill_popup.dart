import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpa/firebase/models/pill_model.dart';

void showAddPillDialog(
  BuildContext context,
  CollectionReference pillsCollection, {
  Pill? existingPill,
}) {
  final isEditing = existingPill != null;

  final nameController = TextEditingController(text: existingPill?.name ?? '');
  final expController = TextEditingController(
      text: existingPill != null ? existingPill.exp.toString() : '');
  final typeController = TextEditingController(text: existingPill?.type ?? '');
  final dosageController =
      TextEditingController(text: existingPill?.dosage ?? '');

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          isEditing ? 'Edit Pill' : 'Add New Pill',
          style: TextStyle(
            color: Color(0xFF021952),
            fontFamily: 'Mikhak',
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              _styledTextField('Pill Name', nameController),
              SizedBox(height: 16),
              _styledTextField('Expiration (days)', expController,
                  isNumber: true),
              SizedBox(height: 16),
              _styledTextField('Type', typeController),
              SizedBox(height: 14),
              _styledTextField('Dosage', dosageController),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0D16B2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(isEditing ? 'Update' : 'Add'),
            onPressed: () async {
              final name = nameController.text.trim();
              final exp = int.tryParse(expController.text.trim()) ?? 0;
              final type = typeController.text.trim();
              final dosage = dosageController.text.trim();
              final now = DateTime.now();

              if (name.isEmpty || type.isEmpty || dosage.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              if (isEditing) {
                await pillsCollection.doc(existingPill.piId).update({
                  'name': name,
                  'exp': exp,
                  'type': type,
                  'dosage': dosage,
                  'updatedAt': Timestamp.fromDate(now),
                });
              } else {
                final newPill = Pill(
                  piId: '',
                  name: name,
                  exp: exp,
                  type: type,
                  dosage: dosage,
                  createdAt: now,
                  updatedAt: now,
                );
                await pillsCollection.add(newPill.toMap());
              }

              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            },
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
