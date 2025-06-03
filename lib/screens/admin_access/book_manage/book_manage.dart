import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simpa/firebase/models/book_model.dart';
import 'package:simpa/screens/admin_access/admin_app_bar.dart';
import 'package:simpa/screens/admin_access/add_booking_popup.dart';
import 'package:simpa/screens/user_access/stylesAndDec/dec.dart';
import 'package:simpa/splash.dart';

class BookManage extends StatefulWidget {
  const BookManage({super.key});

  @override
  State<BookManage> createState() => _BookManageState();
}

class _BookManageState extends State<BookManage> {
  final bookingsCollection = FirebaseFirestore.instance.collection('bookings');

  void _deleteBooking(String id) async {
    await bookingsCollection.doc(id).delete();
  }

  void _editBooking(Book book) {
    showAddOrEditBookingDialog(
      context,
      bookingsCollection,
      existingBooking: book,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB9DEDE),
      appBar: AdminAppBar(title: 'Manage Bookings'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddOrEditBookingDialog(context, bookingsCollection),
        child: Icon(Icons.add, color: Color(0xFF0D16B2)),
      ),
      body: StreamBuilder<QuerySnapshot>(
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

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              if (allBookings.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No bookings found.'),
                  ),
                )
              else
                ...allBookings.map(
                      (book) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Container(
                      decoration: BoxDec.style,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          ListTile(
                            title: Text(book.reason),
                            subtitle: Text(
                              'Desc: ${book.desc}\nDate: ${book.date?.toLocal().toString().split(' ')[0] ?? 'N/A'}\nStatus: ${book.status}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editBooking(book),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteBooking(book.bid),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
