import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ParentingArticlesPage extends StatelessWidget {
  const ParentingArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parenting Articles'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('articles').doc('O7uSI08a7PPy7ChCy4A3').snapshots(),
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