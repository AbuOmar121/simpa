import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:simpa/firebase/models/book_model.dart';
import 'package:simpa/screens/admin_access/admin_app_bar.dart';
import 'package:simpa/screens/doctor_access/book_management/global_pop_up.dart';
import 'package:simpa/screens/doctor_access/book_management/next_book.dart';
import 'package:simpa/screens/user_access/stylesAndDec/dec.dart';
import 'package:simpa/splash.dart';

class BookManagement extends StatefulWidget {
  final auth.User user;
  const BookManagement({super.key, required this.user});

  @override
  State<BookManagement> createState() => _BookManagementState();
}

class _BookManagementState extends State<BookManagement> {
  final bookingsCollection = FirebaseFirestore.instance.collection('bookings');
  DateTime selectedDate = DateTime.now();

  void _deleteBooking(String id) async {
    await bookingsCollection.doc(id).update({'status': 'canceled'});
  }

  void _inProgress(String id) async {
    await bookingsCollection.doc(id).update({'status': 'in progress'});
  }

  void _done(String id) async {
    await bookingsCollection.doc(id).update({'status': 'done'});
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget buildTrailingButtons(Book book) {
    List<Widget> buttons = [];

    if (book.status == 'pending') {
      buttons.add(
        IconButton(
          icon: Icon(Icons.incomplete_circle_sharp, color: Colors.blue),
          onPressed: () => _inProgress(book.bid),
        ),
      );

      buttons.add(
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteBooking(book.bid),
        ),
      );
    }

    if (book.status == 'in progress') {
      buttons.add(
        IconButton(
            icon: Icon(
              Icons.check_sharp,
              color: Colors.green,
              size: 33,
            ),
            onPressed: () {
              GlobalPopUp(context, bid: book.bid, pid: book.pid);
              nextBook(context, pid: book.pid);
              _done(book.bid);
            }),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: buttons,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB9DEDE),
      appBar: AdminAppBar(title: 'Book Management'),
      body: Column(
        children: [
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: _pickDate,
              icon: Icon(Icons.calendar_today),
              label: Text(
                'Pick Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
              ),
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: bookingsCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading bookings'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: Splash());
                }

                final allBookings = snapshot.data!.docs
                    .map((doc) => Book.fromDocumentSnapshot(doc))
                    .toList();

                final filteredBookings = allBookings.where((book) {
                  if (book.date == null) return false;
                  final date = book.date!;
                  return date.year == selectedDate.year &&
                      date.month == selectedDate.month &&
                      date.day == selectedDate.day;
                }).toList();

                if (filteredBookings.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No bookings for selected date.',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 80),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final book = filteredBookings[index];

                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDec.style,
                        child: Column(
                          children: [
                            SizedBox(height: 8),
                            ListTile(
                              title: Text(book.reason),
                              subtitle: Text(
                                'Desc: ${book.desc}\n'
                                'Date: ${book.date?.toLocal().toString().split(' ')[0] ?? 'N/A'}\n'
                                'Status: ${book.status}',
                              ),
                              trailing: buildTrailingButtons(book),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
