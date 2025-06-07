import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatUserId;
  final String chatUserName;

  const ChatScreen({
    super.key,
    required this.chatUserId,
    required this.chatUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    // Your chat UI here, you can access widget.chatUserId and widget.chatUserName
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatUserName),
      ),
      body: Center(
        child:
            Text('Chat with ${widget.chatUserName} (ID: ${widget.chatUserId})'),
      ),
    );
  }
}
