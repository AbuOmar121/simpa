import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simpa/firebase/models/notification_model.dart';
import 'package:simpa/screens/project_app_bar.dart';
import 'package:simpa/screens/user_access/notification/get_notification.dart';

class NotificationsScreen extends StatefulWidget {
  final User user;
  const NotificationsScreen({super.key, required this.user});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Notifications>> notificationFuture;
  List<Notifications> notifications = [];

  @override
  void initState() {
    super.initState();
    notificationFuture = _fetchNotificationData();
  }

  Future<List<Notifications>> _fetchNotificationData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: widget.user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      notifications = querySnapshot.docs.map((doc) {
        return Notifications.fromDocumentSnapshot(doc);
      }).toList();
      return notifications;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE1E1),
      appBar: ProjectAppBar(title: 'Notifications'),
      body: Container(
        padding: EdgeInsets.all(16),
        child: RefreshIndicator(
          color: Colors.pink,
          onRefresh: () async {
            setState(
              () {
                notificationFuture = _fetchNotificationData();
              },
            );
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 32, 0, 32),
                  child: Text(
                    'Notification System',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GetNotification(user: widget.user),
                SizedBox(
                  height: 64,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
