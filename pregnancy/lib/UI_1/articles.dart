import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  String? _expandedArticleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('articles').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final articles = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              final articleId = article.id;
              final Map<String, dynamic> urls = Map<String, dynamic>.from(article['url']);
              final entries = urls.entries.toList();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ExpansionTile(
                  key: PageStorageKey(articleId),
                  title: Text(
                    article['title'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onExpansionChanged: (isExpanded) {
                    setState(() {
                      _expandedArticleId = isExpanded ? articleId : null;
                    });
                  },
                  initiallyExpanded: _expandedArticleId == articleId,
                  children: _expandedArticleId == articleId
                      ? entries.map((urlInfo) {
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
                        }).toList()
                      : [],
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
