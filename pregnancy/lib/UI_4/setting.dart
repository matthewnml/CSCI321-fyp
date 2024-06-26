import 'package:flutter/material.dart';
import '/UI_4/account.dart';
import 'emergency_contact.dart'; // Import the EmergencyContactPage
import '/UI_main/password_reset.dart'; // Import the PasswordResetPage

class SettingsScreen extends StatelessWidget {
  final String userId;

  const SettingsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[50],
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountPage(userId: userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Emergency Contact'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyContactPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Contact Us'),
            onTap: () {
              // Handle tap
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms & Conditions'),
            onTap: () {
              Navigator.pushNamed(context, '/terms_conditions');
            },
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text('Reset Password'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PasswordResetPage(),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.brown[100], // Button text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Log out'),
            ),
          ),
        ],
      ),
    );
  }
}
