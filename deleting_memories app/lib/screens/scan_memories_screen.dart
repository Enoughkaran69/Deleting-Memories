import 'package:deleting_memories/screens/photo_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanMemoriesScreen extends StatefulWidget {
  @override
  _ScanMemoriesScreenState createState() => _ScanMemoriesScreenState();
}

class _ScanMemoriesScreenState extends State<ScanMemoriesScreen> {
  List<bool> stepsCompleted = [false, false, false]; // Tracks the completion of each step

  @override
  void initState() {
    super.initState();
    _loadStepsState(); // Load saved steps state on initialization
  }

  // Load saved steps state from SharedPreferences
  Future<void> _loadStepsState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < stepsCompleted.length; i++) {
        stepsCompleted[i] = prefs.getBool('step_$i') ?? false;
      }
    });
  }

  // Save the state of a completed step in SharedPreferences
  Future<void> _saveStepState(int stepIndex, bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('step_$stepIndex', completed);

    // Save completion time if all steps are completed
    if (stepsCompleted.every((step) => step)) {
      prefs.setString('completion_time', DateTime.now().toIso8601String());
    }
  }

  // Mark a step as completed
  void markStepCompleted(int stepIndex) {
    setState(() {
      stepsCompleted[stepIndex] = true;
    });
    _saveStepState(stepIndex, true); // Save the completed state
  }

  bool get allStepsCompleted => stepsCompleted.every((step) => step);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                Navigator.pushNamed(context, '/'); // Navigate to HomeScreen
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
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
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
                        Scaffold.of(context).openDrawer(); // Open Drawer
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
                  'Scan Memories',
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
          Text("Only Select when you have completed the steps 💔."),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  _buildStep(
                    context,
                    stepIndex: 0,
                    title: 'Step 1: Scan Photos',
                    description:
                    'Upload a photo of your ex, and we will identify and suggest related photos to delete.',
                    isCompleted: stepsCompleted[0],
                    onCompleted: () {
                      if (!stepsCompleted[0]) {
                        // Navigate to PhotoScanScreen only if Step 1 is not completed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotoScanScreen(
                              onPhotosDeleted: () => markStepCompleted(0),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  _buildStep(
                    context,
                    stepIndex: 1,
                    title: 'Step 2: Delete Chats',
                    description: 'Manually delete chats with your ex from messaging apps like WhatsApp and SMS.',
                    isCompleted: stepsCompleted[1],
                    onCompleted: () => markStepCompleted(1),
                  ),
                  _buildStep(
                    context,
                    stepIndex: 2,
                    title: 'Step 3: Block on Social Media',
                    description: 'Blocking your ex on social media can help you move on. Complete this step manually.',
                    isCompleted: stepsCompleted[2],
                    onCompleted: () => markStepCompleted(2),
                  ),
                ],
              ),
            ),
          ),
          if (allStepsCompleted)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: Icon(Icons.done, color: Colors.white),
                  label: Text(
                    'Well Done! Back to Home',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep(
      BuildContext context, {
        required int stepIndex,
        required String title,
        required String description,
        required bool isCompleted,
        required VoidCallback onCompleted,
      }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListTile(
          leading: Checkbox(
            value: isCompleted,
            onChanged: stepIndex == 0 || stepsCompleted[stepIndex - 1]
                ? (value) => onCompleted()
                : null, // Disable if the previous step is not completed
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isCompleted ? Colors.green : Colors.blueAccent,
            ),
          ),
          subtitle: Text(
            description,
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          trailing: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey,
          ),
        ),
      ),
    );
  }
}
