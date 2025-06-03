import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:simpa/firebase/models/pet_model.dart';
import 'package:simpa/screens/project_app_bar.dart';
import 'package:simpa/screens/user_access/stylesAndDec/dec.dart';
import 'package:simpa/screens/user_access/user/edit_field.dart';
import 'package:simpa/screens/user_access/welcomeScreen/welcome.dart';
import 'package:simpa/splash.dart';
import 'package:simpa/service/notification_service.dart';


class BookSystem extends StatefulWidget {
  final auth.User user;

  const BookSystem({super.key, required this.user});

  @override
  State<BookSystem> createState() => _BookSystemState();
}

class _BookSystemState extends State<BookSystem> {
  late Future<Map<String, dynamic>> _allDataFuture;
  late TextEditingController reasonController;
  late TextEditingController descController;
  String? selectedPetId;
  List<Pet> petsList = [];

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    reasonController = TextEditingController();
    descController = TextEditingController();
    _allDataFuture = _loadAllData();
  }

  @override
  void dispose() {
    reasonController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _loadAllData() async {
    try {
      final userData = await _fetchUserData();
      final pets = await _fetchPetsData();
      petsList = pets;
      return {
        'userData': userData,
        'pets': pets,
      };
    } catch (e) {
      return {'error': 'Failed to load data'};
    }
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get();

    if (!doc.exists) return {'error': 'User data not found'};
    return doc.data()!;
  }

  Future<List<Pet>> _fetchPetsData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('pets')
        .where('ownerId', isEqualTo: widget.user.uid)
        .get();

    return querySnapshot.docs.map((doc) {
      return Pet.fromDocumentSnapshot(doc);
    }).toList();
  }

  Future<void> _pickDate() async {
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

  Future<void> _pickTime() async {
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

  bool _isFormValid() {
    return reasonController.text.isNotEmpty &&
        selectedPetId != null &&
        selectedDate != null &&
        selectedTime != null &&
        selectedTime!.hour >= 9 &&
        selectedTime!.hour < 21;
  }

  Future<void> _submitBooking() async {
    if (!_isFormValid()) {
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

      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': widget.user.uid,
        'petId': selectedPetId,
        'reason': reasonController.text.trim(),
        'desc': descController.text.trim(),
        'dateTime': Timestamp.fromDate(fullDateTime),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking submitted!'),
          backgroundColor: Colors.green,
        ),
      );
        setState(() {
        reasonController.clear();
        descController.clear();
        selectedDate = null;
        selectedTime = null;
        selectedPetId = null;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit booking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveNoti() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final docRef =
      FirebaseFirestore.instance.collection('notifications').doc();

      await docRef.set({
        'title': 'Booking System',
        'content': 'Book Success in ${DateFormat.yMMMMd().add_jm().format(selectedDate!)}',
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      BookSystem(user: widget.user);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE1E1),
      appBar: ProjectAppBar(title: 'Book System'),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _allDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Splash(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.containsKey('error')) {
            return Center(
              child: Text('Failed to load data.'),
            );
          }

          final pets = snapshot.data!['pets'] as List<Pet>;

          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Book An Appointment',
                      style: TextStyle(
                        // color: Colors.pink,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDec.style,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TxtField(
                          controller: reasonController,
                          tag: 'Reason',
                        ),
                        SizedBox(height: 16),
                        TxtField(
                          controller: descController,
                          tag: 'Description (optional)',
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedPetId,
                          items: pets.map((pet) {
                            return DropdownMenuItem(
                              value: pet.pid,
                              child: Text(pet.petName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPetId = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Pet Name',
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
                        InkWell(
                          onTap: _pickDate,
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
                          onTap: _pickTime,
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
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                    onPressed: (){
                      _submitBooking();
                      _saveNoti();
                      FirebaseMessagingService.instance.showNotification(
                        'Booking System - Simpa',
                        'Book Success in ${DateFormat.yMMMMd().add_jm().format(selectedDate!)}',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              Welcome(user: widget.user),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF4F81),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
