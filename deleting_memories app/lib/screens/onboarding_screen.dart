import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool showGetStartedButton = false; // Flag to show the button

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Start the fade-in animation
    _fadeController.forward();

    // Wait for the typing animation to finish, then show the button
    Future.delayed(Duration(seconds: 4), () {
      setState(() {
        showGetStartedButton = true;
      });
    });
  }

  Future<void> _completeOnboarding() async {
    // Save a flag to indicate that onboarding has been completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);

    // Navigate to the home page
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Center Logo and Typing Animation
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Fade-in Logo
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    'assets/logo.png',
                    height: 100,
                    width: 100,
                  ),
                ),
                const SizedBox(width: 20),
                // Typing Animation for App Name
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'RFRostin-Regular',
                    color: Colors.black,
                  ),
                  child: AnimatedTextKit(
                    isRepeatingAnimation: false,
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'deleting memories. ',
                        cursor: '|',
                        speed: Duration(milliseconds: 100),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer Section
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Made with 💔 by Developer Rahul',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'RFRostin-Regular',
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Get Started Button
          if (showGetStartedButton)
            Positioned(
              bottom: 250,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: _completeOnboarding, // Mark onboarding as completed
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'RFRostin-Regular',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
