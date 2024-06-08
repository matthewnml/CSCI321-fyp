import 'package:flutter/material.dart';
import 'package:pregnancy/UI_3/doctor_profile.dart'; // Import the doctor_profile.dart file

class BookWithDoctorScreen extends StatelessWidget {
  const BookWithDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> doctors = [
      'Doctor 1',
      'Doctor 2',
      'Doctor 3',
      'Doctor 4',
      'Doctor 5',
      'Doctor 6',
      'Doctor 7',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book with Doctor'),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search doctor's name, specialty ....",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(doctor),
                  subtitle: const Text('Name: \nSpecialty: \nLocation: '),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DoctorProfileScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0C9C9), // Updated color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View Profile',
                      style: TextStyle(color: Colors.black), // Updated text color
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFfdebeb),
    );
  }
}
