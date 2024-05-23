import 'package:flutter/material.dart';
import 'package:pregnancy/UI_3/consult_platform.dart'; // Import the consult_platform.dart file

class ChatWithSpecialistScreen extends StatelessWidget {
  const ChatWithSpecialistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ChatPreview> chatPreviews = [
      ChatPreview(
        specialistName: 'Specialist 1',
        previewText: 'Chat preview ..........................................................',
        date: '08/05/2024',
        isWaitingForReply: true,
      ),
      ChatPreview(
        specialistName: 'Specialist 2',
        previewText: 'Chat preview ..........................................................',
        date: '07/05/2024',
        isWaitingForReply: false,
      ),
    ];

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
      body: Column(
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
                            builder: (context) => const ChatScreen(),
                          ),
                        );
                      },
                    ),
                    if (chat.isWaitingForReply)
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text('Waiting for Reply'),
                      ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Chat Now',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFfdebeb),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 2, // Set the current index to 'Health'
        onTap: (int index) {
          // Handle tab navigation
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/calendar');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/health');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/settings');
          }
        },
      ),
    );
  }
}

class ChatPreview {
  final String specialistName;
  final String previewText;
  final String date;
  final bool isWaitingForReply;

  ChatPreview({
    required this.specialistName,
    required this.previewText,
    required this.date,
    required this.isWaitingForReply,
  });
}
