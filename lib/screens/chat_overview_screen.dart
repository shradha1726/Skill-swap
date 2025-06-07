import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatOverviewScreen extends StatefulWidget {
  final String chatUserId; // The UID of the user you are chatting with
  final String chatUserName;

  const ChatOverviewScreen(
      {super.key, required this.chatUserId, required this.chatUserName});

  @override
  State<ChatOverviewScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatOverviewScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  User? get currentUser => _auth.currentUser;

  String get chatId {
    final ids = [currentUser!.uid, widget.chatUserId];
    ids.sort();
    return ids.join('_');
  }

  Future<void> _sendMessage({String? text, String? imageUrl}) async {
    if ((text == null || text.trim().isEmpty) && (imageUrl == null)) return;

    final message = {
      'idFrom': currentUser!.uid,
      'idTo': widget.chatUserId,
      'timestamp': FieldValue.serverTimestamp(),
      'content': text ?? '',
      'imageUrl': imageUrl ?? '',
      'type': imageUrl != null ? 'image' : 'text',
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);

    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickAndSendImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final fileName =
        '${currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('chat_images').child(fileName);

    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    final imageUrl = await snapshot.ref.getDownloadURL();

    await _sendMessage(imageUrl: imageUrl);
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final isMe = data['idFrom'] == currentUser!.uid;

    if (data['type'] == 'image') {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Image.network(
          data['imageUrl'],
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.deepPurple : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          data['content'],
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatUserName),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return _buildMessageItem(docs[index]);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo),
                  color: Colors.deepPurple,
                  onPressed: _pickAndSendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Type a message'),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.deepPurple,
                  onPressed: () =>
                      _sendMessage(text: _messageController.text.trim()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
