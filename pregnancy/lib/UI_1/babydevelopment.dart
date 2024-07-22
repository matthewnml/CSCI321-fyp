import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BabyDevelopmentPage extends StatefulWidget {
  final String userId;

  const BabyDevelopmentPage({super.key, required this.userId});

  @override
  _BabyDevelopmentPageState createState() => _BabyDevelopmentPageState();
}

class _BabyDevelopmentPageState extends State<BabyDevelopmentPage> with SingleTickerProviderStateMixin {
  final List<double> weights = [3.5, 4.2, 5.0, 5.8]; // Sample weights in kg
  final List<double> heights = [50, 54, 57, 60]; // Sample heights in cm
  final List<String> months = ['Month 1', 'Month 2', 'Month 3', 'Month 4']; // Sample months

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Development'),
        backgroundColor: const Color(0xFFFFF4F4),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Height'),
            Tab(text: 'Weight'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrendGraph('Height', heights, Colors.green),
          _buildTrendGraph('Weight', weights, Colors.blue),
        ],
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

  Widget _buildTrendGraph(String title, List<double> data, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            '$title Trends',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
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
                    spots: List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index])),
                    isCurved: true,
                    barWidth: 2,
                    color: color, // Set the line color directly
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
