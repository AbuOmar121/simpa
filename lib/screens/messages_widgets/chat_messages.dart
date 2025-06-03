import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simpa/screens/messages_widgets/message_bubble.dart';
import 'package:simpa/splash.dart';

class ChatMessages extends StatefulWidget {
  final String sendTo; // The person the current user is chatting with
  const ChatMessages({super.key, required this.sendTo});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser!;
    final currentUserId = authUser.uid;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Splash());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No messages',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        }

        final allMessages = snapshot.data!.docs;
        final filteredMessages = allMessages.where((doc) {
          final data = doc.data();
          final sender = data['userId'];
          final receiver = data['sendTo'];

          return (sender == currentUserId && receiver == widget.sendTo) ||
              (sender == widget.sendTo && receiver == currentUserId);
        }).toList();

        return ListView.builder(
          itemCount: filteredMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = filteredMessages[index].data();
            final nextMessage = index + 1 < filteredMessages.length
                ? filteredMessages[index + 1].data()
                : null;

            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId = nextMessage?['userId'];
            final bool nextUserIsSame = nextMessageUserId == currentMessageUserId;

            final username = (chatMessage.containsKey('firstName') && chatMessage.containsKey('lastName'))
                ? '${chatMessage['firstName']} ${chatMessage['lastName']}'
                : 'User';

            if (nextUserIsSame) {
              return MessageBubble.next(
                isMe: currentUserId == currentMessageUserId,
                message: chatMessage['text'],
              );
            } else {
              return MessageBubble.first(
                username: username,
                message: chatMessage['text'],
                isMe: currentUserId == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
