import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewSpecialistProfile extends StatefulWidget {
  final String specialistId;

  const ViewSpecialistProfile({Key? key, required this.specialistId}) : super(key: key);

  @override
  _ViewSpecialistProfileState createState() => _ViewSpecialistProfileState();
}

class _ViewSpecialistProfileState extends State<ViewSpecialistProfile> {
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    super.initState();
    print("Initiating profile fetch for ID: ${widget.specialistId}");
    fetchProfile();
  }

  void fetchProfile() async {
    print("Fetching data from Firestore...");
    try {
      DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(widget.specialistId)
          .collection('profile')
          .doc('details')
          .get();

      if (profileSnapshot.exists) {
        print("Data found: ${profileSnapshot.data()}");
        setState(() {
          profileData = profileSnapshot.data() as Map<String, dynamic>?;
        });
      } else {
        print("No data found for ID: ${widget.specialistId}");
      }
    } catch (e) {
      print("Failed to fetch profile data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Specialist Profile'),
        backgroundColor: Colors.pink[50],
      ),
      body: profileData == null
        ? const Center(child: CircularProgressIndicator())
        : profileData!.isEmpty
          ? const Center(child: Text("No data available. Please check the ID or network connection."))
          : buildProfileListView(),
    );
  }

  ListView buildProfileListView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        buildProfileField('Full Name', profileData?['name']),
        buildProfileField('Degree', profileData?['degree']),
        buildProfileField('Specialty', profileData?['specialty']),
        buildProfileField('Institution', profileData?['institution']),
        buildProfileField('Clinical Interest', profileData?['clinicalInterest']),
      ],
    );
  }

  Widget buildProfileField(String label, String? value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value ?? 'N/A'),
    );
  }
}
