import 'package:flutter/material.dart';
import 'package:pregnancy/UI_3/view_details.dart'; // Import the view_details.dart file

class MyAppointment extends StatelessWidget {
  const MyAppointment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointment'),
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
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAppointmentCard(context, 'Dr. John Doe', '2024-06-10', '10:00 AM'),
          const SizedBox(height: 16),
          _buildAppointmentCard(context, 'Dr. Jane Smith', '2024-06-12', '02:00 PM'),
        ],
      ),
      backgroundColor: const Color(0xFFfdebeb),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, String doctorName, String date, String time) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text('Doctor Name: $doctorName'),
        subtitle: Text('Date: $date\nTime: $time'),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyAppointmentDetailsScreen(
                  doctorName: doctorName,
                  date: date,
                  time: time,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE0C9C9), // Use backgroundColor instead of primary
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'View Details',
            style: TextStyle(color: Colors.black), // Set text color to black
          ),
        ),
      ),
    );
  }
}
