import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'health_widget/audio_player_widget.dart';
import 'health_widget/video_player_widget.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({required this.chatId, Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage({String? text, String? mediaUrl, String? mediaType}) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    final message = {
      'senderId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'text': text,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
    };

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add(message);

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({
      'lastMessage': text ?? mediaType,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    _controller.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickMedia(String mediaType) async {
    final picker = ImagePicker();
    XFile? pickedFile;

    if (mediaType == 'image') {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    } else if (mediaType == 'video') {
      pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    }

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_media')
          .child('${widget.chatId}_${DateTime.now().millisecondsSinceEpoch}');

      final uploadTask = storageRef.putFile(file);

      final snapshot = await uploadTask;
      final mediaUrl = await snapshot.ref.getDownloadURL();

      _sendMessage(mediaUrl: mediaUrl, mediaType: mediaType);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
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
                      title: message['mediaUrl'] != null
                          ? (message['mediaType'] == 'image'
                              ? Image.network(message['mediaUrl'])
                              : message['mediaType'] == 'video'
                                  ? VideoPlayerWidget(url: message['mediaUrl'])
                                  : AudioPlayerWidget(url: message['mediaUrl']))
                          : Text(message['text'] ?? ''),
                      subtitle: Text(message['senderId']),
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
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: () => _pickMedia('image'),
                ),
                IconButton(
                  icon: const Icon(Icons.videocam),
                  onPressed: () => _pickMedia('video'),
                ),
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () => _pickMedia('audio'),
                ),
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
