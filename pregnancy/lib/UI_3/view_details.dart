import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_details.dart'; // Import the edit_details.dart file

class MyAppointmentDetailsScreen extends StatefulWidget {
  final String userId;
  final String appointmentId;

  const MyAppointmentDetailsScreen({
    super.key,
    required this.userId,
    required this.appointmentId,
  });

  @override
  _MyAppointmentDetailsScreenState createState() => _MyAppointmentDetailsScreenState();
}

class _MyAppointmentDetailsScreenState extends State<MyAppointmentDetailsScreen> {
  late Future<Map<String, dynamic>> _appointmentDetailsFuture;

  Future<Map<String, dynamic>> _fetchAppointmentDetails() async {
    DocumentSnapshot appointmentDoc = await FirebaseFirestore.instance
        .collection('user_accounts')
        .doc(widget.userId)
        .collection('appt_info')
        .doc(widget.appointmentId)
        .get();

    return appointmentDoc.data() as Map<String, dynamic>;
  }

  @override
  void initState() {
    super.initState();
    _appointmentDetailsFuture = _fetchAppointmentDetails();
  }

  void _refreshAppointmentDetails() {
    setState(() {
      _appointmentDetailsFuture = _fetchAppointmentDetails();
    });
  }

  Future<void> _deleteAppointment() async {
    await FirebaseFirestore.instance
        .collection('user_accounts')
        .doc(widget.userId)
        .collection('appt_info')
        .doc(widget.appointmentId)
        .delete();

    Navigator.pop(context, true); // Return true to indicate deletion
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Appointment'),
          content: const Text('Are you sure you want to delete this appointment?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss the dialog
                await _deleteAppointment(); // Delete the appointment
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointment'),
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _appointmentDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching appointment details.'));
          }

          var appointment = snapshot.data!;
          String doctorName = appointment['Doctor Name'];
          String location = appointment['Location'];
          String date = appointment['Date'];
          String time = appointment['Time'];
          bool alertMe = appointment['Alert Me'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appointment Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  color: Colors.pink[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Doctor: Dr. $doctorName (Gynaecologist)',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Location:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          location,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Appointment Date: $date',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Appointment Time: $time',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Alert Me: ${alertMe ? 'Yes' : 'No'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          bool? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditAppointmentDetailsScreen(
                                userId: widget.userId,
                                appointmentId: widget.appointmentId,
                              ),
                            ),
                          );
                          if (result == true) {
                            _refreshAppointmentDetails();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB9CAD7), // Updated color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(color: Colors.black), // Updated text color
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showDeleteConfirmationDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB9CAD7), // Updated color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.black), // Updated text color
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: const Color(0xFFfdebeb),
    );
  }
}
