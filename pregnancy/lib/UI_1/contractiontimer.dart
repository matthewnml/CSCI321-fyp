import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  void _stopTimer() {
    setState(() {
      _isTiming = false;
      _timer?.cancel();
      if (_startTime != null) {
        _contractions.add({
          'intensity': _intensity,
          'duration': _contractionDuration,
          'time': _startTime!,
        });
        _intensity = ''; // Reset intensity after saving
      }
    });
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
                    subtitle: Text(
                      'Duration: ${_formatDuration(contraction['duration'])}\nTime: ${_formatTime(contraction['time'])}',
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
