import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firestore
import 'utilities/health.dart';  // Import your health service
import 'high_heart_noti.dart';  // Import the high heart rate notification page
import 'low_heart_noti.dart';  // Import the low heart rate notification page
import 'package:firebase_auth/firebase_auth.dart';  // Import FirebaseAuth

class HeartRateTracker extends StatefulWidget {
  const HeartRateTracker({super.key});

  @override
  _HeartRateTrackerState createState() => _HeartRateTrackerState();
}

class _HeartRateTrackerState extends State<HeartRateTracker> {
  List<FlSpot> _heartRateSpots = [];
  bool _isLoading = true;
  String? _error = '';
  double? _restingHeartRate;
  Map<String, double>? _heartRateRange;
  int? _highHeartRateThreshold;
  int? _lowHeartRateThreshold;

  @override
  void initState() {
    super.initState();
    _fetchHeartRateData();
    _fetchHeartRateThresholds();  // Fetch the current thresholds
  }

  Future<void> _fetchHeartRateData() async {
    try {
      final healthService = HealthService();
      final dataPoints = await healthService.getHeartRate();
      final restingHeartRate = await healthService.getRestingHeartRate();
      final heartRateRange = await healthService.getHeartRateRange();

      setState(() {
        _restingHeartRate = restingHeartRate as double?;
        _heartRateRange = heartRateRange;
      });

      if (dataPoints != null && dataPoints.isNotEmpty) {
        setState(() {
          _heartRateSpots = dataPoints.map((point) {
            final x = point.dateFrom.hour.toDouble() + point.dateFrom.minute.toDouble() / 60;
            final y = (point.value as NumericHealthValue).numericValue.toDouble();
            return FlSpot(x, y);
          }).toList();

          _error = null; // Clear any previous errors
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No data available';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to fetch data';
          _isLoading = false;
        });
      }
      print('Error fetching heart rate data: $e');
    }
  }

  Future<void> _fetchHeartRateThresholds() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final highThresholdDoc = await FirebaseFirestore.instance
            .collection('user_accounts')
            .doc(user.uid)
            .collection('heart_rate_notifications')
            .doc('high')
            .get();

        final lowThresholdDoc = await FirebaseFirestore.instance
            .collection('user_accounts')
            .doc(user.uid)
            .collection('heart_rate_notifications')
            .doc('low')
            .get();

        setState(() {
          _highHeartRateThreshold = highThresholdDoc.data()?['threshold'];
          _lowHeartRateThreshold = lowThresholdDoc.data()?['threshold'];
        });
      } catch (e) {
        print('Error fetching heart rate thresholds: $e');
      }
    }
  }

  String _getFormattedHour(double value) {
    int hours = value.toInt();
    if (hours >= 24) hours = hours % 24; // Wrap around if greater than 24
    return '$hours:00';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Heart Rate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!))
                        : LineChart(
                            LineChartData(
                              backgroundColor: Colors.white,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _heartRateSpots,
                                  isCurved: true,
                                  color: Colors.redAccent,
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  belowBarData: BarAreaData(show: false),
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 3,
                                        color: Colors.redAccent,
                                        strokeWidth: 0,
                                      );
                                    },
                                  ),
                                ),
                              ],
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Transform.translate(
                                          offset: const Offset(0, 15),  // Move the labels a bit down
                                          child: Transform.rotate(
                                            angle: -0.5,  // Rotate the labels slightly
                                            child: Text(
                                              _getFormattedHour(value),
                                              style: const TextStyle(
                                                color: Color(0xff68737d),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    interval: 2,  // Adjust interval to reduce overlap
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    reservedSize: 30, // Adjust reserved size for a more balanced space
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 7.0), // Adjust padding to move the labels right
                                        child: Text(
                                          '${value.toInt()}',
                                          style: const TextStyle(
                                            color: Color(0xff67727d),
                                            fontSize: 15,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              minY: 0,
                              maxY: 150,
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Resting Heart Rate:', _restingHeartRate != null ? '${_restingHeartRate!.toInt()} BPM' : '60'),
            const SizedBox(height: 10),
            _buildInfoRow(
              'Healthy range:',
              '50 - 140 BPM',
            ),
            const SizedBox(height: 20),
            _buildNotificationButton('High Heart Rate Threshold:', _highHeartRateThreshold != null ? '${_highHeartRateThreshold!} BPM' : 'Set Threshold', _navigateToHighHeartRateNoti),
            const SizedBox(height: 10),
            _buildNotificationButton('Low Heart Rate Threshold:', _lowHeartRateThreshold != null ? '${_lowHeartRateThreshold!} BPM' : 'Set Threshold', _navigateToLowHeartRateNoti),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNotificationButton(String label, String buttonText, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        ElevatedButton(
          onPressed: onTap,
          child: Text(buttonText),
        ),
      ],
    );
  }

  void _navigateToHighHeartRateNoti() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HighHeartRateNotificationPage(userId: FirebaseAuth.instance.currentUser!.uid)),
    );
  }

  void _navigateToLowHeartRateNoti() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LowHeartRateNotificationPage(userId: FirebaseAuth.instance.currentUser!.uid)),
    );
  }
}
