import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pregnancy/UI_3/chat_w_specialist.dart';
import 'package:pregnancy/UI_3/specialist_profile.dart'; // Import the specialist_profile.dart file
import 'package:pregnancy/UI_4/notification_page.dart';

class HealthSpecialistScreen extends StatefulWidget {
  const HealthSpecialistScreen({super.key});

  @override
  _HealthSpecialistScreenState createState() => _HealthSpecialistScreenState();
}

class _HealthSpecialistScreenState extends State<HealthSpecialistScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _fullName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  void _loadUserDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('user_accounts').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _fullName = userDoc['full_name'] ?? "User";
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(), // Navigate to the notification page
                  ),
               );  
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatWithSpecialistScreen(),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(
                          Icons.chat,
                          size: 40,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Chat with Specialist',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.black,
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Hello, $_fullName',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SpecialistProfileScreen(),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'My Profile',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFfdebeb),
    );
  }
}
