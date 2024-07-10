import 'package:flutter/material.dart';

class HealthJournal extends StatelessWidget {
  const HealthJournal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Journal'),
        backgroundColor: Colors.transparent,
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
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.favorite, color: Colors.black),
            title: const Text('Heart Rate Tracker'),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
            onTap: () {
              // Handle Heart Rate Tracker tap
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.medical_services, color: Colors.black),
            title: const Text('Medical/ Allergy History'),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
            onTap: () {
              // Handle Medical/ Allergy History tap
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFfdebeb),
    );
  }
}
