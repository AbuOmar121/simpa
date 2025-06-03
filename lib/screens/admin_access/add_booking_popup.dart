import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpa/firebase/models/book_model.dart';

void showAddOrEditBookingDialog(
    BuildContext context,
    CollectionReference bookingsCollection, {
      Book? existingBooking,
    }) {
  final reasonController = TextEditingController(text: existingBooking?.reason ?? '');
  final descController = TextEditingController(text: existingBooking?.desc ?? '');
  DateTime? selectedDate = existingBooking?.date;
  String petId = existingBooking?.pid ?? '';
  String userId = existingBooking?.uid ?? '';
  String status = existingBooking?.status ?? 'pending';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          existingBooking == null ? 'Add Booking' : 'Edit Booking',
          style: const TextStyle(
            color: Color(0xFF0D16B2),
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Mikhak',
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _styledTextField('Reason', reasonController),
              const SizedBox(height: 12),
              _styledTextField('Description', descController),
              const SizedBox(height: 12),

              // Only show Pet ID & User ID in Add mode
              if (existingBooking == null) ...[
                _styledTextField(
                  'Pet ID',
                  TextEditingController(text: petId),
                  onChanged: (val) => petId = val,
                ),
                const SizedBox(height: 12),
                _styledTextField(
                  'User ID',
                  TextEditingController(text: userId),
                  onChanged: (val) => userId = val,
                ),
                const SizedBox(height: 12),
              ],

              // Only show status in Edit mode
              if (existingBooking != null) ...[
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  items: ['pending', 'done', 'in progress', 'canceled']
                      .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value[0].toUpperCase() + value.substring(1)),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      status = value;
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],

              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) selectedDate = picked;
                },
                child: Text(selectedDate == null
                    ? 'Pick Date'
                    : 'Date: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              final desc = descController.text.trim();

              // Description is NOT required now
              if (reason.isEmpty || (existingBooking == null && (petId.isEmpty || userId.isEmpty))) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
                return;
              }

              final data = Book(
                bid: existingBooking?.bid ?? '',
                reason: reason,
                desc: desc, // Can be empty
                date: selectedDate,
                pid: petId,
                uid: userId,
                createdAt: existingBooking?.createdAt ?? DateTime.now(),
                status: status,
              ).toMap();

              if (existingBooking == null) {
                await bookingsCollection.add(data);
              } else {
                await bookingsCollection.doc(existingBooking.bid).update(data);
              }

              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            },
            child: Text(
              existingBooking == null ? 'Add' : 'Update',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      );
    },
  );
}

// Modified to allow optional onChanged handler
Widget _styledTextField(String label, TextEditingController controller,
    {bool isNumber = false, void Function(String)? onChanged}) {
  return TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF0D16B2)),
        borderRadius: BorderRadius.circular(25),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
      ),
    ),
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
  );
}
