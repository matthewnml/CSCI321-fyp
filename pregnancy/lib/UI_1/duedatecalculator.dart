import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DueDateCalculatorPage extends StatefulWidget {
  final String userId;

  const DueDateCalculatorPage({Key? key, required this.userId})
      : super(key: key);

  @override
  _DueDateCalculatorPageState createState() => _DueDateCalculatorPageState();
}

class _DueDateCalculatorPageState extends State<DueDateCalculatorPage> {
  final TextEditingController _lastPeriodController = TextEditingController();
  final TextEditingController _cycleLengthController = TextEditingController();
  final TextEditingController _ivfController = TextEditingController();
  final TextEditingController _conceptionController = TextEditingController();
  final TextEditingController _ultrasoundController = TextEditingController();
  final TextEditingController _ultrasoundWeeksController =
  TextEditingController();
  final TextEditingController _ultrasoundDaysController =
  TextEditingController();
  DateTime? _estimatedDueDate;
  bool _calculating = false;
  String _selectedMethod = 'Last Period';
  String _selectedEmbryoAge = 'Day 3';

  @override
  void dispose() {
    _lastPeriodController.dispose();
    _cycleLengthController.dispose();
    _ivfController.dispose();
    _conceptionController.dispose();
    _ultrasoundController.dispose();
    _ultrasoundWeeksController.dispose();
    _ultrasoundDaysController.dispose();
    super.dispose();
  }

  void _calculateDueDate() {
    setState(() {
      _calculating = true;
    });

    try {
      DateTime? estimatedDueDate;

      if (_selectedMethod == 'Last Period') {
        DateTime lastPeriod = DateTime.parse(_lastPeriodController.text);
        int cycleLength = int.parse(_cycleLengthController.text);
        if (cycleLength < 21 || cycleLength > 35) {
          throw Exception('Cycle length must be between 21 and 35 days.');
        }
        int adjustment = cycleLength - 28;
        estimatedDueDate = lastPeriod.add(Duration(days: 280 + adjustment));
      } else if (_selectedMethod == 'IVF') {
        DateTime ivfDate = DateTime.parse(_ivfController.text);
        int embryoAgeDays = _selectedEmbryoAge == 'Day 3' ? 263 : 261;
        estimatedDueDate = ivfDate.add(Duration(days: embryoAgeDays));
      } else if (_selectedMethod == 'Conception') {
        DateTime conceptionDate = DateTime.parse(_conceptionController.text);
        estimatedDueDate = conceptionDate.add(Duration(days: 266));
      } else if (_selectedMethod == 'Ultrasound') {
        DateTime ultrasoundDate = DateTime.parse(_ultrasoundController.text);
        int ultrasoundWeeks = int.parse(_ultrasoundWeeksController.text);
        int ultrasoundDays = int.parse(_ultrasoundDaysController.text);
        int totalDays = (ultrasoundWeeks * 7) + ultrasoundDays;
        if (ultrasoundWeeks < 1 || ultrasoundWeeks > 42 || ultrasoundDays < 0 || ultrasoundDays > 6) {
          throw Exception('Ultrasound weeks must be between 1 and 42, and days between 0 and 6.');
        }
        estimatedDueDate = ultrasoundDate.add(Duration(days: 280 - totalDays));
      }

      setState(() {
        _estimatedDueDate = estimatedDueDate;
        _calculating = false;
      });
    } catch (e) {
      setState(() {
        _estimatedDueDate = null;
        _calculating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      hintText: 'Enter $label',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Due Date Calculator'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: _selectedMethod,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMethod = newValue!;
                });
              },
              items: <String>['Last Period', 'IVF', 'Conception', 'Ultrasound']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            if (_selectedMethod == 'Last Period') ...[
              TextField(
                controller: _lastPeriodController,
                decoration:
                _inputDecoration('First day of last period (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _cycleLengthController,
                decoration: _inputDecoration(
                    'Average length of menstrual cycle days (21-35)'),
                keyboardType: TextInputType.number,
              ),
            ] else if (_selectedMethod == 'IVF') ...[
              TextField(
                controller: _ivfController,
                decoration: _inputDecoration('IVF Transfer Date (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text('Embryo Age:'),
              ),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Day 3'),
                      leading: Radio<String>(
                        value: 'Day 3',
                        groupValue: _selectedEmbryoAge,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedEmbryoAge = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Day 5'),
                      leading: Radio<String>(
                        value: 'Day 5',
                        groupValue: _selectedEmbryoAge,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedEmbryoAge = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (_selectedMethod == 'Conception') ...[
              TextField(
                controller: _conceptionController,
                decoration: _inputDecoration('Conception Date (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
              ),
            ] else if (_selectedMethod == 'Ultrasound') ...[
              TextField(
                controller: _ultrasoundController,
                decoration: _inputDecoration('Ultrasound Date (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _ultrasoundWeeksController,
                decoration: _inputDecoration(
                    'Ultrasound Weeks (1-42)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _ultrasoundDaysController,
                decoration: _inputDecoration(
                    'Ultrasound Days (0-6)'),
                keyboardType: TextInputType.number,
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculating ? null : _calculateDueDate,
              child: _calculating
                  ? CircularProgressIndicator()
                  : Text('Calculate Due Date'),
            ),
            SizedBox(height: 16),
            if (_estimatedDueDate != null)
              Text(
                'Estimated Due Date: ${DateFormat('yyyy-MM-dd').format(_estimatedDueDate!)}',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: DueDateCalculatorPage(userId: 'user123'),
));
