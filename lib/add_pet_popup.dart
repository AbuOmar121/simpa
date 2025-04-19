import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

void showAddPetPopup(BuildContext context,
    {required void Function() onPetAdded}) {
  final _formKey = GlobalKey<FormState>();
  final petNameController = TextEditingController();
  final petBreedController = TextEditingController();
  String petType = '';
  String petGender = '';
  DateTime? birthDate;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add a New Pet'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: petNameController,
                  decoration: const InputDecoration(
                    labelText: 'Pet Name',
                    hintText: 'Enter pet name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a pet name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  items: ['Cat', 'Dog', 'Bird', 'Rabbit', 'Other'].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) petType = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Pet Type',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: petBreedController,
                  decoration: const InputDecoration(
                    labelText: 'Pet Breed',
                    hintText: 'Enter pet breed',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a breed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  items: ['Male', 'Female'].map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) petGender = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Pet Gender',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    birthDate == null
                        ? 'Select Birth Date'
                        : 'Birth Date: ${DateFormat('yyyy-MM-dd').format(birthDate!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now());
                    if (selectedDate != null) {
                      birthDate = selectedDate;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() && birthDate != null) {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please sign in first')),
                    );
                  }
                  return;
                }

                try {
                  await FirebaseFirestore.instance.collection('pets').add({
                    'name': petNameController.text.trim(),
                    'type': petType,
                    'breed': petBreedController.text.trim(),
                    'gender': petGender,
                    'birthDate': Timestamp.fromDate(birthDate!),
                    'ownerId': user.uid,
                    'createdAt': FieldValue.serverTimestamp(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    onPetAdded();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pet added successfully!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding pet: $e')),
                    );
                  }
                }
              } else if (birthDate == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a birth date')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
