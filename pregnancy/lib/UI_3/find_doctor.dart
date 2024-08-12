import 'package:flutter/material.dart';
import 'utilities/doctor.dart';

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

    DoctorProfileService service = DoctorProfileService(
        'https://www.kkh.com.sg/patient-care/find-a-doctor?k=*&PageNo=$_currentPage#abdomen');
    var newProfiles = await service.getAllDoctorProfiles();
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
                      onPressed: () {},
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
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFfdebeb),
    );
  }
}
