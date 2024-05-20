import 'package:flutter/material.dart';
import 'package:pregnancy/UI_3/health.dart'; // Import the health.dart file

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.pink[50],
        elevation: 0,
      ),
      body: const Center(
        child: Text('Welcome to the Pregnancy App!'),
      ),
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
        currentIndex: 0, // Set the current index to 'Home'
        onTap: (int index) {
          // Handle tab navigation
          if (index == 2) { // 'Health' tab has index 2
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HealthScreen()), // Navigate to HealthScreen
            );
          }
        },
      ),
    );
  }
}
