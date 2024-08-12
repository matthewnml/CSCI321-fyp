import 'package:flutter/material.dart';
import 'utilities/doctor_details_service.dart'; 

class DoctorProfile extends StatelessWidget {
  final String url;
  final String name;
  final String specialty;
  final String location;

  const DoctorProfile({
    Key? key,
    required this.url,
    required this.name,
    required this.specialty,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.pink.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(specialty, style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            Text(location, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<Map<String, String>>(
                future: DoctorDetailsService().fetchDoctorDetails(url),
                builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text("No data available", style: TextStyle(color: Colors.red));
                    }
                    return Column(
                      children: [
                        Text("Qualifications: ${snapshot.data?['Qualifications']}", style: TextStyle(fontSize: 16)),
                        Text("Designation: ${snapshot.data?['Designation']}", style: TextStyle(fontSize: 16)),
                      ],
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
