import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:simpa/screens/messages_widgets/chat_messages.dart';
import 'package:simpa/screens/messages_widgets/new_message.dart';
import 'package:simpa/screens/project_app_bar.dart';

class ChattingScreen extends StatefulWidget {
  final auth.User user;
  final String vet;
  const ChattingScreen({
    super.key,
    required this.user,
    required this.vet,
  });

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE1E1),
      appBar: ProjectAppBar(title: 'Chat With a Vit'),
      body: Column(
        children: [
          Expanded(child: ChatMessages(sendTo: widget.vet,),),
          NewMessage(sendTo:widget.vet),
        ],
      ),
    );
  }
}
