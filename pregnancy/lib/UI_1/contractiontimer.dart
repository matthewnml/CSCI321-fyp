import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContractionTimerPage extends StatefulWidget {
  @override
  _ContractionTimerPageState createState() => _ContractionTimerPageState();
}

class _ContractionTimerPageState extends State<ContractionTimerPage> {
  bool _isTiming = false;
  bool _isFirstContraction = true;
  late DateTime _startTime;
  late DateTime _endTime;
  Duration _contractionDuration = Duration(seconds: 0);
  int _contractionCount = 0;
  late Timer _timer;
  late Stream<int> _timerStream;
  late StreamSubscription<int> _timerSubscription;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _endTime = _startTime.add(Duration(days: 365));
  }

  @override
  void dispose() {
    _timerSubscription.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isTiming = true;
      _startTime = DateTime.now();
      _endTime = _startTime.add(_contractionDuration); // Update _endTime when starting the timer
      if (!_isFirstContraction) {
        _contractionCount++;
      } else {
        _isFirstContraction = false;
      }
      _timerStream = Stream<int>.periodic(Duration(seconds: 1), (x) => x).takeWhile((_) => _isTiming);
      _timerSubscription = _timerStream.listen((_) {
        setState(() {
          _contractionDuration = DateTime.now().difference(_startTime);
        });
      });
    });
  }

  void _stopTimer() {
    setState(() {
      _isTiming = false;
      _endTime = DateTime.now();
      _contractionDuration = _endTime.difference(_startTime);
      _timerSubscription.cancel();
      _sendContractionData(_contractionDuration);
    });
  }

  void _resetTimer() {
    setState(() {
      _isTiming = false;
      _contractionDuration = Duration(seconds: 0);
      _contractionCount = 0;
    });
  }

  void _sendContractionData(Duration duration) {
    // Implement the function to send contraction data back to the home page
    // You can use a callback function or any other method to send data back
  }

  String _formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, "0");
  }

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm:ss a').format(time);
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
            _buildInfoContainer('Start Time', _formatTime(_startTime)),
            SizedBox(height: 16.0),
            if (_isTiming) _buildInfoContainer('End Time', _formatTime(_endTime)),
            SizedBox(height: 16.0),
            if (_isTiming) _buildInfoContainer('Duration', _formatDuration(_contractionDuration)),
            SizedBox(height: 16.0),
            if (_isTiming) _buildInfoContainer('Frequency', _contractionCount.toString()),
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isTiming ? null : _startTimer,
                  child: Text('Start Contraction'),
                ),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: Text('Reset Timer'),
                ),
                ElevatedButton(
                  onPressed: _isTiming ? _stopTimer : null,
                  child: Text('Stop Contraction'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoContainer(String title, String value) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }
}


