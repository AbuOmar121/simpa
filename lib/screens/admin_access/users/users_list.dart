import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simpa/screens/admin_access/admin_app_bar.dart';
import 'package:simpa/screens/admin_access/users/add_user_popup.dart';
import 'package:simpa/screens/user_access/stylesAndDec/dec.dart';
import 'package:simpa/splash.dart';

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  String _searchQuery = '';

  void _deleteUser(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user')),
      );
    }
  }

  Future<void> _updateRole(String uid, String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'role': newRole,
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role updated to $newRole')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update role')),
      );
    }
  }

  int _rolePriority(String role) {
    switch (role) {
      case 'admin':
        return 0;
      case 'vet':
        return 1;
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB9DEDE),
      appBar: AdminAppBar(title: 'Users List'),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name or email',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.trim().toLowerCase());
                },
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDec.style,
                child: Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: Splash(),);
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text('Something went wrong'));
                          }

                          final users = snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.toLowerCase();
                            final email = (data['email'] ?? '').toLowerCase();
                            return name.contains(_searchQuery) || email.contains(_searchQuery);
                          }).toList();
                          users.sort((a, b) {
                            final roleA = (a['role'] ?? 'user') as String;
                            final roleB = (b['role'] ?? 'user') as String;
                            return _rolePriority(roleA).compareTo(_rolePriority(roleB));
                          });

                          if (users.isEmpty) {
                            return Center(child: Text('No users found.'));
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final doc = users[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final userId = doc.id;
                              final currentRole = data['role'] ?? 'user';

                              return Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(16,0,0,0),
                                    child: ListTile(
                                      title: Text('${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(data['email'] ?? 'No email'),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text('Role: '),
                                              SizedBox(width: 8,),
                                              DropdownButton<String>(
                                                value: currentRole,
                                                items: ['admin', 'vet', 'user'].map((role) {
                                                  return DropdownMenuItem<String>(
                                                    value: role,
                                                    child: Text(role),
                                                  );
                                                }).toList(),
                                                onChanged: (newValue) {
                                                  if (newValue != null && newValue != currentRole) {
                                                    _updateRole(userId, newValue);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () {
                                              showAddUserDialog(
                                                context,
                                                userId: userId,
                                                initialFirstName: data['firstName'],
                                                initialLastName: data['lastName'],
                                                initialEmail: data['email'],
                                                initialRole: currentRole,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteUser(userId),
                                          ),
                                        ],
                                      ),

                                    ),
                                  ),
                                  Divider(color: Colors.cyan),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
