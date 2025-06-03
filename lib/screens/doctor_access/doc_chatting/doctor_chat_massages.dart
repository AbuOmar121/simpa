import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simpa/screens/messages_widgets/message_bubble.dart';
import 'package:simpa/splash.dart';

class DoctorChatMessages extends StatefulWidget {
  final String sendTo;
  const DoctorChatMessages({super.key, required this.sendTo});

  @override
  State<DoctorChatMessages> createState() => _DoctorChatMessagesState();
}

class _DoctorChatMessagesState extends State<DoctorChatMessages> {
  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .orderBy('createdAt', descending: false)
          .where('sendTo', isEqualTo: authUser.uid)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Splash(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Some thing went wrong',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No messages',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          );
        }
        final loadedMessages = snapshot.data!.docs;

        return ListView.builder(
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index].data();
            final nextMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;

            final currentMessageUserId = chatMessage['userId'];

            final bool nextUserIsSame = nextMessage == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                isMe: authUser.uid == currentMessageUserId,
                message: chatMessage['text'],
              );
            } else {
              return MessageBubble.first(
                username:
                // ignore: prefer_interpolation_to_compose_strings
                '${chatMessage['firstName'] + " " + chatMessage['lastName']}',
                message: chatMessage['text'],
                isMe: authUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
