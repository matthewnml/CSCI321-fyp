import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'history.dart';
import 'heart_rate_tracker.dart'; 
import 'medication_tracker.dart'; 
import 'package:pregnancy/UI_4/notification_page.dart';

class HealthJournal extends StatelessWidget {
  const HealthJournal({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Journal'),
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
                    // Navigate to the notification page
                    builder: (context) => const NotificationPage(), 
                  ),
                );
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFEDED),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Colors.black),
                title: const Text('Heart Rate Tracker'),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => HeartRateTracker()
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.medical_services, color: Colors.black),
                title: const Text('Medical/ Allergy History'),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryPage(userId: currentUser.uid),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.healing, color: Colors.black),
                title: const Text('Medication Tracker'),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicationTrackerPage(userId: currentUser.uid),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
