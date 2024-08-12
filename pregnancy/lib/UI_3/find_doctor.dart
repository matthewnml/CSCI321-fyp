import 'package:flutter/material.dart';
import 'utilities/doctor.dart';
import 'doctor_profile.dart';

class FindADoctor extends StatefulWidget {
  const FindADoctor({Key? key}) : super(key: key);

  @override
  FindADoctorState createState() => FindADoctorState();
}

class FindADoctorState extends State<FindADoctor> {
  late ScrollController _scrollController;
  late List<Map<String, String>> _doctorProfiles;
  bool _isLoading = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _doctorProfiles = [];
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchMoreData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchMoreData() async {
  if (_isLoading) return;
  setState(() => _isLoading = true);

  String url = 'https://www.kkh.com.sg/patient-care/find-a-doctor?SpID=598f1b27-454a-4b9e-bea2-806c243a98bd&InstID=607a2275-3dee-4aff-8eeb-ff49077be347&PageNo=$_currentPage#abdomen';
  print('Fetching data from: $url');

  DoctorProfileService service = DoctorProfileService(url);
  String htmlContent = await service.fetchDoctorProfiles(url, _currentPage); // Fetch HTML content
  List<Map<String, String>> newProfiles = service.parseDoctorProfiles(htmlContent); // Parse HTML content into profiles

  _doctorProfiles.addAll(newProfiles);

  setState(() {
    _isLoading = false;
    _currentPage++;
  });
}



  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _fetchMoreData();
    }
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
            child: ListView.builder(
  controller: _scrollController,
  itemCount: _doctorProfiles.length + (_isLoading ? 1 : 0),
  itemBuilder: (context, index) {
    if (index >= _doctorProfiles.length) {
      return const Center(child: CircularProgressIndicator());
    }
    var profile = _doctorProfiles[index];
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
            // Using Navigator to push to DoctorProfile
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorProfile(
          url: profile['profileUrl'] ?? '',  // Provide default empty string if null
          name: profile['name'] ?? '',  // Provide default empty string if null
          specialty: profile['specialty'] ?? '',  // Provide default empty string if null
          location: profile['location'] ?? '',  // Provide default empty string if null
        ),
      ),
    );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text('View Profiles'),
        ),
      ),
    );
  },
),

          ),
        ],
      ),
      backgroundColor: const Color(0xFFfdebeb),
    );
  }
}
