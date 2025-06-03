import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:simpa/screens/messages_widgets/new_message.dart';
import 'package:simpa/screens/project_app_bar.dart';

import 'doctor_chat_massages.dart';

class DoctorChattingScreen extends StatefulWidget {
  final auth.User user;
  final String vet;
  const DoctorChattingScreen({
    super.key,
    required this.user,
    required this.vet,
  });

  @override
  State<DoctorChattingScreen> createState() => _DoctorChattingScreenState();
}

class _DoctorChattingScreenState extends State<DoctorChattingScreen> {
  final authUser = auth.FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE1E1),
      appBar: ProjectAppBar(title: 'Ask A Vit'),
      body: Column(
        children: [
          Expanded(
            child: DoctorChatMessages(
              sendTo: authUser.uid,
            ),
          ),
          NewMessage(sendTo: widget.vet),
        ],
      ),
    );
  }
}
