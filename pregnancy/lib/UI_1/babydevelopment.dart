import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BabyDevelopmentPage extends StatefulWidget {
  final String userId;

  const BabyDevelopmentPage({super.key, required this.userId});

  @override
  _BabyDevelopmentPageState createState() => _BabyDevelopmentPageState();
}

class _BabyDevelopmentPageState extends State<BabyDevelopmentPage> with SingleTickerProviderStateMixin {
  final List<double?> weights = List<double?>.filled(12, null);
  final List<double?> heights = List<double?>.filled(12, null);
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

        weights[monthIndex] = newWeight;
        heights[monthIndex] = newHeight;
      });

      _weightController.clear();
      _heightController.clear();
      Navigator.pop(context); // Close the dialog
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid data and select a valid month.')));
    }
  }

  void _deleteData(int index) {
    setState(() {
      weights[index] = null;
      heights[index] = null;
    });
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
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

  Widget _buildTrendGraph(String title, List<double?> data, Color color) {
    final adjustedData = List.generate(months.length, (index) {
      return data[index] != null ? FlSpot(index.toDouble(), data[index]!) : null;
    }).where((spot) => spot != null).toList();

    final double maxY = data.where((d) => d != null).isNotEmpty
        ? data.where((d) => d != null).reduce((a, b) => a! > b! ? a : b)!
        : 100;
    const double minY = 0;
    final double interval = (maxY / 10).ceilToDouble() + 1;

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
                maxY: maxY + 5,
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
                      reservedSize: 60,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              months[index],
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 70,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '${value.toInt()}',
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  rightTitles: const AxisTitles(
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
                    spots: adjustedData.cast<FlSpot>(),
                    isCurved: true,
                    barWidth: 4,
                    color: color,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                    aboveBarData: BarAreaData(show: false),
                  ),
                ],
                lineTouchData: const LineTouchData(
                  enabled: false,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columnSpacing: 2,
                columns: const [
                  DataColumn(label: Text('Month')),
                  DataColumn(label: Text('Height (cm)')),
                  DataColumn(label: Text('Weight (kg)')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: List<DataRow>.generate(months.length, (index) {
                  return DataRow(cells: [
                    DataCell(Text(months[index])),
                    DataCell(Text(heights[index]?.toStringAsFixed(1) ?? 'N/A')),
                    DataCell(Text(weights[index]?.toStringAsFixed(1) ?? 'N/A')),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(index),
                      ),
                    ),
                  ]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Data'),
        content: Text('Are you sure you want to delete the data for ${months[index]}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteData(index);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
