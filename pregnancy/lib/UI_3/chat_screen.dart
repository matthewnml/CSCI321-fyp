import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pregnancy/UI_4/notifications.dart'; // Import the notification service
import 'view_specialist_profile.dart';
import 'package:flutter/gestures.dart';

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
  late NotificationService _notificationService;
  bool _isChatCompleted = false; // State to track if chat is completed
  String? specialistId; // Variable to store the specialist's ID

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationService = NotificationService();
    _notificationService.init();
    fetchChatDetails();
  }

  void fetchChatDetails() async {
    DocumentSnapshot chatSnapshot = await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).get();
    if (chatSnapshot.exists) {
      var data = chatSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _isChatCompleted = data['status'] == 'completed';
        specialistId = data['specialistId']; // Store the specialistId from Firestore
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
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
    final urlRegExp = RegExp(r'(https?:\/\/[^\s]+)');
    List<InlineSpan> spans = [];

    text.splitMapJoin(
      urlRegExp,
      onMatch: (Match match) {
        spans.add(TextSpan(
          text: match.group(0),
          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () => _launchURL(match.group(0)!),
        ));
        return '';
      },
      onNonMatch: (String text) {
        spans.add(TextSpan(
          text: text,
          style: const TextStyle(color: Colors.black),
        ));
        return '';
      },
    );

    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(fontSize: 16),  // Default text style
      ),
    );
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

    // Fetch chat document to determine the receiver's user ID
    final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).get();
    final chatData = chatDoc.data();
    if (chatData != null) {
      final receiverId = chatData['createdBy'] == userId ? chatData['specialistId'] : chatData['createdBy'];
      if (receiverId != userId) {
        // Save notification if the receiver is not the sender
        _notificationService.saveNotificationToDatabase(
          'New message from $senderName',
          text,
          receiverId,
        );
      }
    }
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
      await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
        'status': 'completed',
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
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
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'profile':
                    if (specialistId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewSpecialistProfile(specialistId: specialistId!),
                        ),
                      );
                    } else {
                      print("Specialist ID is not available.");
                    }
                    break;
                  case 'terminate':
                    await _terminateChat();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Text('View Specialist’s Profile'),
                ),
                const PopupMenuItem<String>(
                  value: 'terminate',
                  child: const Text(
                    'Terminate Chat',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
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
            if (!_isChatCompleted) // Conditionally render the input area
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
