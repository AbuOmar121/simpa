import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpa/firebase/models/pet_model.dart';
import 'package:simpa/screens/user_access/user/edit_field.dart';

void nextBook(BuildContext context, {required String pid}) {
  final formKey = GlobalKey<FormState>();
  final reasonController = TextEditingController();
  final descController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String selectedOption = 'No'; // Changed from '0' to 'No'

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickDate() async {
            final DateTime now = DateTime.now();
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? now,
              firstDate: DateTime(now.year, now.month, now.day),
              lastDate: DateTime(2100),
            );

            if (picked != null) {
              setState(() {
                selectedDate = picked;
              });
            }
          }

          Future<void> pickTime() async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: selectedTime ?? TimeOfDay.now(),
            );

            if (picked != null) {
              if (picked.hour >= 21 || picked.hour < 9) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Allowed time is between 9:00 AM and 9:00 PM'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                setState(() {
                  selectedTime = picked;
                });
              }
            }
          }

          bool isFormValid() {
            return reasonController.text.isNotEmpty &&
                selectedDate != null &&
                selectedTime != null &&
                selectedTime!.hour >= 9 &&
                selectedTime!.hour < 21;
          }

          Future<Pet?> fetchPetData(String pid) async {
            try {
              final docSnapshot = await FirebaseFirestore.instance
                  .collection('pets')
                  .doc(pid)
                  .get();

              if (docSnapshot.exists) {
                return Pet.fromDocumentSnapshot(docSnapshot);
              }
            } catch (e) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return null;
          }

          Future<void> submitBooking() async {
            if (selectedOption == 'No') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Next Book is disabled.'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            if (!isFormValid()) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please fill all fields correctly.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            try {
              final DateTime fullDateTime = DateTime(
                selectedDate!.year,
                selectedDate!.month,
                selectedDate!.day,
                selectedTime!.hour,
                selectedTime!.minute,
              );

              Pet? pet = await fetchPetData(pid);

              await FirebaseFirestore.instance.collection('bookings').add({
                'userId': pet?.uid,
                'petId': pid,
                'reason': reasonController.text.trim(),
                'desc': descController.text.trim(),
                'dateTime': Timestamp.fromDate(fullDateTime),
                'status': 'pending',
                'createdAt': FieldValue.serverTimestamp(),
              });

              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking submitted!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to submit booking'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }

          return AlertDialog(
            title: Text(
              'Next Book',
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
                    // Dropdown with Yes / No options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Next Book: "),
                        SizedBox(width: 12),
                        DropdownButton<String>(
                          value: selectedOption,
                          items: ['No', 'Yes'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedOption = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (selectedOption == 'Yes') ...[
                      TxtField(
                        controller: reasonController,
                        tag: 'Reason',
                      ),
                      SizedBox(height: 16),
                      TxtField(
                        controller: descController,
                        tag: 'Description',
                      ),
                      SizedBox(height: 16),
                      InkWell(
                        onTap: pickDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Select Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            selectedDate != null
                                ? '${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}'
                                : 'Tap to pick a date',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      InkWell(
                        onTap: pickTime,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Select Time',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : 'Tap to pick a time',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFFE91E63)),
                ),
              ),
              ElevatedButton(
                onPressed: submitBooking,
                child: Text(
                  'Save',
                  style: TextStyle(color: Color(0xFFE91E63)),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
