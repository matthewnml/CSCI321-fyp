import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LowHeartRateNotificationPage extends StatefulWidget {
  final String userId;

  const LowHeartRateNotificationPage({super.key, required this.userId});

  @override
  _LowHeartRateNotificationPageState createState() => _LowHeartRateNotificationPageState();
}

class _LowHeartRateNotificationPageState extends State<LowHeartRateNotificationPage> {
  int _selectedBpm = 40; // Default value

  @override
  void initState() {
    super.initState();
    _loadCurrentThreshold();
  }

  Future<void> _loadCurrentThreshold() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(user.uid)
          .collection('heart_rate_notifications')
          .doc('low')
          .get();

      if (doc.exists) {
        setState(() {
          _selectedBpm = doc['threshold'] ?? 50;
        });
      }
    }
  }

  Future<void> _saveThreshold() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(user.uid)
          .collection('heart_rate_notifications')
          .doc('low')
          .set({'threshold': _selectedBpm});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Low Heart Rate Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Threshold',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildBpmOption(40),
            _buildBpmOption(45),
            _buildBpmOption(50),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveThreshold();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBpmOption(int bpm) {
    return ListTile(
      title: Text('$bpm BPM'),
      leading: Radio<int>(
        value: bpm,
        groupValue: _selectedBpm,
        onChanged: (int? value) {
          setState(() {
            _selectedBpm = value!;
          });
        },
      ),
    );
  }
}
