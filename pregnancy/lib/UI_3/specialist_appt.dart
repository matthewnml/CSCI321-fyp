import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';

class ChatWithSpecialistScreen extends StatelessWidget {
  const ChatWithSpecialistScreen({super.key});

  Future<void> _createNewChat(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
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
        builder: (context) => ChatScreen(chatId: newChat.id, userName: userName, isSpecialist: false),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Center(child: Text('No user logged in'));

    final userId = user.uid;

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
              : _buildSpecialistChatList(context, userId, userName),
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
          //.orderBy('lastUpdated', descending: true)  
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('An error occurred'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final waitingForReplyChats = snapshot.data!.docs.where((doc) => doc['status'] == 'new').toList();
        final ongoingChats = snapshot.data!.docs.where((doc) => doc['status'] == 'ongoing').toList();
        final completedChats = snapshot.data!.docs.where((doc) => doc['status'] == 'completed').toList();

        return Column(
          children: [
            _buildChatSection(
              context,
              'Waiting for Reply',
              waitingForReplyChats,
              userName,
              false,
              userId,
            ),
            _buildChatSection(
              context,
              'Ongoing Chats',
              ongoingChats,
              userName,
              false,
              userId,
            ),
            _buildChatSection(
              context,
              'Completed Chats',
              completedChats,
              userName,
              false,
              userId,
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

  Widget _buildChatSection(BuildContext context, String title, List<DocumentSnapshot> chats, String userName, bool isSpecialist, String userId) {
      return Expanded(
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  Map<String, dynamic>? chatData = chat.data() as Map<String, dynamic>?;

                  // Determine display name based on the role (specialist or user)
                  String displayName = isSpecialist
                    ? (chatData?.containsKey('createdByName') ?? false ? chatData!['createdByName'] as String : 'No name available')
                    : (chatData?.containsKey('specialistName') ?? false ? chatData!['specialistName'] as String : 'No specialist assigned');

                  return ListTile(
                    title: Text(displayName),
                    subtitle: Text(
                      chatData != null && chatData.containsKey('lastMessage')
                      ? chatData['lastMessage'] as String 
                      : 'No message'
                    ),
                    trailing: Text(
                      chatData != null && chatData.containsKey('lastUpdated') && chat['lastUpdated'] != null
                      ? _formatTimestamp(chat['lastUpdated'] as Timestamp)
                      : 'No date'
                    ),
                    onTap: () {
                      if (!isSpecialist && (chatData?['specialistId'] == null || chatData?['status'] == 'new')) {
                        // User action (if needed)
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: chat.id,
                            userName: userName,
                            isSpecialist: isSpecialist,
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
      );
  }


  Widget _buildSpecialistChatList(BuildContext context, String userId, String userName) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .orderBy('lastUpdated', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('An error occurred'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final newChats = snapshot.data!.docs.where((doc) => doc['specialistId'] == null && doc['status'] == 'new').toList();
        final ongoingChats = snapshot.data!.docs.where((doc) => doc['specialistId'] == userId && doc['status'] == 'ongoing').toList();
        final completedChats = snapshot.data!.docs.where((doc) => doc['specialistId'] == userId && doc['status'] == 'completed').toList();

        return Column(
          children: [
            _buildChatSection(
              context,
              'New Chats',
              newChats,
              userName,
              true,
              userId,
            ),
            _buildChatSection(
              context,
              'Ongoing Chats',
              ongoingChats,
              userName,
              true,
              userId,
            ),
            _buildChatSection(
              context,
              'Completed Chats',
              completedChats,
              userName,
              true,
              userId,
            ),
          ],
        );
      },
    );
  }
}
