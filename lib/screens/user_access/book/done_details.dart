import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simpa/firebase/models/book_model.dart';
import 'package:simpa/firebase/models/pill_model.dart';
import 'package:simpa/screens/project_app_bar.dart';
import 'package:simpa/screens/user_access/pets/details.dart';
import 'package:simpa/screens/user_access/stylesAndDec/dec.dart';
import 'package:simpa/splash.dart';

class DoneDetails extends StatefulWidget {
  final String bid;
  final String petName;
  const DoneDetails({super.key, required this.bid, required this.petName});

  @override
  State<DoneDetails> createState() => _DoneDetailsState();
}

class _DoneDetailsState extends State<DoneDetails> {
  late Future<Book?> _bookFuture;
  List<Pill> _pills = [];

  @override
  void initState() {
    super.initState();
    _bookFuture = _fetchBookData();
    _fetchPillsForBooking(widget.bid);
  }

  Future<Book?> _fetchBookData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bid)
          .get();
      if (doc.exists) {
        return Book.fromDocumentSnapshot(doc);
      }
      // ignore: empty_catches
    } catch (e) {}
    return null;
  }

  Future<void> _fetchPillsForBooking(String bid) async {
    try {
      final pillPetQuery = await FirebaseFirestore.instance
          .collection('pillpet')
          .where('bid', isEqualTo: bid)
          .get();

      final pillPetDocs = pillPetQuery.docs;

      final pillIds = pillPetDocs.map((doc) => doc['piid'] as String).toList();

      List<Pill> pills = [];
      for (String id in pillIds) {
        final pillDoc =
            await FirebaseFirestore.instance.collection('pills').doc(id).get();

        if (pillDoc.exists) {
          pills.add(Pill.fromDocumentSnapshot(pillDoc));
        }
      }

      setState(() {
        _pills = pills;
      });
      // ignore: empty_catches
    } catch (e) {}
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
            return Center(child: Splash());
          } else if (snapshot.hasError) {
            return Center(child: Text('An error occurred.'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No booking found.'));
          }

          final book = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.petName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  SizedBox(height: 16),
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
                        Divider(color: Colors.pink),
                        DetailBar(
                          icon: Icons.description_outlined,
                          detail: 'Description',
                          data: book.desc.isNotEmpty
                              ? book.desc
                              : 'There is no description',
                        ),
                        Divider(color: Colors.pink),
                        DetailBar(
                          icon: Icons.check,
                          detail: 'Status',
                          data: book.status,
                        ),
                        Divider(color: Colors.pink),
                        DetailBar(
                          icon: Icons.date_range,
                          detail: 'Date',
                          data: book.date != null
                              ? DateFormat('yyyy-MM-dd – kk:mm')
                                  .format(book.date!)
                              : 'No date available',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Pills for this booking",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _pills.isEmpty
                      ? Text("No pills found.")
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _pills.length,
                          itemBuilder: (context, index) {
                            final pill = _pills[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 2,
                              child: ListTile(
                                leading:
                                    Icon(Icons.medication, color: Colors.pink),
                                title: Text(
                                  pill.name,

                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8,),
                                    Text('Type: ${pill.type}'),
                                    Text('Dosage: ${pill.dosage}'),
                                    Text('Exp: ${pill.exp} days'),
                                    Text(
                                        'Created: ${DateFormat('yyyy-MM-dd').format(pill.createdAt)}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
