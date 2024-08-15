import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContractionTimerPage extends StatefulWidget {
  final String userId;

  const ContractionTimerPage({super.key, required this.userId});

  @override
  _ContractionTimerPageState createState() => _ContractionTimerPageState();
}

class _ContractionTimerPageState extends State<ContractionTimerPage> {
  bool _isTiming = false;
  DateTime? _startTime;
  Duration _contractionDuration = const Duration(seconds: 0);
  Timer? _timer;
  String _intensity = '';
  final List<Map<String, dynamic>> _contractions = [];

  @override
  void initState() {
    super.initState();
    _loadSavedContractions();
  }

  Future<void> _loadSavedContractions() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(widget.userId)
          .collection('contractions')
          .orderBy('timestamp', descending: false)
          .get();

      setState(() {
        _contractions.addAll(snapshot.docs.map((doc) => {
              'intensity': doc['intensity'],
              'duration': Duration(seconds: doc['duration']), // Convert int to Duration
              'time': (doc['time'] as Timestamp).toDate(),
              'timeApart': doc['timeApart'],
            }).toList());
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load contractions: $e')),
      );
    }
  }

  void _startTimer() {
    setState(() {
      _isTiming = true;
      _startTime = DateTime.now();
      _contractionDuration = const Duration(seconds: 0);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _contractionDuration = DateTime.now().difference(_startTime!);
        });
      });
    });
  }

  Future<void> _stopTimer() async {
    setState(() {
      _isTiming = false;
      _timer?.cancel();
      if (_startTime != null) {
        String timeApart = '--'; // Default value for the first entry
        if (_contractions.isNotEmpty) {
          Duration interval = _startTime!.difference(_contractions.last['time']);
          int minutes = interval.inMinutes;
          int seconds = interval.inSeconds % 60;
          timeApart = '${minutes}m ${seconds}s'; // Calculate interval for subsequent entries
        }

        Map<String, dynamic> newContraction = {
          'intensity': _intensity,
          'duration': _contractionDuration.inSeconds, // Save duration in seconds
          'time': _startTime!,
          'timeApart': timeApart,
        };

        _contractions.add(newContraction);
        _intensity = ''; // Reset intensity after saving
      }
    });

    // Save to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(widget.userId)
          .collection('contractions')
          .add({
        'intensity': _intensity, // Store the intensity string
        'duration': _contractionDuration.inSeconds, // Save duration in seconds
        'time': _startTime!,
        'timeApart': _contractions.last['timeApart'], // Store timeApart correctly
        'timestamp': _startTime!, // Timestamp for querying later
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save contraction: $e')),
      );
    }
  }

  void _setIntensity(String intensity) {
    setState(() {
      _intensity = intensity;
    });
  }

  String _formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, "0");
  }

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contraction Timer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isTiming ? _stopTimer : _startTimer,
                  child: _isTiming ? const Text('Stop') : const Text('Start'),
                ),
              ],
            ),
            if (_isTiming) // Show timer only when timing
              Text(
                _formatDuration(_contractionDuration),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _setIntensity('Low'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _intensity == 'Low' ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('Low'),
                ),
                ElevatedButton(
                  onPressed: () => _setIntensity('Med'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _intensity == 'Med' ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('Med'),
                ),
                ElevatedButton(
                  onPressed: () => _setIntensity('High'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _intensity == 'High' ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('High'),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: _contractions.length,
                itemBuilder: (context, index) {
                  final contraction = _contractions[index];
                  return ListTile(
                    title: Text('Intensity: ${contraction['intensity']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duration: ${_formatDuration(contraction['duration'] is Duration ? contraction['duration'] : Duration(seconds: contraction['duration']))}',
                        ),
                        Text(
                          'Time: ${_formatTime(contraction['time'])}',
                        ),
                        Text(
                          'Frequency: ${contraction['timeApart']}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _contractions.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
