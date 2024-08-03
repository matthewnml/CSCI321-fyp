import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuideManagement extends StatefulWidget {
  const GuideManagement({super.key});

  @override
  _GuideManagementState createState() => _GuideManagementState();
}

class _GuideManagementState extends State<GuideManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _guideStream;

  @override
  void initState() {
    super.initState();
    _guideStream = _firestore.collection('guides').snapshots(); // Collection for guides
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Guides'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'All Guides',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateGuideScreen()),
                );
              },
              child: const Text('Create New Guide'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _guideStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No guides found.'));
                  }
                  final guides = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: guides.length,
                    itemBuilder: (context, index) {
                      final guide = guides[index];
                      final data = guide.data() as Map<String, dynamic>;
                      final guideId = guide.id;

                      return Card(
                        child: ListTile(
                          title: Text(data['title'] ?? 'No title'),
                          subtitle: Text(data['content'] ?? 'No content'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditGuideScreen(guideId: guideId),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteGuide(guideId);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteGuide(String guideId) async {
    await _firestore.collection('guides').doc(guideId).delete(); // Collection for guides
  }
}

class CreateGuideScreen extends StatefulWidget {
  const CreateGuideScreen({super.key});

  @override
  _CreateGuideScreenState createState() => _CreateGuideScreenState();
}

class _CreateGuideScreenState extends State<CreateGuideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Guide'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _createGuide();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createGuide() async {
    await _firestore.collection('guides').add({ // Collection for guides
      'title': _titleController.text,
      'content': _contentController.text,
    });
    Navigator.pop(context);
  }
}

class EditGuideScreen extends StatefulWidget {
  final String guideId;

  const EditGuideScreen({super.key, required this.guideId});

  @override
  _EditGuideScreenState createState() => _EditGuideScreenState();
}

class _EditGuideScreenState extends State<EditGuideScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _loadGuideData();
  }

  void _loadGuideData() async {
    final doc = await _firestore.collection('guides').doc(widget.guideId).get(); // Collection for guides
    final data = doc.data() as Map<String, dynamic>;

    setState(() {
      _titleController.text = data['title'] ?? '';
      _contentController.text = data['content'] ?? '';
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Guide ${widget.guideId}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _updateGuide();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateGuide() async {
    await _firestore.collection('guides').doc(widget.guideId).update({ // Collection for guides
      'title': _titleController.text,
      'content': _contentController.text,
    });
    Navigator.pop(context);
  }
}
