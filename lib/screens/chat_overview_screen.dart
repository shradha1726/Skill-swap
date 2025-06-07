import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class ChatOverviewScreen extends StatefulWidget {
  const ChatOverviewScreen({super.key});

  @override
  State<ChatOverviewScreen> createState() => _ChatOverviewScreenState();
}

class _ChatOverviewScreenState extends State<ChatOverviewScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<QuerySnapshot> getRecentChatsStream() {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser!.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  Future<List<QueryDocumentSnapshot>> fetchMatchedUsers() async {
    final matchedSnapshot = await _firestore
        .collection('matches')
        .where('userIds', arrayContains: currentUser!.uid)
        .get();

    final matchedUserIds = matchedSnapshot.docs
        .map((doc) => (doc.data() as Map)['userIds'] as List<dynamic>)
        .expand((ids) => ids)
        .where((id) => id != currentUser!.uid)
        .toSet()
        .toList();

    if (matchedUserIds.isEmpty) return [];

    final usersSnapshot = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: matchedUserIds)
        .get();

    return usersSnapshot.docs;
  }

  void openChat(String chatUserId, String chatUserName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatUserId: chatUserId,
          chatUserName: chatUserName,
        ),
      ),
    );
  }

  Widget _buildChatListItem(DocumentSnapshot chatDoc) {
    final data = chatDoc.data() as Map<String, dynamic>;
    final participants = List<String>.from(data['participants']);
    final otherUserId = participants.firstWhere((id) => id != currentUser!.uid);
    final lastMessage = data['lastMessage'] ?? '';
    final lastMessageTime = (data['lastMessageTime'] as Timestamp?)?.toDate();

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(otherUserId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const ListTile(title: Text('Loading...'));
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final userName = userData['displayName'] ?? 'User';

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: userData['photoUrl'] != null
                ? NetworkImage(userData['photoUrl'])
                : null,
            child:
                userData['photoUrl'] == null ? const Icon(Icons.person) : null,
          ),
          title: Text(userName),
          subtitle: Text(lastMessage),
          trailing: lastMessageTime != null
              ? Text(
                  TimeOfDay.fromDateTime(lastMessageTime).format(context),
                  style: const TextStyle(fontSize: 12),
                )
              : null,
          onTap: () => openChat(otherUserId, userName),
        );
      },
    );
  }

  Widget _buildMatchedUserItem(DocumentSnapshot userDoc) {
    final data = userDoc.data() as Map<String, dynamic>;
    final userName = data['displayName'] ?? 'User';

    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            data['photoUrl'] != null ? NetworkImage(data['photoUrl']) : null,
        child: data['photoUrl'] == null ? const Icon(Icons.person) : null,
      ),
      title: Text(userName),
      subtitle: const Text('Matched user'),
      onTap: () => openChat(userDoc.id, userName),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text('Please log in'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: getRecentChatsStream(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final chats = chatSnapshot.data?.docs ?? [];

        if (chats.isNotEmpty) {
          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) => _buildChatListItem(chats[index]),
          );
        } else {
          return FutureBuilder<List<QueryDocumentSnapshot>>(
            future: fetchMatchedUsers(),
            builder: (context, matchedSnapshot) {
              if (matchedSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final matchedUsers = matchedSnapshot.data ?? [];
              if (matchedUsers.isEmpty) {
                return const Center(child: Text('No chats or matches found'));
              }
              return ListView.separated(
                itemCount: matchedUsers.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) =>
                    _buildMatchedUserItem(matchedUsers[index]),
              );
            },
          );
        }
      },
    );
  }
}
