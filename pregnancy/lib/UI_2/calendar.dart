import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const CalendarScreen(),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFfdebeb),
      ),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<DateTime, List<Map<String, dynamic>>> _notes = {};
  Set<DateTime> _noteDates = {};
  bool _loadingNotes = true;
  Set<DateTime> _ovulationDates = {};
  Set<DateTime> _periodDates = {};
  DateTime? _lastPeriodStartDate;
  int _cycleLength = 28;
  int _lutealPhaseLength = 14;
  int _periodLength = 6; // average period length
  int _fertileWindowLength = 6; // fertile window length including ovulation day

  @override
  void initState() {
    super.initState();
    _loadCycleInfo();
    _loadNotes();
  }

  Future<void> _loadCycleInfo() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot cycleDoc = await _firestore.collection('user_accounts').doc(user.uid).collection('cycle_info').doc('data').get();
        if (cycleDoc.exists) {
          setState(() {
            _lastPeriodStartDate = (cycleDoc['lastPeriodStartDate'] as Timestamp?)?.toDate();
            _cycleLength = cycleDoc['cycleLength'] ?? 28;
            _lutealPhaseLength = cycleDoc['lutealPhaseLength'] ?? 14;
            _calculateFutureDates();
          });
        }
      } catch (e) {
        print("Failed to load cycle info: $e");
      }
    }
  }

  Future<void> _loadNotes() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot notesSnapshot = await _firestore
            .collection('user_accounts')
            .doc(user.uid)
            .collection('notes')
            .get();

        QuerySnapshot apptSnapshot = await _firestore
            .collection('user_accounts')
            .doc(user.uid)
            .collection('appt_info')
            .get();

        Map<DateTime, List<Map<String, dynamic>>> loadedNotes = {};
        Set<DateTime> noteDates = {};

        for (var doc in notesSnapshot.docs) {
          DateTime date = (doc['timestamp'] as Timestamp).toDate();
          Map<String, dynamic> note = {
            'id': doc.id,
            'title': doc['title'],
            'content': doc['content'],
          };

          DateTime dateOnly = DateTime(date.year, date.month, date.day);
          if (loadedNotes[dateOnly] == null) {
            loadedNotes[dateOnly] = [];
          }
          loadedNotes[dateOnly]!.add(note);
          noteDates.add(dateOnly);

          if (note['title'].toLowerCase().contains('ovulation')) {
            _ovulationDates.add(dateOnly);
          }
          if (note['title'].toLowerCase().contains('period')) {
            _periodDates.add(dateOnly);
          }
        }

        for (var doc in apptSnapshot.docs) {
          DateTime date;
          try {
            date = DateFormat('d/M/yyyy').parse(doc['Date']);
          } catch (e) {
            date = DateTime.parse(doc['Date']);
          }
          Map<String, dynamic> appt = {
            'id': doc.id,
            'title': 'Appointment with Dr. ${doc['Doctor Name']}',
            'content': 'Time: ${doc['Time']}',
          };

          DateTime dateOnly = DateTime(date.year, date.month, date.day);
          if (loadedNotes[dateOnly] == null) {
            loadedNotes[dateOnly] = [];
          }
          loadedNotes[dateOnly]!.add(appt);
          noteDates.add(dateOnly);
        }

        setState(() {
          _notes = loadedNotes;
          _noteDates = noteDates;
          _loadingNotes = false;
        });
      } catch (e) {
        print("Failed to load notes: $e");
        setState(() {
          _loadingNotes = false;
        });
      }
    }
  }

  Future<void> _saveCycleInfo() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('user_accounts').doc(user.uid).collection('cycle_info').doc('data').set({
          'lastPeriodStartDate': _lastPeriodStartDate != null ? Timestamp.fromDate(_lastPeriodStartDate!) : null,
          'cycleLength': _cycleLength,
          'lutealPhaseLength': _lutealPhaseLength,
        }, SetOptions(merge: true));
      } catch (e) {
        print("Failed to save cycle info: $e");
      }
    }
  }

  Future<void> _saveNote(String title, String content) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('user_accounts')
            .doc(user.uid)
            .collection('notes')
            .add({
          'title': title,
          'content': content,
          'timestamp': Timestamp.fromDate(_selectedDay),
        });

        DateTime dateOnly = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
        setState(() {
          if (_notes[dateOnly] == null) {
            _notes[dateOnly] = [];
          }
          _notes[dateOnly]!.add({'title': title, 'content': content});
          _noteDates.add(dateOnly);

          if (title.toLowerCase().contains('ovulation')) {
            _ovulationDates.add(dateOnly);
          }
          if (title.toLowerCase().contains('period')) {
            _periodDates.add(dateOnly);
          }
        });
      } catch (e) {
        print("Failed to save note: $e");
      }
    }
  }

  Future<void> _deleteNote(String noteId, DateTime dateOnly) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('user_accounts')
            .doc(user.uid)
            .collection('notes')
            .doc(noteId)
            .delete();

        setState(() {
          _notes[dateOnly]?.removeWhere((note) => note['id'] == noteId);
          if (_notes[dateOnly]?.isEmpty ?? true) {
            _notes.remove(dateOnly);
            _noteDates.remove(dateOnly);
            _ovulationDates.remove(dateOnly);
            _periodDates.remove(dateOnly);
          }
        });
      } catch (e) {
        print("Failed to delete note: $e");
      }
    }
  }

  void _calculateFutureDates() {
    if (_lastPeriodStartDate != null) {
      _periodDates.clear();
      _ovulationDates.clear();
      DateTime date = _lastPeriodStartDate!;
      for (int i = 0; i < 12; i++) {
        // Add period dates
        for (int j = 0; j < _periodLength; j++) {
          _periodDates.add(date.add(Duration(days: j)));
        }
        // Add ovulation dates (fertile window)
        DateTime ovulationStartDate = date.add(Duration(days: _cycleLength - _lutealPhaseLength - (_fertileWindowLength - 1)));
        for (int j = 0; j < _fertileWindowLength; j++) {
          _ovulationDates.add(ovulationStartDate.add(Duration(days: j)));
        }
        date = date.add(Duration(days: _cycleLength));
      }
      setState(() {});
    }
  }

  void _showCycleSettingsDialog() {
    TextEditingController cycleLengthController = TextEditingController(text: _cycleLength.toString());
    TextEditingController lutealPhaseController = TextEditingController(text: _lutealPhaseLength.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cycle Settings"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cycleLengthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Cycle Length (days)"),
              ),
              TextField(
                controller: lutealPhaseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Luteal Phase Length (days)"),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () {
                setState(() {
                  _cycleLength = int.tryParse(cycleLengthController.text) ?? 28;
                  _lutealPhaseLength = int.tryParse(lutealPhaseController.text) ?? 14;
                  _calculateFutureDates();
                  _saveCycleInfo();
                });
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _lastPeriodStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _lastPeriodStartDate) {
      setState(() {
        _lastPeriodStartDate = pickedDate;
        _calculateFutureDates();
        _saveCycleInfo();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showCycleSettingsDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _showDatePicker,
              child: const Text('Select Last Period Start Date'),
            ),
          ),
          if (_lastPeriodStartDate != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Last Period Start Date: ${DateFormat.yMMMd().format(_lastPeriodStartDate!)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                DateTime dateOnly = DateTime(date.year, date.month, date.day);
                if (_noteDates.contains(dateOnly) || _ovulationDates.contains(dateOnly) || _periodDates.contains(dateOnly)) {
                  Color markerColor;
                  if (_ovulationDates.contains(dateOnly)) {
                    markerColor = Colors.blue;
                  } else if (_periodDates.contains(dateOnly)) {
                    markerColor = Colors.red;
                  } else {
                    markerColor = Colors.black;
                  }
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: markerColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.blue, "Ovulation Dates"),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.red, "Period Dates"),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.black, "Other Notes"),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loadingNotes
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      _buildExpandableTile(context, 'Pregnancy Symptoms'),
                      _buildExpandableTile(context, 'Weight'),
                      _buildExpandableTile(context, 'Activity'),
                      _buildExpandableTile(context, 'Appointments'),
                      _buildExpandableTile(context, 'Medication'),
                      const SizedBox(height: 16),
                      _buildNotesSection(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildExpandableTile(BuildContext context, String title) {
    return ExpansionTile(
      title: Text(title),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              _showDialog(context, title);
            },
            child: Text('Add $title'),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    DateTime dateOnly = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Notes for Selected Date',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (_notes[dateOnly] != null && _notes[dateOnly]!.isNotEmpty)
          ..._notes[dateOnly]!.map((note) => ListTile(
                title: Text(note['title']),
                subtitle: Text(note['content']),
                trailing: note.containsKey('id')
                    ? IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteNote(note['id'], dateOnly);
                        },
                      )
                    : null,
              ))
        else
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No notes for this date'),
          ),
      ],
    );
  }

  void _showDialog(BuildContext context, String title) {
    TextEditingController noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: noteController,
            decoration: InputDecoration(hintText: "Enter $title"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () {
                _saveNote(title, noteController.text);
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
