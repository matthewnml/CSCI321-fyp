import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pregnancy/UI_4/notification_page.dart';

class MedicationTrackerPage extends StatefulWidget {
  final String userId;

  const MedicationTrackerPage({super.key, required this.userId});

  @override
  _MedicationTrackerPageState createState() => _MedicationTrackerPageState();
}

class _MedicationTrackerPageState extends State<MedicationTrackerPage> {
  void _addOrEditMedication({String? docId, String? initialName, String? initialTime}) {
    TextEditingController medicationController = TextEditingController(text: initialName);
    String selectedTime = initialTime ?? 'Off';

    List<String> times = [
      'Off',
      ...List.generate(24, (index) {
        DateTime time = DateTime(2024, 1, 1, index);
        return DateFormat('hh:mm a').format(time);
      })
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? 'Add New Medication' : 'Edit Medication'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: medicationController,
                decoration: const InputDecoration(hintText: 'Enter Medication/Supplement Name'),
                autofocus: true,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Reminder:'),
                  DropdownButton<String>(
                    value: selectedTime,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTime = newValue!;
                      });
                    },
                    items: times.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(docId == null ? 'Add' : 'Update'),
              onPressed: () {
                if (medicationController.text.trim().isNotEmpty) {
                  if (docId == null) {
                    FirebaseFirestore.instance
                        .collection('user_accounts')
                        .doc(widget.userId)
                        .collection('medication')
                        .add({
                      'name': medicationController.text.trim(),
                      'time': selectedTime != 'Off' ? selectedTime : null
                    });
                  } else {
                    FirebaseFirestore.instance
                        .collection('user_accounts')
                        .doc(widget.userId)
                        .collection('medication')
                        .doc(docId)
                        .update({
                      'name': medicationController.text.trim(),
                      'time': selectedTime != 'Off' ? selectedTime : null
                    });
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Medication name is required.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteMedication(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this medication?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('user_accounts')
                    .doc(widget.userId)
                    .collection('medication')
                    .doc(docId)
                    .delete();
                Navigator.of(context).pop();
              },
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
        title: const Text('Medication Tracker'),
        backgroundColor: const Color(0xFFFFEDED),
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
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFFFEDED),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('user_accounts')
              .doc(widget.userId)
              .collection('medication')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            var documents = snapshot.data!.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                var doc = documents[index];
                return ListTile(
                  title: Text(doc['name']),
                  subtitle: Text(doc['time'] ?? 'No reminder set'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _addOrEditMedication(
                            docId: doc.id,
                            initialName: doc['name'],
                            initialTime: doc['time']
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMedication(doc.id),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditMedication(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
