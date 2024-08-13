import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'utilities/health.dart';  // Import your health service

class HeartRateTracker extends StatefulWidget {
  @override
  _HeartRateTrackerState createState() => _HeartRateTrackerState();
}

class _HeartRateTrackerState extends State<HeartRateTracker> {
  List<FlSpot> _heartRateSpots = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchHeartRateData();
  }

  Future<void> _fetchHeartRateData() async {
    try {
      final healthService = HealthService();
      final dataPoints = await healthService.getHeartRate();
      
      if (mounted) { // Check if the widget is still mounted
        if (dataPoints != null) {
          setState(() {
            _heartRateSpots = dataPoints.map((point) {
              final x = point.dateFrom.hour.toDouble() + point.dateFrom.minute.toDouble() / 60;
              final y = (point.value as num).toDouble(); // Ensure the value is a num before converting to double
              return FlSpot(x, y);
            }).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'No data available';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) { // Check if the widget is still mounted
        setState(() {
          _error = 'Failed to fetch data';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Heart Rate Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Heart Rate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _error.isNotEmpty
                        ? Center(child: Text(_error))
                        : LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              minX: 0,
                              maxX: 24,
                              minY: 0,
                              maxY: 150,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _heartRateSpots,
                                  isCurved: true,
                                  color: Colors.redAccent,
                                  barWidth: 4,
                                  belowBarData: BarAreaData(show: false),
                                  dotData: FlDotData(show: false),
                                ),
                              ],
                            ),
                          ),
              ),
            ),
            SizedBox(height: 20),
            _buildInfoRow('Resting Heart Rate:', '50 BPM'),
            SizedBox(height: 10),
            _buildInfoRow('Range:', '50 - 110 BPM'),
            SizedBox(height: 20),
            _buildNotificationToggle('High Heart Rate Notification', false),
            SizedBox(height: 10),
            _buildNotificationToggle('Low Heart Rate Notification', false),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNotificationToggle(String label, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        Switch(
          value: value,
          onChanged: (newValue) {
            // Implement notification toggle logic
          },
        ),
      ],
    );
  }
}
