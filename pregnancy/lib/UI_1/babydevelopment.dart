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
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _monthController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _addData() {
    final newMonth = _monthController.text;
    final newWeight = double.tryParse(_weightController.text);
    final newHeight = double.tryParse(_heightController.text);

    if (newMonth.isNotEmpty && newWeight != null && newHeight != null) {
      setState(() {
        months.add(newMonth);
        weights.add(newWeight);
        heights.add(newHeight);
      });

      _monthController.clear();
      _weightController.clear();
      _heightController.clear();
      Navigator.pop(context); // Close the dialog
    } else {
      // Handle invalid input
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid data.')));
    }
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
        onPressed: () => _showAddDataDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }

  void _showAddDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _monthController,
              decoration: const InputDecoration(labelText: 'Month'),
            ),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Height (cm)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _addData,
            child: const Text('Add'),
          ),
        ],
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
                        if (index < months.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(months[index]),
                          );
                        }
                        return const Text('');
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

