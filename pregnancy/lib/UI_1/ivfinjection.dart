import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class IVFInjectionTrackerPage extends StatefulWidget {
  final String userId;

  const IVFInjectionTrackerPage({Key? key, required this.userId})
      : super(key: key);

  @override
  _IVFInjectionTrackerPageState createState() =>
      _IVFInjectionTrackerPageState();
}

class _IVFInjectionTrackerPageState extends State<IVFInjectionTrackerPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _injections = {};

  final TextEditingController _controller = TextEditingController();

  void _addInjection() {
    if (_selectedDay != null && _controller.text.isNotEmpty) {
      setState(() {
        if (_injections[_selectedDay!] == null) {
          _injections[_selectedDay!] = [];
        }
        _injections[_selectedDay!]!.add(_controller.text);
        _controller.clear();
      });
    }
  }

  void _removeInjection(DateTime day, int index) {
    setState(() {
      _injections[day]!.removeAt(index);
      if (_injections[day]!.isEmpty) {
        _injections.remove(day);
      }
    });
  }

  List<String> _getInjectionsForDay(DateTime day) {
    return _injections[day] ?? [];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year, // Opens the year picker first
    );
    if (picked != null) {
      setState(() {
        _focusedDay = DateTime(picked.year, picked.month,
            1); // Focus on the first day of the selected month
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IVF Injection Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // update `_focusedDay` here as well
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getInjectionsForDay,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Injection Details',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addInjection,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount:
                  _getInjectionsForDay(_selectedDay ?? DateTime.now()).length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_getInjectionsForDay(
                      _selectedDay ?? DateTime.now())[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeInjection(_selectedDay!, index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
