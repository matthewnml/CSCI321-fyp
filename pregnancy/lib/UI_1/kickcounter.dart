import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KickCounterPage extends StatefulWidget {
  @override
  _KickCounterState createState() => _KickCounterState();
}

class _KickCounterState extends State<KickCounterPage> {
  int _kickCount = 0;
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(Duration(minutes: 30));
  Timer? _timer;
  Duration _remainingTime = Duration(minutes: 30);

  void _incrementKickCount() {
    setState(() {
      _kickCount++;
    });
  }

  void _resetKickCount() {
    setState(() {
      _kickCount = 0;
      _endTime = DateTime.now().add(Duration(minutes: 30)); // Reset duration to 30 minutes
      _remainingTime = Duration(minutes: 30);
    });
  }

  void _startTimer() {
    setState(() {
      _startTime = DateTime.now();
      _endTime = _startTime.add(Duration(minutes: 30)); // 30 minutes for tracking kicks
      _kickCount = 0;
      _remainingTime = Duration(minutes: 30);
      _timer?.cancel(); // Cancel any existing timer
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_remainingTime.inSeconds > 0) {
          setState(() {
            _remainingTime = _remainingTime - Duration(seconds: 1);
          });
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _stopTimer() {
    setState(() {
      _timer?.cancel();
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
        title: Text('Kick Counter'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 8.0),
            _buildInfo('Date', _formatDate(_startTime)),
            SizedBox(height: 8.0),
            _buildInfo('Start Time', _formatTime(_startTime)),
            SizedBox(height: 8.0),
            _buildInfo('Duration', _formatDuration(_remainingTime)),
            SizedBox(height: 8.0),
            _buildInfo('Kicks', '$_kickCount'),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _incrementKickCount,
              child: Text('Count Kick'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _resetKickCount,
              child: Text('Reset'),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startTimer,
                  child: Text('Start Timer'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _stopTimer,
                  child: Text('Stop Timer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String title, String value) {
    return SizedBox(
      width: 200, // Adjust the width according to your preference
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
