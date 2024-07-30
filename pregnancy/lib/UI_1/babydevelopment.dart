import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BabyDevelopmentPage extends StatefulWidget {
  final String userId;

  const BabyDevelopmentPage({super.key, required this.userId});

  @override
  _BabyDevelopmentPageState createState() => _BabyDevelopmentPageState();
}

class _BabyDevelopmentPageState extends State<BabyDevelopmentPage> with SingleTickerProviderStateMixin {
  final List<double> weights = [3.5, 4.2, 5.0, 5.8, 6.2, 6.5, 7.0, 7.3, 7.6, 8.0, 8.3, 8.5];
  final List<double> heights = [50, 54, 57, 60, 62, 64, 66, 68, 70, 72, 74, 76];
  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'
  ];

  late TabController _tabController;
  String selectedMonth = 'January';
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
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _addData() {
    final newWeight = double.tryParse(_weightController.text);
    final newHeight = double.tryParse(_heightController.text);

    if (newWeight != null && newHeight != null && months.contains(selectedMonth)) {
      setState(() {
        final monthIndex = months.indexOf(selectedMonth);

        if (monthIndex < weights.length) {
          weights[monthIndex] = newWeight;
          heights[monthIndex] = newHeight;
        } else {
          weights.add(newWeight);
          heights.add(newHeight);
        }
      });

      _weightController.clear();
      _heightController.clear();
      Navigator.pop(context); // Close the dialog
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid data and select a valid month.')));
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
          _buildTrendGraph('Height (cm)', heights, Colors.green),
          _buildTrendGraph('Weight (kg)', weights, Colors.blue),
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
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: selectedMonth,
                  onChanged: (String? newValue) {
                    if (newValue != null && months.contains(newValue)) {
                      setState(() {
                        selectedMonth = newValue;
                      });
                    }
                  },
                  items: months.map<DropdownMenuItem<String>>((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(month),
                    );
                  }).toList(),
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
            );
          },
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
    final double maxDataValue = data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) : 100;
    final double minY = 0;
    final double maxY = maxDataValue + 5;
    final double interval = (maxY / 10).ceilToDouble();
    final adjustedData = List.generate(months.length, (index) {
      return FlSpot(index.toDouble(), index < data.length ? data[index] : 0);
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                maxY: maxY,
                minY: minY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: interval,
                  verticalInterval: 1,
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60, // Increased reserved size for bottom titles
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < months.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0), // Adjust vertical padding
                              child: Text(
                                months[index],
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center, // Center align text
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 70, // Increased reserved size for left titles
                      interval: interval, // Adjust interval based on data range
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Adjust horizontal padding
                            child: Text(
                              '${value.toInt()}',
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.right, // Align text to the right
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false, // Hide top titles
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: const Color(0xff37434d),
                    width: 1,
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: adjustedData,
                    isCurved: true,
                    barWidth: 4,
                    color: color,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                    aboveBarData: BarAreaData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
