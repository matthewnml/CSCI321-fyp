import 'package:flutter/material.dart';
import 'package:health/health.dart';

class HeartRateTracker extends StatefulWidget {
  const HeartRateTracker({super.key});

  @override
  _HeartRateTrackerState createState() => _HeartRateTrackerState();
}

class _HeartRateTrackerState extends State<HeartRateTracker> {
  HealthFactory health = HealthFactory();
  List<HealthDataPoint> _healthDataList = [];
  double? _restingHeartRate;
  String _heartRateRange = "-";

  @override
  void initState() {
    super.initState();
    fetchHeartRateData();
  }

  Future<void> fetchHeartRateData() async {
    final types = [HealthDataType.HEART_RATE];
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));

    bool requested = await health.requestAuthorization(types);

    if (requested) {
      try {
        List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(yesterday, now, types);
        _healthDataList = HealthFactory.removeDuplicates(healthData);

        if (_healthDataList.isNotEmpty) {
          // Calculate resting heart rate and range
          _restingHeartRate = _healthDataList.map((e) => e.value).reduce((a, b) => a + b) / _healthDataList.length;
          double minRate = _healthDataList.map((e) => e.value).reduce((a, b) => a < b ? a : b);
          double maxRate = _healthDataList.map((e) => e.value).reduce((a, b) => a > b ? a : b);
          _heartRateRange = "$minRate - $maxRate BPM";
        } else {
          _restingHeartRate = null;
          _heartRateRange = "-";
        }
      } catch (e) {
        print("Error fetching heart rate data: $e");
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate Tracker'),
        backgroundColor: const Color(0xFFFFEDED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Handle notification icon tap
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFEDED),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Heart Rate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Placeholder(), // Replace with the actual chart
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Resting Heart Rate: ${_restingHeartRate?.toStringAsFixed(1) ?? "-"} BPM',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Range: $_heartRateRange',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('High Heart Rate Notification'),
                    value: false,
                    onChanged: (bool value) {
                      // Handle switch state change
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Low Heart Rate Notification'),
                    value: false,
                    onChanged: (bool value) {
                      // Handle switch state change
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
