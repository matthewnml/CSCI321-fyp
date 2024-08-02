import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final String userName; // This will be the name of the currently logged-in user or specialist
  final bool isSpecialist;

  const ChatScreen({required this.chatId, required this.userName, required this.isSpecialist, Key? key}) : super(key: key);

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }

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

    Future<void> _terminateChat() async {
      final bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Terminate Chat'),
            content: const Text('Are you sure you want to terminate the chat?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          );
        },
      ) ?? false;

      if (confirm) {
        await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
          'status': 'completed',
        });
        Navigator.pop(context);
      }
    }

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
            icon: const Icon(Icons.attachment, color: Colors.black),
            onPressed: _terminateChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').orderBy('timestamp', descending: false).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final bool isSentByUser = message['senderId'] == FirebaseAuth.instance.currentUser?.uid;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Align(
                        alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['senderName'] ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              decoration: BoxDecoration(
                                color: isSentByUser ? Colors.green[100] : Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(12.0),
                              child: Text(message['text'] ?? ''),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (message['timestamp'] != null)
                                  ? _formatTimestamp(message['timestamp'] as Timestamp)
                                  : 'No date',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('chats').doc(chatId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.data() != null) {
                final chatData = snapshot.data!.data() as Map<String, dynamic>;
                if (chatData['status'] == 'completed') {
                  return SizedBox.shrink(); // No input area if chat is completed
                }
              }
              // Show input area if chat is not completed
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Enter your question here',
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
              );
            }
          ),
        ],
      ),
      backgroundColor: const Color(0xFFfdebeb),
    );
  }
}
