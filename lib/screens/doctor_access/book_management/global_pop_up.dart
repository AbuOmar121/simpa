import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simpa/firebase/models/pill_model.dart';

// ignore: non_constant_identifier_names
void GlobalPopUp(BuildContext context,
    {required String pid,required String bid}) {
  final formKey = GlobalKey<FormState>();
  Pill? selectedPill;
  int isPillEnabled = 0;

  Future<List<Pill>> fetchPillData() async {
    try {
      final querySnapshot =
      await FirebaseFirestore.instance.collection('pills').get();

      return querySnapshot.docs.map((doc) {
        return Pill.fromDocumentSnapshot(doc);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Add Pill To Pet',
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
                    DropdownButtonFormField<int>(
                      value: isPillEnabled,
                      decoration: InputDecoration(
                        labelText: 'Pills Input?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(value: 0, child: Text("No")),
                        DropdownMenuItem(value: 1, child: Text("Yes")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          isPillEnabled = value!;
                          if (isPillEnabled == 0) {
                            selectedPill = null;
                          }
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    if (isPillEnabled == 1)
                      FutureBuilder<List<Pill>>(
                        future: fetchPillData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error loading pills');
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Text('No pills found');
                          } else {
                            final pills = snapshot.data!;
                            return DropdownButtonFormField<Pill>(
                              value: selectedPill,
                              items: pills.map((pill) {
                                return DropdownMenuItem<Pill>(
                                  value: pill,
                                  child: Text(pill.name),
                                );
                              }).toList(),
                              onChanged: (pill) {
                                setState(() {
                                  selectedPill = pill;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Select Pill',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.pink),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              validator: (value) {
                                if (isPillEnabled == 1 && value == null) {
                                  return 'Please select a pill';
                                }
                                return null;
                              },
                            );
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
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFFE91E63),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate() &&

                      (isPillEnabled == 0 || selectedPill != null)) {
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
                          .collection('pillpet')
                          .add({
                        'pid': pid,
                        'piid': isPillEnabled == 1
                            ? selectedPill!.piId
                            : null,
                        'bid':bid,
                        'date': FieldValue.serverTimestamp(),
                        'createdAt': FieldValue.serverTimestamp(),
                        'updatedAt': FieldValue.serverTimestamp(),
                      });

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Pet added successfully!')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error adding pet: $e')),
                        );
                      }
                    }
                  }
                },
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Color(0xFFE91E63),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
