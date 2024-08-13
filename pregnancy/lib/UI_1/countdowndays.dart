import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CountdownDays extends StatefulWidget {
  final String userId;

  const CountdownDays({super.key, required this.userId});

  @override
  _CountdownDaysState createState() => _CountdownDaysState();
}

class _CountdownDaysState extends State<CountdownDays> {
  int _remainingDays = 50; // Default value
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchDueDateFromFirebase();
  }

  Future<void> _fetchDueDateFromFirebase() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('user_accounts').doc(user.uid).get();
        if (userDoc.exists && userDoc['estimated_due_date'] != null) {
          Timestamp dueDateTimestamp = userDoc['estimated_due_date'];
          DateTime dueDate = dueDateTimestamp.toDate();
          final now = DateTime.now();
          final difference = dueDate.difference(now).inDays;
          setState(() {
            _remainingDays = difference;
          });
        }
      }
    } catch (error) {
      print('Error fetching due date: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: FractionallySizedBox(
        widthFactor: 0.6, // Increased to make the box wider
        child: Container(
          padding: const EdgeInsets.all(16.0), // Increased padding for more space inside the box
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Countdown Days:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Image.asset(
                    _getBabyImage(_remainingDays),
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$_remainingDays days until your due date!',
                      style: const TextStyle(
                        fontSize: 16, // Increased font size for better readability
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center, // Center the text if needed
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getBabyImage(int remainingDays) {
    if (remainingDays > 270) return 'assets/month1.png';
    if (remainingDays > 240) return 'assets/month2.png';
    if (remainingDays > 210) return 'assets/month3.png';
    if (remainingDays > 180) return 'assets/month4.png';
    if (remainingDays > 150) return 'assets/month5.png';
    if (remainingDays > 120) return 'assets/month6.png';
    if (remainingDays > 90) return 'assets/month7.png';
    if (remainingDays > 60) return 'assets/month8.png';
    if (remainingDays > 30) return 'assets/month9.png';
    return 'assets/month10.png';
  }
}
