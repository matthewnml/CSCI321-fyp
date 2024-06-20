import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IVFInjectionTrackerPage extends StatefulWidget {
  final String userId;

  const IVFInjectionTrackerPage({super.key, required this.userId});

  @override
  _IVFInjectionTrackerPageState createState() => _IVFInjectionTrackerPageState();
}

class _IVFInjectionTrackerPageState extends State<IVFInjectionTrackerPage> {
  final List<Map<String, dynamic>> _injections = [];
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _planController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  int? _editingIndex;

  bool _isValidDate(String input) {
    try {
      DateFormat('MM/dd/yyyy').parseStrict(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _saveInjection() {
    if (!_isValidDate(_dateController.text)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Invalid Date'),
          content: Text('Please enter the date in MM/DD/YYYY format.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      final newInjection = {
        'date': _dateController.text,
        'medication': _medicationController.text,
        'plan': _planController.text,
        'notes': _notesController.text,
      };

      if (_editingIndex != null) {
        _injections[_editingIndex!] = newInjection;
        _editingIndex = null;
      } else {
        _injections.add(newInjection);
      }

      _dateController.clear();
      _medicationController.clear();
      _planController.clear();
      _notesController.clear();
    });
  }

  void _editInjection(int index) {
    setState(() {
      _dateController.text = _injections[index]['date'];
      _medicationController.text = _injections[index]['medication'];
      _planController.text = _injections[index]['plan'];
      _notesController.text = _injections[index]['notes'];
      _editingIndex = index;
    });
  }

  void _removeInjection(int index) {
    setState(() {
      _injections.removeAt(index);
    });
  }

  Widget _buildTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Medication')),
        DataColumn(label: Text('Plan')),
        DataColumn(label: Text('Notes')),
        DataColumn(label: Text('Actions')),
      ],
      rows: List<DataRow>.generate(
        _injections.length,
        (index) => DataRow(
          cells: [
            DataCell(Text(_injections[index]['date'])),
            DataCell(Text(_injections[index]['medication'])),
            DataCell(Text(_injections[index]['plan'])),
            DataCell(Text(_injections[index]['notes'])),
            DataCell(Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editInjection(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeInjection(index),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IVF Injection Tracker'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date (MM/DD/YYYY)',
                    hintText: 'e.g., 05/26/2024',
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                TextField(
                  controller: _medicationController,
                  decoration: InputDecoration(
                    labelText: 'Medication',
                    hintText: 'e.g., Follistim',
                  ),
                ),
                TextField(
                  controller: _planController,
                  decoration: InputDecoration(
                    labelText: 'Plan',
                    hintText: 'e.g., Daily injection at 8 AM',
                  ),
                ),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    hintText: 'e.g., Mild side effects noted',
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveInjection,
                  child: Text('Save Injection'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildTable(),
            ),
          ),
        ],
      ),
    );
  }
}
