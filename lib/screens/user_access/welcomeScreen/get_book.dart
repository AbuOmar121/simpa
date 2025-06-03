import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:simpa/firebase/models/book_model.dart';
import 'package:simpa/firebase/models/pet_model.dart';
import 'package:simpa/screens/user_access/Book/book_details.dart';
import 'package:simpa/screens/user_access/stylesAndDec/dec.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:async/async.dart';

class GetBook extends StatefulWidget {
  final auth.User user;
  const GetBook({super.key, required this.user});

  @override
  State<GetBook> createState() => _GetBookState();
}

class _GetBookState extends State<GetBook> {
  Stream<List<Book>> _bookStream() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: widget.user.uid)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Book.fromDocumentSnapshot(doc)).toList());
  }

  Stream<List<Pet>> _petsStream() {
    return FirebaseFirestore.instance
        .collection('pets')
        .where('ownerId', isEqualTo: widget.user.uid)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Pet.fromDocumentSnapshot(doc)).toList());
  }

  static Pet deletedPetPlaceholder = Pet(
    pid: '',
    petName: 'DELETED-deleted-123456789',
    petType: '',
    petBreed: '',
    petGender: '',
    birthdate: null,
    uid: '',
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDec.style,
      child: StreamBuilder<List<dynamic>>(
        stream: StreamZip([_bookStream(), _petsStream()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: Colors.pink),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Padding(
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

          final filteredBooks = books.where((book) {
            final pet = pets.firstWhere(
                  (p) => p.pid == book.pid,
              orElse: () => deletedPetPlaceholder,
            );
            return (book.status == 'in progress' || book.status == 'pending') &&
                pet.petName != deletedPetPlaceholder.petName;
          }).toList();

          if (filteredBooks.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'You have no pending appointments.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(31, 31, 31, 1),
                  ),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
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

                final petName = pet.petName;

                // Choose icon based on status
                Widget statusIcon;
                if (book.status == 'pending') {
                  statusIcon = const Icon(
                    Icons.hourglass_empty,
                    color: Colors.orange,
                    size: 24,
                  );
                } else if (book.status == 'in progress') {
                  statusIcon = const Icon(
                    Icons.autorenew,
                    color: Colors.blue,
                    size: 24,
                  );
                } else {
                  statusIcon = const Icon(
                    Icons.calendar_today,
                    color: Color.fromRGBO(31, 31, 31, 1),
                    size: 24,
                  );
                }

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookDetails(
                              bid: book.bid,
                              petName: petName,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFFFFF),
                                shape: BoxShape.circle,
                              ),
                              child: const ClipOval(
                                child: Icon(
                                  Icons.pets,
                                  color: Colors.pink,
                                  size: 42,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$petName - ${book.reason}',
                                      style: const TextStyle(
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
                                      style: const TextStyle(
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
                    const Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: Color(0xFFFA9DBC),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
