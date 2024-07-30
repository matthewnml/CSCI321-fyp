import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GuidesPage extends StatelessWidget {
  const GuidesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guides'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('guides').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final guides = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: guides.length,
            itemBuilder: (context, index) {
              final guide = guides[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text(
                    guide['title'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GuideDetailPage(guide: guide),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class GuideDetailPage extends StatelessWidget {
  final QueryDocumentSnapshot guide;

  const GuideDetailPage({Key? key, required this.guide}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the 'url' field and treat it as a Map
    final Map<String, dynamic> urls = Map<String, dynamic>.from(guide['url']);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(guide['title']),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: urls.length,
        itemBuilder: (context, index) {
          // Convert the map to a list of entries
          final entries = urls.entries.toList();
          final urlInfo = entries[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text(
                urlInfo.key, // assuming the key is the title of the URL
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.open_in_browser),
              onTap: () {
                _launchURL(urlInfo.value); // assuming the value is the URL string
              },
            ),
          );
        },
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
