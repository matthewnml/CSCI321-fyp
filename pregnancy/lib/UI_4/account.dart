import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ensure you have firebase_auth added in your pubspec.yaml

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isEditing = false;
  final TextEditingController _nameController =
      TextEditingController(text: "Amy Young");
  final TextEditingController _phoneController =
      TextEditingController(text: "+98 1245560090");
  final TextEditingController _emailController =
      TextEditingController(text: "amyoung@random.com");
  final TextEditingController _dueDateController =
      TextEditingController(text: "2023-12-25");
  final TextEditingController _countryController =
      TextEditingController(text: "Singapore");
  final TextEditingController _dateOfBirthController =
      TextEditingController(text: "1998-06-10");
  final TextEditingController _heightController =
      TextEditingController(text: "164");
  final TextEditingController _weightController =
      TextEditingController(text: "52");

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateUserProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        await _firestore.collection('users').doc(userId).set({
          'fullName': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'dueDate': _dueDateController.text,
          'country': _countryController.text,
          'dateOfBirth': _dateOfBirthController.text,
          'height': _heightController.text,
          'weight': _weightController.text,
        }, SetOptions(merge: true));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateUserProfile();
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_picture.jpg'),
            ),
            const SizedBox(height: 16),
            buildTextField("Name", _nameController),
            buildTextField("Phone no.", _phoneController),
            buildTextField("E-Mail", _emailController),
            buildTextField("Due Date", _dueDateController),
            buildTextField("Country", _countryController),
            buildTextField("Date of Birth", _dateOfBirthController),
            buildTextField("Height", _heightController),
            buildTextField("Weight", _weightController),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _isEditing
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    controller.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
