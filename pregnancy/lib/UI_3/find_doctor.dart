import 'package:flutter/material.dart';
import 'utilities/doctor.dart';

class FindADoctor extends StatefulWidget {
  const FindADoctor({Key? key}) : super(key: key);

  @override
  FindADoctorState createState() => FindADoctorState();
}

class FindADoctorState extends State<FindADoctor> {
  late Future<List<Map<String, String>>> _doctorProfiles;

  @override
  void initState() {
    super.initState();
    DoctorProfileService service = DoctorProfileService(
        'https://www.kkh.com.sg/patient-care/find-a-doctor?k=*#abdomen');
    _doctorProfiles = service.getAllDoctorProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find A Doctor'),
        backgroundColor: Colors.pink.shade100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search doctor's name, specialty...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
              future: _doctorProfiles,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No profiles found.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var profile = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            child: const Icon(Icons.person),
                          ),
                          title: Text(profile['name'] ?? 'No name'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile['specialty'] ?? 'No specialty'),
                              Text(profile['location'] ?? 'No location'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Navigate to detailed profile or perform an action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: const Text('View Profile'),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFfdebeb),
    );
  }
}
