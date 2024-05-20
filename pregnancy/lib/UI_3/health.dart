import 'package:flutter/material.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Handle notification icon tap
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
                _buildIconButton(
                  context,
                  Icons.person_add,
                  'Book with Doctor',
                  Colors.pink.shade100,
                ),
                _buildIconButton(
                  context,
                  Icons.chat,
                  'Chat with Specialist',
                  Colors.blue.shade100,
                ),
              ],
            ),
            const SizedBox(height: 40),
            Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hello, User',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildIconButton(
              context,
              Icons.event_available,
              'My Appointment',
              Colors.green.shade100,
            ),
          ],
        ),
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

  Widget _buildIconButton(BuildContext context, IconData icon, String label, Color backgroundColor) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: backgroundColor,
          child: Icon(
            icon,
            size: 40,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
