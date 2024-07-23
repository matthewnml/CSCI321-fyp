import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final String userName; // This will be the name of the currently logged-in user or specialist
  final bool isSpecialist;

  const ChatScreen({required this.chatId, required this.userName, required this.isSpecialist, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    final ScrollController _scrollController = ScrollController();

    Future<void> _sendMessage({required String text}) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userId = user.uid;
      final senderName = userName;

      final message = {
        'senderId': userId,
        'senderName': senderName,
        'timestamp': FieldValue.serverTimestamp(),
        'text': text,
      };

      await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add(message);

      await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      _controller.clear();
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.pink[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];

                    return ListTile(
                      title: Text(message['text'] ?? ''),
                      subtitle: Text(message['senderName'] ?? 'Unknown'),
                      trailing: Text((message['timestamp'] != null) ? (message['timestamp'] as Timestamp).toDate().toString() : 'No date'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(text: _controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFfdebeb),
    );
  }
}
