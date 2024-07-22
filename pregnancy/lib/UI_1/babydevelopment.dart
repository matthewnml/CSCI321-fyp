import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BabyDevelopmentPage extends StatefulWidget {
  final String userId;

  const BabyDevelopmentPage({super.key, required this.userId});

  @override
  _BabyDevelopmentPageState createState() => _BabyDevelopmentPageState();
}

class _BabyDevelopmentPageState extends State<BabyDevelopmentPage> {
  final List<double> weights = [3.5, 4.2, 5.0, 5.8]; // Sample weights in kg
  final List<double> heights = [50, 54, 57, 60]; // Sample heights in cm
  final List<String> months = ['Month 1', 'Month 2', 'Month 3', 'Month 4']; // Sample months

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Development'),
        backgroundColor: const Color(0xFFFFF4F4),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track Your Baby\'s Growth',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildDevelopmentTile('assets/month1.png', 'Month 1', 'Description of milestones for month 1...'),
                  _buildDevelopmentTile('assets/month2.png', 'Month 2', 'Description of milestones for month 2...'),
                  _buildDevelopmentTile('assets/month3.png', 'Month 3', 'Description of milestones for month 3...'),
                  const SizedBox(height: 16),
                  _buildTrendGraph(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add milestone button press
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }

  Widget _buildDevelopmentTile(String imagePath, String title, String description) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          width: 50,
          height: 50,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.black),
          onPressed: () {
            // Handle edit button press
          },
        ),
      ),
    );
  }

  Widget _buildTrendGraph() {
    return Column(
      children: [
        const Text(
          'Growth Trends',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(months[index]),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(value.toString()),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(weights.length, (index) => FlSpot(index.toDouble(), weights[index])),
                  isCurved: true,
                  barWidth: 2,
                  color: Colors.blue, // Set the line color directly
                  dotData: FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: List.generate(heights.length, (index) => FlSpot(index.toDouble(), heights[index])),
                  isCurved: true,
                  barWidth: 2,
                  color: Colors.green, // Set the line color directly
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              color: Colors.blue,
            ),
            const SizedBox(width: 5),
            const Text('Weight (kg)'),
            const SizedBox(width: 20),
            Container(
              width: 10,
              height: 10,
              color: Colors.green,
            ),
            const SizedBox(width: 5),
            const Text('Height (cm)'),
          ],
        ),
      ],
    );
  }
}