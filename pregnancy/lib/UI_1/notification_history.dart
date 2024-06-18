import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF4F4),
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // You can handle the icon press here if needed
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.black),
                title: const Text('You have an upcoming appointment.'),
                subtitle: const Text(
                  'Click for details',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap: () {
                  // Handle the click event for the appointment notification
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.message, color: Colors.black),
                title: const Text('A specialist has replied to your question!'),
                subtitle: const Text(
                  'Click for details',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap: () {
                  // Handle the click event for the specialist reply notification
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
