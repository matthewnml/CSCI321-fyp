import 'package:flutter/material.dart';
import 'user_management.dart'; // Import the user management file
import 'article_management.dart'; // Import the article management file
import 'guide_management.dart'; // Import the guide management file
import '/UI_main/login.dart'; // Import the login file

class AdminDashboard extends StatelessWidget {
  final String userId;

  const AdminDashboard({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Container(
        color: const Color(0xFFFFEBEE), // Pink background color
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserManagement()),
                );
              },
              child: const Text('View Users'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArticleManagement()),
                );
              },
              child: const Text('Manage Articles'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GuideManagement()),
                );
              },
              child: const Text('Manage Guides'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: const Text('Log out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 160, 76, 88), // Background color
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(vertical: 15.0), // Adjust padding
                textStyle: const TextStyle(fontSize: 16), // Text style
              ),
            ),
          ],
        ),
      ),
    );
  }
}
