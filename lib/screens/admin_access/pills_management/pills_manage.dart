import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpa/firebase/models/pill_model.dart';
import 'package:simpa/screens/admin_access/add_pill_popup.dart';
import 'package:simpa/screens/admin_access/admin_app_bar.dart';
import 'package:simpa/screens/user_access/stylesAndDec/dec.dart';
import 'package:simpa/splash.dart';

class PillsManage extends StatefulWidget {
  const PillsManage({super.key});

  @override
  State<PillsManage> createState() => _PillsManageState();
}

class _PillsManageState extends State<PillsManage> {
  final pillsCollection = FirebaseFirestore.instance.collection('pills');
  String _searchQuery = '';

  void _deletePill(String id) async {
    await pillsCollection.doc(id).delete();
  }

  void _editPill(Pill pill) {
    showAddPillDialog(
      context,
      pillsCollection,
      existingPill: pill,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB9DEDE),
      appBar: AdminAppBar(title: 'Manage Pills'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddPillDialog(context, pillsCollection),
        child: Icon(
          Icons.add,
          color: Color(0xFF0D16B2),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: pillsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading pills'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Splash());
          }

          final allPills = snapshot.data!.docs
              .map((doc) => Pill.fromDocumentSnapshot(doc))
              .toList();

          final filteredPills = allPills.where((pill) {
            return pill.name.toLowerCase().contains(_searchQuery);
          }).toList();

          return ListView(
            padding: EdgeInsets.only(bottom: 80),
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name',
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
              ),
              if (filteredPills.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No pills found.'),
                  ),
                )
              else
                ...filteredPills.map(
                  (pill) => Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Container(
                      decoration: BoxDec.style,
                      child: Column(
                        children: [
                          SizedBox(height: 8),
                          ListTile(
                            title: Text(pill.name),
                            subtitle: Text(
                              'Type: ${pill.type} • Dosage: ${pill.dosage}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => _editPill(pill),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deletePill(pill.piId),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
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

