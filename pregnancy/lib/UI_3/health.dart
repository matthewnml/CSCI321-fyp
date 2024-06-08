import 'package:flutter/material.dart';
import 'package:pregnancy/UI_3/specialist_appt.dart'; // Import the chat_with_specialist.dart file
import 'package:pregnancy/UI_3/doc_appt.dart'; // Import the doc_appt.dart file
import 'package:pregnancy/UI_3/my_appt.dart'; // Import the my_appt.dart file

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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookWithDoctorScreen(),
                      ),
                    );
                  },
                ),
                _buildIconButton(
                  context,
                  Icons.chat,
                  'Chat with Specialist',
                  Colors.blue.shade100,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatWithSpecialistScreen(),
                      ),
                    );
                  },
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyAppointment(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFfdebeb),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, String label, Color backgroundColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }
}
