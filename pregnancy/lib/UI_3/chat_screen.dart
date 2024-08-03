import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userName; // This will be the name of the currently logged-in user or specialist
  final bool isSpecialist;

  const ChatScreen({
    required this.chatId,
    required this.userName,
    required this.isSpecialist,
    Key? key,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print("ChatScreen initialized");  // Debug statement
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("App state changed to: $state");  // Debug statement
    if (state == AppLifecycleState.resumed) {
      print("Requesting focus on resume");  // Debug statement
      // Optionally, you might want to delay the focus request slightly
      Future.delayed(Duration(milliseconds: 500), () {
        _focusNode.requestFocus();
      });
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }

  Widget _buildMessage(String text, bool isSentByUser) {
    // This regular expression matches URLs
    final urlRegExp = RegExp(r'(https?:\/\/[^\s]+)');
    final matches = urlRegExp.allMatches(text);

    if (matches.isNotEmpty) {
      final String url = matches.first.group(0)!;
      return InkWell(
        onTap: () => _launchURL(url),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    } else {
      return Text(text);
    }
  }

  Future<void> _sendMessage({required String text}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final senderName = widget.userName;

    final message = {
      'senderId': userId,
      'senderName': senderName,
      'timestamp': FieldValue.serverTimestamp(),
      'text': text,
    };

    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').add(message);

    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print("Back button pressed");  // Debug statement
        return true;
      },
      child: Scaffold(
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
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').orderBy('timestamp', descending: false).snapshots(),
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
                                child: _buildMessage(message['text'] ?? '', isSentByUser),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
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
            ),
          ],
        ),
        backgroundColor: const Color(0xFFfdebeb),
      ),
    );
  }
}
