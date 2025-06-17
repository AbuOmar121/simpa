import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simpa/firebase/models/notification_model.dart';
import 'package:simpa/screens/user_access/stylesAndDec/dec.dart';
import 'package:simpa/splash.dart';

class GetNotification extends StatefulWidget {
  final auth.User user;
  const GetNotification({super.key, required this.user});
  @override
  State<GetNotification> createState() => _GetNotificationState();
}

class _GetNotificationState extends State<GetNotification> {
  late Future<List<Notifications>> _notificationFuture;
  List<Notifications> notifications = [];

  @override
  void initState() {
    super.initState();
    _notificationFuture = _fetchNotificationData();
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
    return Container(
      decoration: BoxDec.style,
      child: FutureBuilder(
        future: _notificationFuture,
        builder: (context, AsyncSnapshot<List<Notifications>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Splash(),
              ),
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Failed to load Notification',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(31, 31, 31, 1),
                  ),
                ),
              ),
            );
          }
          final notif = snapshot.data!;
          if (notif.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No notifications available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(31, 31, 31, 1),
                  ),
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: Colors.pink,
            onRefresh: () async {
              setState(
                () {
                  _notificationFuture = _fetchNotificationData();
                },
              );
            },
            child: SingleChildScrollView(
              child: Column(
                children: notif.map((notif) {
                  return Container(
                    decoration: BoxDec.style,
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          DateFormat.yMMMMd().add_jm().format(notif.timestamp!),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notif.nTitle,
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(31, 31, 31, 1),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        notif.nContent,
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
                            ],
                          ),
                        ),
                        Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: Color(0xFFFA9DBC),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
