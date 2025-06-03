import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  final String sendTo;
  const NewMessage({super.key,required this.sendTo});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    super.dispose();

    _messageController.dispose();
  }

  _sendMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) return;

    FocusScope.of(context).unfocus();
    _messageController.clear();

    final User user = FirebaseAuth.instance.currentUser!;

    final userData= await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    await FirebaseFirestore.instance.collection('chats').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId':user.uid,
      'firstName':userData.data()!['firstName'],
      'lastName':userData.data()!['lastName'],
      'sendTo':widget.sendTo,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(15, 10, 1, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                      labelText: 'Ask Simpa`s Vets ....',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25))),
                  autocorrect: true,
                  enableSuggestions: true,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              IconButton(
                onPressed: _sendMessage,
                icon: Icon(
                  Icons.send,
                  color: Color(0xFFFF4F81),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
