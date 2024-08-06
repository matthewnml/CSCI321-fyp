import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _userStream;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _userStream = _firestore.collection('user_accounts').snapshots();
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'All Users',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search for users...',
              ),
              onChanged: (value) {
                _updateSearchQuery(value);
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateUserScreen()),
                );
              },
              child: const Text('Create New User'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _userStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }
                  final users = snapshot.data!.docs.where((user) {
                    final data = user.data() as Map<String, dynamic>;
                    final fullName = data['full_name']?.toLowerCase() ?? '';
                    final email = data['email']?.toLowerCase() ?? '';
                    return fullName.contains(_searchQuery) || email.contains(_searchQuery);
                  }).toList();
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final data = user.data() as Map<String, dynamic>;
                      final userId = user.id;

                      return Card(
                        child: ListTile(
                          title: Text(data['full_name'] ?? 'No name'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date of Birth: ${data['date_of_birth'] ?? 'N/A'}'),
                              Text('Email: ${data['email'] ?? 'N/A'}'),
                              Text('Role: ${data['role'] ?? 'N/A'}'),
                              Text('Password: ${data['password'] ?? 'N/A'}'),
                              if (data['role'] == 'User') Text('Pregnancy Status: ${data['pregnancy_status'] ?? 'N/A'}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditUserScreen(userId: userId),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _confirmDeleteUser(userId);
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

  void _confirmDeleteUser(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete this user?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser(userId);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String userId) async {
    await _firestore.collection('user_accounts').doc(userId).delete();
  }
}

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedRole;
  String? _selectedPregnancyStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth (DD/MM/YYYY)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date of birth';
                  }
                  final parts = value.split('/');
                  if (parts.length != 3) {
                    return 'Please enter a valid date in the format DD/MM/YYYY';
                  }
                  final day = int.tryParse(parts[0]);
                  final month = int.tryParse(parts[1]);
                  final year = int.tryParse(parts[2]);
                  if (day == null || month == null || year == null) {
                    return 'Please enter a valid date in the format DD/MM/YYYY';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                hint: const Text('Select Role'),
                items: ['User', 'Specialist'].map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue;
                    if (_selectedRole == 'Specialist') {
                      _selectedPregnancyStatus = 'None(For Specialist)';
                    } else {
                      _selectedPregnancyStatus = null;
                    }
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              if (_selectedRole == 'User')
                DropdownButtonFormField<String>(
                  value: _selectedPregnancyStatus,
                  hint: const Text('Select Pregnancy Status'),
                  items: ['Trying to conceive', 'Currently pregnant', 'Have given birth']
                      .map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPregnancyStatus = newValue;
                    });
                  },
                  validator: (value) {
                    if (_selectedRole == 'User' && value == null) {
                      return 'Please select a pregnancy status';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _createUser();
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

  void _createUser() async {
    try {
      // Create user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Add user data to Firestore
      await _firestore.collection('user_accounts').doc(userCredential.user!.uid).set({
        'full_name': _nameController.text,
        'date_of_birth': _dobController.text,
        'email': _emailController.text,
        'password': _passwordController.text, // Store password securely
        'role': _selectedRole,
        'pregnancy_status': _selectedRole == 'User' ? _selectedPregnancyStatus : 'None(For Specialist)',
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error creating user: $e');
      // Handle error (e.g., show a dialog)
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class EditUserScreen extends StatefulWidget {
  final String userId;

  const EditUserScreen({required this.userId, super.key});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedRole;
  String? _selectedPregnancyStatus;
  String? _initialEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final docSnapshot = await _firestore.collection('user_accounts').doc(widget.userId).get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = data['full_name'] ?? '';
        _dobController.text = data['date_of_birth'] ?? '';
        _emailController.text = data['email'] ?? '';
        _initialEmail = data['email'];
        _passwordController.text = data['password'] ?? '';
        _selectedRole = data['role'];
        _selectedPregnancyStatus = data['pregnancy_status'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth (DD/MM/YYYY)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date of birth';
                  }
                  final parts = value.split('/');
                  if (parts.length != 3) {
                    return 'Please enter a valid date in the format DD/MM/YYYY';
                  }
                  final day = int.tryParse(parts[0]);
                  final month = int.tryParse(parts[1]);
                  final year = int.tryParse(parts[2]);
                  if (day == null || month == null || year == null) {
                    return 'Please enter a valid date in the format DD/MM/YYYY';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                hint: const Text('Select Role'),
                items: ['User', 'Specialist'].map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue;
                    if (_selectedRole == 'Specialist') {
                      _selectedPregnancyStatus = 'None(For Specialist)';
                    } else {
                      _selectedPregnancyStatus = null;
                    }
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              if (_selectedRole == 'User')
                DropdownButtonFormField<String>(
                  value: _selectedPregnancyStatus,
                  hint: const Text('Select Pregnancy Status'),
                  items: ['Trying to conceive', 'Currently pregnant', 'Have given birth']
                      .map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPregnancyStatus = newValue;
                    });
                  },
                  validator: (value) {
                    if (_selectedRole == 'User' && value == null) {
                      return 'Please select a pregnancy status';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _updateUser();
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

  void _updateUser() async {
    try {
      User? currentUser = _auth.currentUser;

      // Update email if changed
      if (_initialEmail != _emailController.text) {
        await currentUser!.updateEmail(_emailController.text);
      }

      // Update password if not empty
      if (_passwordController.text.isNotEmpty) {
        await currentUser!.updatePassword(_passwordController.text);
      }

      // Update user data in Firestore
      await _firestore.collection('user_accounts').doc(widget.userId).update({
        'full_name': _nameController.text,
        'date_of_birth': _dobController.text,
        'email': _emailController.text,
        'password': _passwordController.text, // Store password securely
        'role': _selectedRole,
        'pregnancy_status': _selectedRole == 'User' ? _selectedPregnancyStatus : 'None(For Specialist)',
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error updating user: $e');
      // Handle error (e.g., show a dialog)
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
