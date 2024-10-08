import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KickCounterPage extends StatefulWidget {
  final String userId;

  const KickCounterPage({super.key, required this.userId});

  @override
  _KickCounterPageState createState() => _KickCounterPageState();
}

class _KickCounterPageState extends State<KickCounterPage> {
  int _kickCount = 0;
  DateTime _startTime = DateTime.now();
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  final List<Map<String, dynamic>> _records = [];
  bool _isTimerStarted = false;

  @override
  void initState() {
    super.initState();
    _loadSavedRecords(); // Load saved records when the page is initialized
  }

  Future<void> _loadSavedRecords() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(widget.userId)
          .collection('kick_records')
          .orderBy('timestamp', descending: false)
          .get();

      setState(() {
        _records.addAll(snapshot.docs.map((doc) => {
              'id': _records.length + 1,
              'date': doc['date'],
              'startTime': doc['startTime'],
              'duration': doc['duration'],
              'kicks': doc['kicks'],
            }).toList());
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load records: $e')),
      );
    }
  }

  void _incrementKickCount() {
    setState(() {
      _kickCount++;
    });
  }

  void _resetKickCount() {
    setState(() {
      _kickCount = 0;
      _elapsedTime = Duration.zero;
      _timer?.cancel();
      _isTimerStarted = false;
    });
  }

  void _startTimer() {
    setState(() {
      _resetKickCount(); // Reset kick count and timer
      _startTime = DateTime.now();
      _timer?.cancel(); // Cancel any existing timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedTime = DateTime.now().difference(_startTime);
        });
      });
      _isTimerStarted = true;
    });
  }

  Future<void> _finishAndSave() async {
    setState(() {
      _timer?.cancel();
      _records.add({
        'id': _records.length + 1,
        'date': _formatDate(_startTime),
        'startTime': _formatTime(_startTime),
        'duration': _formatDuration(_elapsedTime),
        'kicks': _kickCount,
      });
    });

    // Save the record to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(widget.userId)
          .collection('kick_records') // New collection for kick records
          .add({
        'date': _formatDate(_startTime),
        'startTime': _formatTime(_startTime),
        'duration': _formatDuration(_elapsedTime),
        'kicks': _kickCount,
        'timestamp': _startTime, // Useful for querying later
      });

      _resetKickCount(); // Reset the kick count and timer after saving
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save record: $e')),
      );
    }
  }

  void _deleteRecord(int id) {
    setState(() {
      _records.removeWhere((record) => record['id'] == id);
    });
  }

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm:ss a').format(time);
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatDuration(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kick Counter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8.0),
            _buildInfo('Date', _formatDate(_startTime)),
            const SizedBox(height: 8.0),
            _buildInfo('Start Time', _formatTime(_startTime)),
            const SizedBox(height: 8.0),
            _buildInfo('Duration', _formatDuration(_elapsedTime)),
            const SizedBox(height: 8.0),
            _buildInfo('Kicks', '$_kickCount'),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _isTimerStarted ? _incrementKickCount : null,
              child: const Text('Count Kick'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isTimerStarted ? _resetKickCount : null,
              child: const Text('Reset'),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startTimer,
                  child: const Text('Start Timer'),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _isTimerStarted ? _finishAndSave : null,
                  child: const Text('Finish and Save'),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            _buildRecordsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String title, String value) {
    return SizedBox(
      width: 300,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index];
          return Card(
            child: ListTile(
              title: Text('Date: ${record['date']}'),
              subtitle: Text(
                  'Start Time: ${record['startTime']}\nDuration: ${record['duration']}\nKicks: ${record['kicks']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteRecord(record['id']),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
