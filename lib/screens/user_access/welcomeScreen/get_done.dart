import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:simpa/firebase/models/book_model.dart';
import 'package:simpa/firebase/models/pet_model.dart';
import 'package:simpa/screens/user_access/Book/done_details.dart';
import 'package:simpa/screens/user_access/stylesAndDec/dec.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:async/async.dart';

class GetDone extends StatefulWidget {
  final auth.User user;
  const GetDone({super.key, required this.user});

  @override
  State<GetDone> createState() => _GetDoneState();
}

class _GetDoneState extends State<GetDone> {
  Stream<List<Pet>> _petsStream() {
    return FirebaseFirestore.instance
        .collection('pets')
        .where('ownerId', isEqualTo: widget.user.uid)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Pet.fromDocumentSnapshot(doc)).toList());
  }

  Stream<List<Book>> _bookStream() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: widget.user.uid)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Book.fromDocumentSnapshot(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDec.style,
      child: StreamBuilder<List<dynamic>>(
        stream: StreamZip([_bookStream(), _petsStream()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: Colors.pink),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Failed to load appointments',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(31, 31, 31, 1),
                  ),
                ),
              ),
            );
          }

          final books = snapshot.data![0] as List<Book>;
          final pets = snapshot.data![1] as List<Pet>;

          // Filter only completed or canceled bookings
          final filteredBooks = books.where((book) {
            return book.status != 'in progress' && book.status != 'pending';
          }).toList();

          if (filteredBooks.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'There are no completed appointments',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(31, 31, 31, 1),
                  ),
                ),
              ),
            );
          }

          return Column(
            children: filteredBooks.map((book) {
              final pet = pets.firstWhere(
                    (p) => p.pid == book.pid,
                orElse: () => Pet(
                  pid: '',
                  petName: 'Unknown Pet',
                  petType: '',
                  petBreed: '',
                  petGender: '',
                  birthdate: null,
                  uid: '',
                ),
              );

              final statusIcon = book.status == 'canceled'
                  ? Icon(Icons.cancel, color: Colors.red, size: 24)
                  : Icon(Icons.done, color: Colors.green, size: 24);

              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoneDetails(
                            bid: book.bid,
                            petName: pet.petName,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Icon(
                                Icons.pets,
                                color: Colors.pink,
                                size: 42,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${pet.petName} - ${book.reason}',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(31, 31, 31, 1),
                                    ),
                                  ),
                                  Text(
                                    book.date != null
                                        ? DateFormat.yMMMMd().add_jm().format(book.date!)
                                        : 'No date available',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 14,
                                      color: Color.fromRGBO(31, 31, 31, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          statusIcon,
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: Color(0xFFFA9DBC),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
