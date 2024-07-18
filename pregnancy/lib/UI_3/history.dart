import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatelessWidget {
  final String userId;

  const HistoryPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical/ Allergy History'),
        backgroundColor: const Color(0xFFFFEDED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Handle notification icon tap
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFFFEDED),
        child: Column(
          children: [
            Expanded(
              child: _buildSection(context, 'Medical', 'history_medical'),
            ),
            const Divider(height: 1, color: Colors.black),
            Expanded(
              child: _buildSection(context, 'Allergy', 'history_allergy'),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewEntry(BuildContext context, String collection) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New ${collection == 'history_medical' ? 'Medical' : 'Allergy'}'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter ${collection == 'history_medical' ? 'Medical Condition' : 'Allergy'}'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('user_accounts')
                    .doc(userId)
                    .collection(collection)
                    .add({
                  collection == 'history_medical' ? 'medical' : 'allergy': controller.text
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(userId)
          .collection(collection)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var documents = snapshot.data!.docs;
        return Container(
          color: const Color(0xFFFFEDED),
          child: Column(
            children: [
              Container(
                color: const Color(0xFFFFEDED),
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _addNewEntry(context, collection);
                    },
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.black),
              Expanded(
                child: ListView.separated(
                  itemCount: documents.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black),
                  itemBuilder: (context, index) {
                    String value = documents[index][collection == 'history_medical' ? 'medical' : 'allergy'];
                    return Container(
                      color: Colors.white,
                      child: ListTile(
                        title: Text(value),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('user_accounts')
                                .doc(userId)
                                .collection(collection)
                                .doc(documents[index].id)
                                .delete();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
