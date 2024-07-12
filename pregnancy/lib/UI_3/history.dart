import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatelessWidget {
  final String userId;

  HistoryPage({required this.userId});

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
        bottom: PreferredSize(
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
            Divider(height: 1, color: Colors.black),
            Expanded(
              child: _buildSection(context, 'Allergy', 'history_allergy'),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewEntry(BuildContext context, String collection) {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New ${collection == 'history_medical' ? 'Medical' : 'Allergy'}'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Enter ${collection == 'history_medical' ? 'Medical Condition' : 'Allergy'}'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('user_accounts')
                    .doc(userId)
                    .collection(collection)
                    .add({
                  collection == 'history_medical' ? 'medical' : 'allergy': _controller.text
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
          return Center(child: CircularProgressIndicator());
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      _addNewEntry(context, collection);
                    },
                  ),
                ),
              ),
              Divider(height: 1, color: Colors.black),
              Expanded(
                child: ListView.separated(
                  itemCount: documents.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.black),
                  itemBuilder: (context, index) {
                    String value = documents[index][collection == 'history_medical' ? 'medical' : 'allergy'];
                    return Container(
                      color: Colors.white,
                      child: ListTile(
                        title: Text(value),
                        trailing: IconButton(
                          icon: Icon(Icons.close, color: Colors.black),
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
