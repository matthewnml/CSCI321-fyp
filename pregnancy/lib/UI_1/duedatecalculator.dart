import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DueDateCalculatorPage extends StatefulWidget {
  final String userId;

  const DueDateCalculatorPage({super.key, required this.userId});

  @override
  _DueDateCalculatorPageState createState() => _DueDateCalculatorPageState();
}

class _DueDateCalculatorPageState extends State<DueDateCalculatorPage> {
  final TextEditingController _lastPeriodController = TextEditingController();
  final TextEditingController _cycleLengthController = TextEditingController();
  DateTime? _estimatedDueDate;
  bool _calculating = false;
  String _selectedMethod = 'Last Period';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadDueDateData();
  }

  @override
  void dispose() {
    _lastPeriodController.dispose();
    _cycleLengthController.dispose();
    super.dispose();
  }

  Future<void> _loadDueDateData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('user_accounts').doc(user.uid).get();
        if (userDoc.exists && userDoc['due_date_data'] != null) {
          Map<String, dynamic> dueDateData = userDoc['due_date_data'];
          _lastPeriodController.text = dueDateData['lastPeriod'] ?? '';
          _cycleLengthController.text = dueDateData['cycleLength'] ?? '';
          _selectedMethod = dueDateData['method'] ?? 'Last Period';
          if (dueDateData['estimatedDueDate'] != null) {
            _estimatedDueDate = (dueDateData['estimatedDueDate'] as Timestamp).toDate();
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _saveDueDateData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('user_accounts').doc(user.uid).set({
          'due_date_data': {
            'lastPeriod': _lastPeriodController.text,
            'cycleLength': _cycleLengthController.text,
            'method': _selectedMethod,
            'estimatedDueDate': _estimatedDueDate != null ? Timestamp.fromDate(_estimatedDueDate!) : null,
          },
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Due date data saved successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  void _calculateDueDate() {
    setState(() {
      _calculating = true;
    });

    try {
      DateTime? estimatedDueDate;

      if (_selectedMethod == 'Last Period') {
        DateTime lastPeriod = DateTime.parse(_lastPeriodController.text);
        int cycleLength = int.parse(_cycleLengthController.text);
        if (cycleLength < 21 || cycleLength > 35) {
          throw Exception('Cycle length must be between 21 and 35 days.');
        }
        int adjustment = cycleLength - 28;
        estimatedDueDate = lastPeriod.add(Duration(days: 280 + adjustment));
      }

      setState(() {
        _estimatedDueDate = estimatedDueDate;
        _calculating = false;
      });

      _saveDueDateData();
    } catch (e) {
      setState(() {
        _estimatedDueDate = null;
        _calculating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      hintText: 'Enter $label',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
    );
  }

  int getRemainingDays() {
    if (_estimatedDueDate == null) return 0;
    final now = DateTime.now();
    final difference = _estimatedDueDate!.difference(now).inDays;
    return difference;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Due Date Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDueDateData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: _selectedMethod,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMethod = newValue!;
                });
              },
              items: <String>['Last Period']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            if (_selectedMethod == 'Last Period') ...[
              TextField(
                controller: _lastPeriodController,
                decoration: _inputDecoration('First day of last period (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _cycleLengthController,
                decoration: _inputDecoration('Average length of menstrual cycle days (21-35)'),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculating ? null : _calculateDueDate,
              child: _calculating
                  ? const CircularProgressIndicator()
                  : const Text('Calculate Due Date'),
            ),
            const SizedBox(height: 16),
            if (_estimatedDueDate != null)
              Text(
                'Estimated Due Date: ${DateFormat('yyyy-MM-dd').format(_estimatedDueDate!)}',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
