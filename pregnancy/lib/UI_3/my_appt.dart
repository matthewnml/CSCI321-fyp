import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'view_details.dart'; // Import the view_details.dart file
import 'add_appt.dart'; // Import the add_appt.dart file
import 'package:pregnancy/UI_4/notification_page.dart';

class MyAppointment extends StatefulWidget {
  const MyAppointment({super.key});

  @override
  _MyAppointmentState createState() => _MyAppointmentState();
}

class _MyAppointmentState extends State<MyAppointment> {
  late Future<List<QueryDocumentSnapshot>> _appointmentsFuture;

  Future<List<QueryDocumentSnapshot>> _fetchAppointments() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(user.uid)
          .collection('appt_info')
          .get();
      return appointmentsSnapshot.docs;
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _fetchAppointments();
  }

  void _refreshAppointments() {
    setState(() {
      _appointmentsFuture = _fetchAppointments();
    });
  }

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
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching appointments.'));
          }

          var appointments = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: appointments.map((appointment) {
              var data = appointment.data() as Map<String, dynamic>;
              return _buildAppointmentCard(
                context,
                data['Doctor Name'] ?? '',
                data['Date'] ?? '',
                data['Time'] ?? '',
                appointment.id,
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAppointmentScreen(),
            ),
          );
          if (result == true) {
            _refreshAppointments();
          }
        },
        backgroundColor: const Color(0xFFB9CAD7),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      backgroundColor: const Color(0xFFfdebeb),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, String doctorName, String date, String time, String appointmentId) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text('Doctor: Dr. $doctorName'),
        subtitle: Text('Date: $date\nTime: $time'),
        trailing: ElevatedButton(
          onPressed: () async {
            bool? result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyAppointmentDetailsScreen(
                  userId: FirebaseAuth.instance.currentUser!.uid,
                  appointmentId: appointmentId,
                ),
              ),
            );
            if (result == true) {
              _refreshAppointments();
            }
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
