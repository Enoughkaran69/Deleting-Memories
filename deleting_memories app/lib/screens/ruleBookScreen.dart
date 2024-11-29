import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class RuleBookScreen extends StatefulWidget {
  @override
  _RuleBookScreenState createState() => _RuleBookScreenState();
}

class _RuleBookScreenState extends State<RuleBookScreen> {
  final TextEditingController _noteController = TextEditingController();
  List<String> _notes = [];
  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _initializeNotifications();
    tz.initializeTimeZones();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleReminder(String note, int index, TimeOfDay time, List<bool> selectedDays) async {
    for (int i = 0; i < 7; i++) {
      if (selectedDays[i]) {
        await _notificationsPlugin.zonedSchedule(
          index * 7 + i, // Unique ID for each day
          'Life Note Reminder',
          note,
          _nextInstanceOfTime(i, time),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'rulebook_channel',
              'Rulebook Reminders',
              channelDescription: 'Reminders for life notes',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exact,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminders set for "$note"')),
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int day, TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    while (scheduledDate.weekday != day + 1 || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes = prefs.getStringList('notes') ?? [];
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notes', _notes);
  }

  void _addNote() {
    if (_noteController.text.isNotEmpty) {
      setState(() {
        _notes.add(_noteController.text);
        _noteController.clear();
        _saveNotes();
      });
    }
  }

  void _deleteNoteAtIndex(int index) {
    setState(() {
      _notes.removeAt(index);
      _saveNotes();
    });
  }

  void _showReminderDialog(String note, int index) {
    final List<bool> selectedDays = List.generate(7, (index) => false);
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Set Reminder'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Select Days:', style: GoogleFonts.poppins(fontSize: 16)),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (i) {
                      return FilterChip(
                        label: Text(
                          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
                          style: TextStyle(color: Colors.white),
                        ),
                        selected: selectedDays[i],
                        onSelected: (isSelected) {
                          setDialogState(() {
                            selectedDays[i] = isSelected;
                          });
                        },
                        selectedColor: Colors.blueAccent,
                        backgroundColor: Colors.grey,
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text('Select Time:', style: GoogleFonts.poppins(fontSize: 16)),
                  ElevatedButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setDialogState(() {
                          selectedTime = time;
                        });
                      }
                    },
                    child: Text(
                      'Pick Time: ${selectedTime.format(context)}',
                      style: GoogleFonts.openSans(fontSize: 16),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: GoogleFonts.poppins(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () {
                    _scheduleReminder(note, index, selectedTime, selectedDays);
                    Navigator.pop(context);
                  },
                  child: Text('Set Reminder', style: GoogleFonts.poppins(fontSize: 16)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 60,
                    width: 60,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'deleting memories.',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'RFRostin-Regular',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blueAccent),
              title: Text('Home', style: GoogleFonts.poppins(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.blueAccent),
              title: Text('About', style: GoogleFonts.poppins(fontSize: 16)),
              onTap: () {
                // Add navigation or actions for About
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context); // Open the Drawer
                        },
                      );
                    },
                  ),
                  Image.asset(
                    'assets/logo.png',
                    height: 40,
                    width: 40,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Your Life Rule Book',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'RFRostin-Regular',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            TextField(
              controller: _noteController,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: 'Write a life rule...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                contentPadding: const EdgeInsets.all(16.0),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add, color: Colors.blueAccent),
                  onPressed: _addNote,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _notes.isEmpty
                  ? Center(
                child: Text(
                  'No notes yet. Add a new rule to get started!',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        _notes[index],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.alarm, color: Colors.blueAccent),
                            onPressed: () => _showReminderDialog(_notes[index], index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteNoteAtIndex(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
