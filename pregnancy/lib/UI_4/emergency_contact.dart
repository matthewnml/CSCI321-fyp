import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyContactPage extends StatefulWidget {
  const EmergencyContactPage({super.key});

  @override
  _EmergencyContactPageState createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends State<EmergencyContactPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContact();
  }

  void _loadEmergencyContact() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('user_accounts').doc(user.uid).get();
        if (userDoc.exists && userDoc['emergency_contact'] != null) {
          Map<String, dynamic> emergencyContact = userDoc['emergency_contact'];
          _nameController.text = emergencyContact['name'] ?? '';
          _phoneController.text = emergencyContact['phone'] ?? '';
          _relationController.text = emergencyContact['relation'] ?? '';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _saveEmergencyContact() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('user_accounts').doc(user.uid).update({
          'emergency_contact': {
            'name': _nameController.text,
            'phone': _phoneController.text,
            'relation': _relationController.text,
          },
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emergency contact saved successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Contact"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _relationController,
              decoration: const InputDecoration(
                labelText: 'Relation',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEmergencyContact,
              child: const Text('Save Contact'),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFfdebeb),
    );
  }
}
