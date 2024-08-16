import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'utilities/health.dart';  // Import your health service

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

  @override
  void initState() {
    super.initState();
    _fetchHeartRateData();
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

      //print('Data points retrieved: ${dataPoints?.length}');
      
      if (dataPoints != null && dataPoints.isNotEmpty) {
        setState(() {
          _heartRateSpots = dataPoints.map((point) {
            final x = point.dateFrom.hour.toDouble() + point.dateFrom.minute.toDouble() / 60;

            //print('point.value runtime type: ${point.value.runtimeType}');

            final y = (point.value as NumericHealthValue).numericValue.toDouble();
            //print('FLSpot created: x = $x, y = $y');

            return FlSpot(x, y);
          }).toList();

          //print('FLSpot List: $_heartRateSpots');

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

  String _getFormattedHour(double value) {
    int hours = value.toInt();
    if (hours >= 24) hours = hours % 24; // Wrap around if greater than 24
    return '$hours:00';
  }

  @override
  Widget build(BuildContext context) {
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
            _buildInfoRow('Resting Heart Rate:', _restingHeartRate != null ? '${_restingHeartRate!.toInt()} BPM' : 'N/A'),
            const SizedBox(height: 10),
            _buildInfoRow(
              'Range:',
              _heartRateRange != null
                  ? '${_heartRateRange!['min']!.toInt()} - ${_heartRateRange!['max']!.toInt()} BPM'
                  : 'N/A',
            ),
            const SizedBox(height: 20),
            _buildNotificationToggle('High Heart Rate Notification', false),
            const SizedBox(height: 10),
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
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNotificationToggle(String label, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
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
