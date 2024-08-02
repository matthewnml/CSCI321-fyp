import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FemaleHealthArticlesPage extends StatelessWidget {
  const FemaleHealthArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Female Health Articles'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('articles').doc('W9AddyOOZiPZEebJ8B3I').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final guide = snapshot.data!;
          final Map<String, dynamic> urls = Map<String, dynamic>.from(guide['url']);
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
