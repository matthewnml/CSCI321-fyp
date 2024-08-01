import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pregnancy Guides',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GuidesPage(),
    );
  }
}

class GuidesPage extends StatelessWidget {
  const GuidesPage({super.key});

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
              final Map<String, dynamic> urls = Map<String, dynamic>.from(guide['url']);
              final entries = urls.entries.toList();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ExpansionTile(
                  title: Text(
                    guide['title'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  children: entries.map((urlInfo) {
                    return ListTile(
                      title: Text(
                        urlInfo.key,
                        style: const TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                        urlInfo.value,
                        style: const TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                      trailing: const Icon(Icons.open_in_browser),
                      onTap: () {
                        _launchURL(urlInfo.value);
                      },
                    );
                  }).toList(),
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
