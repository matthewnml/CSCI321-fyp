import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SpecialistProfileScreen extends StatefulWidget {
  const SpecialistProfileScreen({super.key});

  @override
  _SpecialistProfileScreenState createState() => _SpecialistProfileScreenState();
}

class _SpecialistProfileScreenState extends State<SpecialistProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _degreeController = TextEditingController();
  TextEditingController _institutionController = TextEditingController();
  TextEditingController _specialtyController = TextEditingController();
  TextEditingController _clinicalInterestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSpecialistDetails();
  }

  void _loadSpecialistDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Load name from user_accounts collection
        DocumentSnapshot userDoc = await _firestore.collection('user_accounts').doc(user.uid).get();
        if (userDoc.exists) {
          _nameController.text = userDoc['full_name'] ?? '';
        }

        // Load other details from user_accounts/profile sub-collection
        DocumentSnapshot profileDoc = await _firestore.collection('user_accounts').doc(user.uid).collection('profile').doc('details').get();
        if (profileDoc.exists) {
          setState(() {
            _nameController.text = profileDoc['name'] ?? _nameController.text;
            _degreeController.text = profileDoc['degree'] ?? '';
            _institutionController.text = profileDoc['institution'] ?? '';
            _specialtyController.text = profileDoc['specialty'] ?? '';
            _clinicalInterestController.text = profileDoc['clinicalInterest'] ?? '';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _saveSpecialistDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('user_accounts').doc(user.uid).collection('profile').doc('details').set({
          'name': _nameController.text,
          'degree': _degreeController.text,
          'institution': _institutionController.text,
          'specialty': _specialtyController.text,
          'clinicalInterest': _clinicalInterestController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        
        // Return to the previous screen
        Navigator.pop(context);
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
        title: const Text('Specialist Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: _degreeController,
                decoration: const InputDecoration(labelText: 'Degree'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your degree';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _institutionController,
                decoration: const InputDecoration(labelText: 'Current Employment Institution'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your institution';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(labelText: 'Specialty/Department'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your specialty';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _clinicalInterestController,
                decoration: const InputDecoration(labelText: 'Clinical Interest'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your clinical interest';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveSpecialistDetails();
                  }
                },
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
