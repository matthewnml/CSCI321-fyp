import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoGuidesPage extends StatelessWidget {
  const VideoGuidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Guides'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('guides').doc('x9k42qkVyZs07tlGui59').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: const Text('Document does not exist'));
          }

          final guide = snapshot.data!;
          final data = guide.data() as Map<String, dynamic>;

          if (!data.containsKey('url')) {
            return Center(child: const Text('Field "url" does not exist in the document'));
          }

          final Map<String, dynamic> urls = Map<String, dynamic>.from(data['url']);

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: urls.length,
            itemBuilder: (context, index) {
              final entries = urls.entries.toList();
              final urlInfo = entries[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text(
                    urlInfo.key,
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.open_in_browser),
                  onTap: () {
                    _launchURL(urlInfo.value);
                  },
                ),
              );
            },
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
