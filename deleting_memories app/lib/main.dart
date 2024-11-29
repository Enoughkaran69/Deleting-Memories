import 'package:deleting_memories/screens/motivation.dart';
import 'package:deleting_memories/screens/ruleBookScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/scan_memories_screen.dart';
import 'screens/photo_scan_screen.dart';
import 'screens/scan_results_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => InitialScreen(),
        '/home': (context) => HomeScreen(),
        '/scan': (context) => ScanMemoriesScreen(),
        '/motivation': (context) => MotivationsScreen(),
        '/rules': (context) => RuleBookScreen(),
        '/scanResults': (context) => ScanResultsScreen(),
        '/scanPhotos': (context) => PhotoScanScreen(
          onPhotosDeleted: () {},
        ),
      },
    );
  }
}

class InitialScreen extends StatelessWidget {
  Future<bool> _isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboardingCompleted') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isOnboardingCompleted(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == true) {
          // Onboarding completed, navigate to home screen
          return HomeScreen();
        } else {
          // Onboarding not completed, navigate to onboarding screen
          return OnboardingScreen();
        }
      },
    );
  }
}
