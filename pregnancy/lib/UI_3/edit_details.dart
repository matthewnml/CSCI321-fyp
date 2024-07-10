import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAppointmentDetailsScreen extends StatefulWidget {
  final String userId;
  final String appointmentId;

  const EditAppointmentDetailsScreen({
    super.key,
    required this.userId,
    required this.appointmentId,
  });

  @override
  _EditAppointmentDetailsScreenState createState() => _EditAppointmentDetailsScreenState();
}

class _EditAppointmentDetailsScreenState extends State<EditAppointmentDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _doctorNameController;
  late TextEditingController _locationController;
  late TextEditingController _dateController;
  String _selectedTime = '10:00 AM';
  bool _alertMe = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointmentDetails();
  }

  Future<void> _fetchAppointmentDetails() async {
    DocumentSnapshot appointmentDoc = await FirebaseFirestore.instance
        .collection('user_accounts')
        .doc(widget.userId)
        .collection('appt_info')
        .doc(widget.appointmentId)
        .get();

    Map<String, dynamic> appointment = appointmentDoc.data() as Map<String, dynamic>;

    setState(() {
      _doctorNameController = TextEditingController(text: appointment['Doctor Name']);
      _locationController = TextEditingController(text: appointment['Location']);
      _dateController = TextEditingController(text: appointment['Date']);
      _selectedTime = appointment['Time'];
      _alertMe = appointment['Alert Me'];
      _isLoading = false;
    });
  }

  Future<void> _updateAppointmentDetails() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(widget.userId)
          .collection('appt_info')
          .doc(widget.appointmentId)
          .update({
        'Doctor Name': _doctorNameController.text,
        'Location': _locationController.text,
        'Date': _dateController.text,
        'Time': _selectedTime,
        'Alert Me': _alertMe,
      });
      Navigator.pop(context, true); // Return true to indicate data was updated
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
        title: const Text('Edit Appointment'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                              await _updateAppointmentDetails();
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
