import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simpa/firebase/models/book_model.dart';
import 'package:simpa/screens/project_app_bar.dart';
import 'package:simpa/screens/user_access/pets/details.dart';
import 'package:simpa/screens/user_access/stylesAndDec/dec.dart';
import 'package:simpa/screens/user_access/welcomeScreen/welcome.dart';
import 'package:simpa/service/notification_service.dart';
import 'package:simpa/splash.dart';

class BookDetails extends StatefulWidget {
  final String bid;
  final String petName;
  const BookDetails({super.key, required this.bid, required this.petName});

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  late Future<Book?> _bookFuture;

  @override
  void initState() {
    super.initState();
    _bookFuture = _fetchBookData();
  }

  Future<Book?> _fetchBookData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bid)
          .get();

      if (docSnapshot.exists) {
        return Book.fromDocumentSnapshot(docSnapshot);
      } else {
        return null;
      }
    } catch (e) {
      // print('Error fetching booking: $e');
      return null;
    }
  }

  Future<void> _saveNoti(book) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final docRef =
      FirebaseFirestore.instance.collection('notifications').doc();

      await docRef.set({
        'title': 'Booking System',
        'content': 'Book cancel in ${DateFormat.yMMMMd().add_jm().format(DateTime.now())}',
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    // ignore: empty_catches
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE1E1),
      appBar: ProjectAppBar(title: 'Book Details'),
      body: FutureBuilder<Book?>(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Splash(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('An error occurred.'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No booking found.'));
          }

          final book = snapshot.data!;

          return Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.petName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  decoration: BoxDec.style,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DetailBar(
                        icon: Icons.flutter_dash_outlined,
                        detail: 'Reason',
                        data: book.reason,
                      ),
                      Divider(
                        color: Colors.pink,
                      ),
                      DetailBar(
                        icon: Icons.description_outlined,
                        detail: 'Description',
                        data: book.desc != ''
                            ? book.desc
                            : 'their is no description',
                      ),
                      Divider(
                        color: Colors.pink,
                      ),
                      DetailBar(
                        icon: Icons.check,
                        detail: 'status',
                        data: book.status,
                      ),
                      Divider(
                        color: Colors.pink,
                      ),
                      DetailBar(
                        icon: Icons.flutter_dash_outlined,
                        detail: 'Reason',
                        data: book.date != null
                            ? DateFormat('yyyy-MM-dd – kk:mm')
                                .format(book.date!)
                            : 'No date available',
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    FirebaseFirestore.instance
                        .collection('bookings')
                        .doc(widget.bid)
                        .update({'status': 'canceled'});

                    FirebaseMessagingService.instance.showNotification(
                      'Booking System - Simpa',
                      'Book - ${book.reason} - canceled successfully',
                    );

                    final user = FirebaseAuth.instance.currentUser;

                    _saveNoti(book);

                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Welcome(user: user),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No user is currently signed in.')),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: const Color(0xFFFFFFFF),
                    size: 24,
                  ),
                  label: Text(
                    'Cancel Book',
                    style: TextStyle(
                      fontFamily: 'Inter Tight',
                      color: Color(0xFFFFFFFF),
                      fontSize: 16,
                      letterSpacing: 0.0,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE91E63),
                    foregroundColor: Color(0xFFFFFFFF),
                    minimumSize: Size(350, 50),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.transparent),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
