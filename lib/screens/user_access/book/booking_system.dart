import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:simpa/screens/user_access/Book/book_system.dart';
import 'package:simpa/screens/user_access/welcomeScreen/get_book.dart';
import 'package:simpa/screens/user_access/welcomeScreen/get_done.dart';

class BookingSystem extends StatefulWidget {
  final auth.User user;
  const BookingSystem({super.key, required this.user});

  @override
  State<BookingSystem> createState() => _BookingSystemState();
}

class _BookingSystemState extends State<BookingSystem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE1E1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Add padding for bottom button
        child: Column(
          children: [
            const SizedBox(height: 8),
            _sectionTitle('Upcoming Appointment'),
            const SizedBox(height: 12),
            GetBook(user: widget.user),
            const SizedBox(height: 32),
            _sectionTitle('Done Appointments'),
            const SizedBox(height: 12),
            GetDone(user: widget.user),
            const SizedBox(height: 64),
          ],
        ),
      ),

      // Add Appointment button at the bottom
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFFFFE1E1),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      BookSystem(user: widget.user),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF4F81),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:Text(
              'Add Appointment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F1F1F),
          ),
        ),
      ),
    );
  }
}
