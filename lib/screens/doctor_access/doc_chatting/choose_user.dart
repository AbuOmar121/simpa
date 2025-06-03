import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:simpa/screens/admin_access/admin_app_bar.dart';
import 'package:simpa/screens/user_access/user_messaging/chatting_screen.dart';

class ChooseUser extends StatefulWidget {
  final auth.User user;
  const ChooseUser({super.key, required this.user});

  @override
  State<ChooseUser> createState() => _ChooseUserState();
}

class _ChooseUserState extends State<ChooseUser> {
  final currentUser = auth.FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> filteredUsers = [];
  TextEditingController searchController = TextEditingController();

  Future<void> fetchSenders() async {
    if (currentUser == null) return;

    final chatSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('sendTo', isEqualTo: currentUser!.uid)
        .get();

    final senderIds = chatSnapshot.docs
        .map((doc) => doc['userId'] as String)
        .toSet()
        .toList();

    List<Map<String, dynamic>> senders = [];
    for (final id in senderIds) {
      final userSnap =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (userSnap.exists) {
        senders.add({'id': id, ...userSnap.data()!});
      }
    }

    setState(() {
      allUsers = senders;
      filteredUsers = senders;
    });
  }

  void filterUsers(String query) {
    final filtered = allUsers.where((user) {
      final fullName = '${user['firstName']} ${user['lastName']}'.toLowerCase();
      return fullName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredUsers = filtered;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchSenders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB9DEDE),
      appBar: AdminAppBar(title: 'Direct Messages'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: TextField(
              controller: searchController,
              onChanged: filterUsers,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text('No users have messaged you.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title:
                              Text('${user['firstName']} ${user['lastName']}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChattingScreen(
                                  user: widget.user,
                                  vet: user['id'],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
