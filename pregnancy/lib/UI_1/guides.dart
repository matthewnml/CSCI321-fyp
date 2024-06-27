

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GuidePage extends StatelessWidget {
  final String title;
  final String url;

  const GuidePage({required this.title, required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _launchURL(url);
          },
          child: const Text('Open Guide'),
        ),
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