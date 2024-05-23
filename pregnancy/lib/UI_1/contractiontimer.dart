import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContractionTimerPage extends StatefulWidget {
  @override
  _ContractionTimerPageState createState() => _ContractionTimerPageState();
}

class _ContractionTimerPageState extends State<ContractionTimerPage> {
  bool _isTiming = false;
  DateTime? _startTime;
  Duration _contractionDuration = Duration(seconds: 0);
  Timer? _timer;
  String _intensity = '';
  List<Map<String, dynamic>> _contractions = [];

  void _startTimer() {
    setState(() {
      _isTiming = true;
      _startTime = DateTime.now();
      _contractionDuration = Duration(seconds: 0);
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
        title: Text('Contraction Timer'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isTiming ? _stopTimer : _startTimer,
                  child: _isTiming ? Text('Stop') : Text('Start'),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _setIntensity('Low'),
                  child: Text('Low'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _intensity == 'Low' ? Colors.blue : Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _setIntensity('Med'),
                  child: Text('Med'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _intensity == 'Med' ? Colors.blue : Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _setIntensity('High'),
                  child: Text('High'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _intensity == 'High' ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
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
                      icon: Icon(Icons.delete),
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

void main() {
  runApp(MaterialApp(
    home: ContractionTimerPage(),
  ));
}
