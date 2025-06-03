import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:simpa/screens/project_app_bar.dart';
import 'package:simpa/screens/user_access/user_messaging/chatting_screen.dart';
import 'package:simpa/splash.dart';

class ChooseVet extends StatelessWidget {
  final auth.User user;
  const ChooseVet({super.key, required this.user});

  Future<List<Map<String, dynamic>>> fetchVetUsers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'vet')
        .get();

    return snapshot.docs
        .map((doc) => {
      'id': doc.id,
      ...doc.data(),
    })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xFFFFE1E1),
      appBar: ProjectAppBar(title: 'Ask A Vet'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchVetUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Splash());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No vets found.'));
          }

          final vetUsers = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: vetUsers.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Center(
                  child: Padding(
                    padding:EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Choose a Vet',
                      style:TextStyle(
                        fontSize: 21,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }

              final vet = vetUsers[index - 1];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading:CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    '${vet['firstName'] ?? ''} ${vet['lastName'] ?? ''}',
                    style:TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text('ID: $index'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChattingScreen(
                          user: user,
                          vet: vet['id'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}