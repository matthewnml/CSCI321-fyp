import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _selectedTime = '10:00 AM';
  bool _alertMe = false;

  Future<void> _addAppointmentDetails() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('user_accounts')
            .doc(user.uid)
            .collection('appt_info')
            .add({
          'Doctor Name': _doctorNameController.text,
          'Location': _locationController.text,
          'Date': _dateController.text,
          'Time': _selectedTime,
          'Alert Me': _alertMe,
        });

        Navigator.pop(context, true); // Return true to indicate data was added
      }
    }
  }

  @override
  void dispose() {
    _doctorNameController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Appointment'),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Appointment Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Card(
                  color: Colors.pink[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _doctorNameController,
                          decoration: const InputDecoration(
                            labelText: 'Doctor',
                            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            fillColor: Color(0xFFE0C9C9),
                            filled: true,
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontSize: 14),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the doctor\'s name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            fillColor: Color(0xFFE0C9C9),
                            filled: true,
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontSize: 14),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            labelText: 'Appointment Date',
                            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            fillColor: Color(0xFFE0C9C9),
                            filled: true,
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontSize: 14),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the appointment date';
                            }
                            // Add more validation for date format if needed
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedTime,
                          decoration: const InputDecoration(
                            labelText: 'Appointment Time',
                            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            fillColor: Color(0xFFE0C9C9),
                            filled: true,
                            border: OutlineInputBorder(),
                          ),
                          items: <String>[
                            '10:00 AM',
                            '11:00 AM',
                            '12:00 PM',
                            '01:00 PM',
                            '02:00 PM',
                            '03:00 PM',
                            '04:00 PM',
                            '05:00 PM',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedTime = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select the appointment time';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Alert Me:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Radio(
                              value: true,
                              groupValue: _alertMe,
                              onChanged: (bool? value) {
                                setState(() {
                                  _alertMe = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              'Yes',
                              style: TextStyle(fontSize: 14),
                            ),
                            Radio(
                              value: false,
                              groupValue: _alertMe,
                              onChanged: (bool? value) {
                                setState(() {
                                  _alertMe = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              'No',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _addAppointmentDetails();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB9CAD7), // Updated color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.black), // Updated text color
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB9CAD7), // Updated color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black), // Updated text color
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFfdebeb),
    );
  }
}
