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
    _guideStream = _firestore.collection('guides').snapshots();
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
                      final urls = data['url'] is Map
                          ? data['url'] as Map<String, dynamic>
                          : <String, dynamic>{'default': data['url']};

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListTile(
                            title: Text(
                              data['title']?.toString() ?? 'No title',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: urls.entries.map<Widget>((entry) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Text(
                                      '${entry.key}: ${entry.value}',
                                      style: const TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
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
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(guideId);
                                  },
                                ),
                              ],
                            ),
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

  void _showDeleteConfirmationDialog(String guideId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Guide'),
          content: const Text('Are you sure you want to delete this guide? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteGuide(guideId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteGuide(String guideId) async {
    await _firestore.collection('guides').doc(guideId).delete();
  }
}

class CreateGuideScreen extends StatefulWidget {
  const CreateGuideScreen({super.key});

  @override
  _CreateGuideScreenState createState() => _CreateGuideScreenState();
}

class _CreateGuideScreenState extends State<CreateGuideScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = '';
  final _displayNameController = TextEditingController();
  final _urlController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _guideStream;

  @override
  void initState() {
    super.initState();
    _guideStream = _firestore.collection('guides').snapshots();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

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
              StreamBuilder<QuerySnapshot>(
                stream: _guideStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final categories = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['title']?.toString() ?? '';
                  }).toList();

                  return DropdownButtonFormField<String>(
                    value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                    items: categories.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue ?? '';
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select Category',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  );
                },
              ),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a display name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _addGuideToCategory();
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

  void _addGuideToCategory() async {
    final snapshot = await _firestore
        .collection('guides')
        .where('title', isEqualTo: _selectedCategory)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      final urls = data['url'] is Map
          ? data['url'] as Map<String, dynamic>
          : <String, dynamic>{'default': data['url']};
      urls[_displayNameController.text] = _urlController.text;

      await _firestore.collection('guides').doc(doc.id).update({
        'url': urls,
      });

      Navigator.pop(context);
    }
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
  final Map<String, TextEditingController> _urlControllers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _loadGuideData();
  }

  void _loadGuideData() async {
    final doc = await _firestore.collection('guides').doc(widget.guideId).get();
    final data = doc.data() as Map<String, dynamic>;

    setState(() {
     
      _titleController.text = data['title']?.toString() ?? '';

      final urls = data['url'] as Map<String, dynamic>;
      urls.forEach((key, value) {
        _urlControllers[key] = TextEditingController(text: value.toString());
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Guide'),
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
              const SizedBox(height: 20),
              ..._urlControllers.entries.map((entry) {
                final key = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: key,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showUrlDeleteConfirmationDialog(key);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
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

  void _showUrlDeleteConfirmationDialog(String urlKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete URL'),
          content: const Text('Are you sure you want to delete this URL?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _urlControllers.remove(urlKey);
                });
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _updateGuide() async {
    final urls = _urlControllers.map((key, controller) => MapEntry(key, controller.text));
    await _firestore.collection('guides').doc(widget.guideId).update({
      'title': _titleController.text,
      'url': urls,
    });

    Navigator.pop(context);
  }
}
