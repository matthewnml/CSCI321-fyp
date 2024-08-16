import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching URLs
import 'utilities/doctor.dart'; // Assuming this is where your DoctorProfileService is defined

class FindADoctor extends StatefulWidget {
  const FindADoctor({super.key});

  @override
  FindADoctorState createState() => FindADoctorState();
}

class FindADoctorState extends State<FindADoctor> {
  late ScrollController _scrollController;
  late List<Map<String, String>> _doctorProfiles;
  late List<Map<String, String>> _filteredDoctorProfiles; // For storing filtered profiles
  bool _isLoading = false;
  int _currentPage = 0;
  String _searchQuery = ''; // Store search query

  @override
  void initState() {
    super.initState();
    _doctorProfiles = [];
    _filteredDoctorProfiles = [];
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchMoreData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Fetch and filter data based on search query
  void _fetchMoreData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    String url = 'https://www.kkh.com.sg/patient-care/find-a-doctor?SpID=598f1b27-454a-4b9e-bea2-806c243a98bd&InstID=607a2275-3dee-4aff-8eeb-ff49077be347&PageNo=$_currentPage#abdomen';
    //print('Fetching data from: $url');

    DoctorProfileService service = DoctorProfileService(url);
    String htmlContent = await service.fetchDoctorProfiles(url, _currentPage);
    List<Map<String, String>> newProfiles = service.parseDoctorProfiles(htmlContent);

    setState(() {
      _doctorProfiles.addAll(newProfiles);

      // Filter the new data based on the current search query
      _filteredDoctorProfiles = _doctorProfiles.where((profile) {
        return profile['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               profile['specialty']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               profile['location']!.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      _isLoading = false;
      _currentPage++;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _fetchMoreData();
    }
  }

  // Handle search input changes
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;

      // Filter all loaded profiles based on the search query
      _filteredDoctorProfiles = _doctorProfiles.where((profile) {
        return profile['name']!.toLowerCase().contains(query.toLowerCase()) ||
               profile['specialty']!.toLowerCase().contains(query.toLowerCase()) ||
               profile['location']!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _launchURL(String url) async {
    // Ensure the URL is fully qualified
    final String fullUrl = url.startsWith('http') ? url : 'https://www.kkh.com.sg$url';

    //print('Attempting to launch URL: $fullUrl');  // Debugging line

    try {
      final Uri uri = Uri.parse(fullUrl); // Convert the String URL to a Uri object
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $fullUrl';
      }
    } catch (e) {
      print('Error launching URL: $e');
      // Optionally, show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the link. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find A Doctor'),
        backgroundColor: Colors.pink.shade50,
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
              onChanged: _onSearchChanged, // Handle search input changes
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
              itemCount: _filteredDoctorProfiles.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _filteredDoctorProfiles.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                var profile = _filteredDoctorProfiles[index];
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
                        String profileUrl = profile['profileUrl'] ?? '';
                        if (profileUrl.isNotEmpty) {
                          _launchURL(profileUrl);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text('View Profile'),
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
