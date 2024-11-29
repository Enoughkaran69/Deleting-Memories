import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool allStepsCompleted = false; // Tracks if all steps are completed
  DateTime? completionTime; // Stores the time when all steps were completed
  String elapsedTime = '00:00:00'; // Formatted elapsed time
  Timer? timer; // Timer for updating elapsed time
  late AnimationController _logoController; // Animation controller for beating logo

  @override
  void initState() {
    super.initState();
    _checkAllStepsCompleted(); // Check if all steps are completed

    // Initialize animation controller for beating logo
    _logoController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Beat every second
      lowerBound: 0.9,
      upperBound: 1.0,
    )..repeat(reverse: true); // Repeat animation in reverse
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel timer on dispose
    _logoController.dispose(); // Dispose animation controller
    super.dispose();
  }

  // Check if all steps are completed from SharedPreferences
  Future<void> _checkAllStepsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    bool completed = true;
    for (int i = 0; i < 3; i++) {
      if (!(prefs.getBool('step_$i') ?? false)) {
        completed = false;
        break;
      }
    }

    // Get the completion time if all steps are completed
    String? storedTime = prefs.getString('completion_time');
    if (completed && storedTime != null) {
      completionTime = DateTime.parse(storedTime);
      _startTimer(); // Start updating elapsed time
    }

    setState(() {
      allStepsCompleted = completed;
    });
  }

  // Start the timer to update elapsed time every second
  void _startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTime = _calculateElapsedTime();
      });
    });
  }

  // Calculate elapsed time in a human-readable format
  String _calculateElapsedTime() {
    if (completionTime == null) return '00:00:00';
    final now = DateTime.now();
    final difference = now.difference(completionTime!);

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:' +
        '${minutes.toString().padLeft(2, '0')}:' +
        '${seconds.toString().padLeft(2, '0')}';
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with Hamburger Icon, Logo, and Text
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
                      icon: const Icon(Icons.menu, color: Colors.black),
                      onPressed: () {
                        Scaffold.of(context).openDrawer(); // Open the Drawer
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
                  'deleting memories.',
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Timer and Beating Logo Section
                  if (allStepsCompleted)
                    Column(
                      children: [
                        Text(
                          'Time since we deleted memories:',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          elapsedTime,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ScaleTransition(
                          scale: _logoController,
                          child: Image.asset(
                            'assets/logo.png',
                            height: 150,
                            width: 150,
                          ),
                        ),
                      ],
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/scan'); // Navigate to Scan Memories
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/icons/scan2.png',
                              height: 300,
                              width: 300,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Scan Memories',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Motivational Quote
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '"The first step to moving on is letting go."',
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.blueAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Memory Vault and Digital Detox Tools in 2x2 Grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      itemCount: features.length,
                      itemBuilder: (context, index) {
                        final feature = features[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, feature['route']!);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  feature['icon']!,
                                  height: 50,
                                  width: 50,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  feature['title']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  feature['description']!,
                                  style: GoogleFonts.openSans(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
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
          ),
        ],
      ),
    );
  }

  final List<Map<String, String>> features = [
    {
      'title': 'Memory Vault',
      'description': 'Store memories for later consideration.',
      'icon': 'assets/icons/vault.png',
      'route': '/vault',
    },
    {
      'title': 'Digital Detox Tools',
      'description': 'Mindfulness tools and app blockers.',
      'icon': 'assets/icons/detox.png',
      'route': '/detox',
    },
    {
      'title': 'Life Rule Book',
      'description': 'Guidelines for a better life.',
      'icon': 'assets/icons/book.png',
      'route': '/rules',
    },
    {
      'title': 'Motivations',
      'description': 'Daily inspiration and positivity.',
      'icon': 'assets/icons/motivation.png',
      'route': '/motivation',
    },
  ];
}
