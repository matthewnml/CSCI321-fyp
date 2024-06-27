import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        scaffoldBackgroundColor: const Color(0xFFfdebeb), // Set your desired background color here
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

  @override
  void initState() {
    super.initState();
    _loadNotes();
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
          }
        });
      } catch (e) {
        print("Failed to delete note: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
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
                _focusedDay = focusedDay; // update `_focusedDay` here as well
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
                if (_noteDates.contains(DateTime(date.year, date.month, date.day))) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
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
          Expanded(
            child: _loadingNotes
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      _buildExpandableTile(context, 'Pregnancy Symptoms'),
                      _buildExpandableTile(context, 'Weight'),
                      _buildExpandableTile(context, 'Activity'),
                      _buildExpandableTile(context, 'Fetal Movement'),
                      _buildExpandableTile(context, 'Kegels'),
                      const SizedBox(height: 16),
                      _buildNotesSection(),
                    ],
                  ),
          ),
        ],
      ),
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
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteNote(note['id'], dateOnly);
                  },
                ),
              )).toList()
        else
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No notes for this date'),
          ),
      ],
    );
  }

  void _showDialog(BuildContext context, String title) {
    TextEditingController _noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _noteController,
            decoration: InputDecoration(hintText: "Enter $title"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () {
                _saveNote(title, _noteController.text);
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
