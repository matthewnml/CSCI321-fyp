import 'package:flutter/material.dart';

class BabyDevelopmentPage extends StatelessWidget {
  final String userId;

  const BabyDevelopmentPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Development'),
        backgroundColor: const Color(0xFFFFF4F4),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track Your Baby\'s Growth',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildDevelopmentTile(
                      'assets/month1.png', 'Month 1', 'Description of milestones for month 1...'),
                  _buildDevelopmentTile(
                      'assets/month2.png', 'Month 2', 'Description of milestones for month 2...'),
                  _buildDevelopmentTile(
                      'assets/month3.png', 'Month 3', 'Description of milestones for month 3...'),
                  // Add more months as needed
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add milestone button press
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }

  Widget _buildDevelopmentTile(String imagePath, String title, String description) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          width: 50,
          height: 50,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.black),
          onPressed: () {
            // Handle edit button press
          },
        ),
      ),
    );
  }
}
