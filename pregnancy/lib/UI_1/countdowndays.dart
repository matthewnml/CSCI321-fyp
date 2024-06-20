import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CountdownDays extends StatefulWidget {
  const CountdownDays({super.key});

  @override
  _CountdownDaysState createState() => _CountdownDaysState();
}

class _CountdownDaysState extends State<CountdownDays> {
  int _remainingDays = 242; // Initialize _remainingDays to a default value

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchDueDateFromFirebase();
  }

  Future<void> _fetchDueDateFromFirebase() async {
    try {
      DocumentSnapshot dueDateSnapshot =
          await _firestore.collection('due_dates').doc('due_date').get();
      Timestamp dueDateTimestamp = dueDateSnapshot['due_date'];
      DateTime dueDate = dueDateTimestamp.toDate();
      final now = DateTime.now();
      final difference = dueDate.difference(now).inDays;
      setState(() {
        _remainingDays = difference;
      });
    } catch (error) {
      print('Error fetching due date: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3C3C3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Countdown:',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Text(
            '$_remainingDays days',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
