import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class ChatWithSpecialistScreen extends StatelessWidget {
  const ChatWithSpecialistScreen({Key? key}) : super(key: key);

  Future<void> _createNewChat(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('user_accounts').doc(userId).get();
    final userName = userDoc['full_name'];

    final newChat = await FirebaseFirestore.instance.collection('chats').add({
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': userId,
      'createdByName': userName,
      'lastMessage': '',
      'lastUpdated': FieldValue.serverTimestamp(),
      'specialistId': null,
      'status': 'new',
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatId: newChat.id, userName: userName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return const Center(child: Text('No user logged in'));

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('user_accounts').doc(userId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userRole = userSnapshot.data!['role'];
        final userName = userSnapshot.data!['full_name'];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chat with Specialist'),
            backgroundColor: Colors.pink[50],
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black),
                onPressed: () {
                  // Handle notification icon tap
                },
              ),
            ],
          ),
          body: userRole == 'User'
              ? _buildUserChatList(context, userId, userName)
              : _buildSpecialistChatList(context, userId),
          backgroundColor: const Color(0xFFfdebeb),
        );
      },
    );
  }

  Widget _buildUserChatList(BuildContext context, String userId, String userName) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('createdBy', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final chatPreviews = snapshot.data!.docs.map((doc) {
          return ChatPreview(
            chatId: doc.id,
            previewText: doc['lastMessage'] ?? 'No message',
            date: (doc['lastUpdated'] != null)
                ? (doc['lastUpdated'] as Timestamp).toDate().toString()
                : 'No date',
            specialistName: doc['specialistId'] == null ? 'No specialist' : 'Specialist',
          );
        }).toList();

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: chatPreviews.length,
                itemBuilder: (context, index) {
                  final chat = chatPreviews[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(chat.specialistName),
                        subtitle: Text(chat.previewText),
                        trailing: Text(chat.date),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(chatId: chat.chatId, userName: userName),
                            ),
                          );
                        },
                      ),
                      if (chat.specialistName == 'No specialist') const Text('Waiting for Reply'),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _createNewChat(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB9CAD7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Chat Now',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpecialistChatList(BuildContext context, String userId) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chats').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final newChats = snapshot.data!.docs.where((doc) => doc['specialistId'] == null).toList();
        final ongoingChats = snapshot.data!.docs.where((doc) => doc['specialistId'] == userId).toList();

        return Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text('New Chats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: newChats.length,
                      itemBuilder: (context, index) {
                        final chat = newChats[index];
                        return ListTile(
                          title: const Text('No specialist'),
                          subtitle: Text(chat['lastMessage'] ?? 'No message'),
                          trailing: Text((chat['lastUpdated'] as Timestamp).toDate().toString()),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  chatId: chat.id,
                                  userName: chat['createdByName'] ?? 'Unknown',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text('Ongoing Chats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ongoingChats.length,
                      itemBuilder: (context, index) {
                        final chat = ongoingChats[index];
                        return ListTile(
                          title: Text(chat['createdByName'] ?? 'Unknown'),
                          subtitle: Text(chat['lastMessage'] ?? 'No message'),
                          trailing: Text((chat['lastUpdated'] as Timestamp).toDate().toString()),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  chatId: chat.id,
                                  userName: chat['createdByName'] ?? 'Unknown',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ChatPreview {
  final String chatId;
  final String previewText;
  final String date;
  final String specialistName;

  ChatPreview({
    required this.chatId,
    required this.previewText,
    required this.date,
    required this.specialistName,
  });
}