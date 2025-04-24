import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simpa/firebase/models/pet_model.dart';

void showEditPetPopup(
  BuildContext context, {
  required Pet pet,
  required void Function() onPetUpdated,
}) {
  final formKey = GlobalKey<FormState>();
  final petNameController = TextEditingController(text: pet.petName);
  final petBreedController = TextEditingController(text: pet.petBreed);
  String petType = pet.petType;
  String petGender = pet.petGender;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Edit Pet Profile',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFFE91E63),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: petNameController,
                  decoration: InputDecoration(
                    labelText: 'Pet name',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a pet name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: petType,
                  items: ['Cat', 'Dog', 'Bird', 'Rabbit', 'Other'].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) petType = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Pet Type',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: petBreedController,
                  decoration: InputDecoration(
                    labelText: 'Pet Breed',
                    hintText: 'Enter pet breed',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a breed';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: petGender,
                  items: ['Male', 'Female'].map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) petGender = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Pet Gender',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFFE91E63),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please sign in first')),
                    );
                  }
                  return;
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('pets')
                      .doc(pet.pid)
                      .update({
                    'name': petNameController.text.trim(),
                    'type': petType,
                    'breed': petBreedController.text.trim(),
                    'gender': petGender,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    onPetUpdated();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pet updated successfully!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating pet: $e'),
                      ),
                    );
                  }
                }
              }
            },
            child: Text(
              'Update',
              style: TextStyle(
                color: Color(0xFFE91E63),
              ),
            ),
          ),
        ],
      );
    },
  );
}
