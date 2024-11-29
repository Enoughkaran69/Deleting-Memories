import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class MotivationsScreen extends StatefulWidget {
  @override
  _MotivationsScreenState createState() => _MotivationsScreenState();
}

class _MotivationsScreenState extends State<MotivationsScreen> {
  final List<String> videoPaths = [
    'assets/videos/video1.mp4',
    'assets/videos/video2.mp4',
    'assets/videos/video3.mp4',
  ];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      backgroundColor: Colors.white,
      body: Column(
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
                  'Motivations',
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
          // Video List Section
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  scrollDirection: Axis.vertical,
                  controller: _pageController,
                  itemCount: videoPaths.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.fromLTRB(50.0,0.0,50.0,150.0),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: MotivationVideoPlayer(videoPath: videoPaths[index]),
                      ),
                    );
                  },
                ),
                // Swipe Up for More Inspiration Text
                Positioned(
                  bottom: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.keyboard_arrow_up, color: Colors.black, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Swipe up for more inspiration',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MotivationVideoPlayer extends StatefulWidget {
  final String videoPath;

  MotivationVideoPlayer({required this.videoPath});

  @override
  _MotivationVideoPlayerState createState() => _MotivationVideoPlayerState();
}

class _MotivationVideoPlayerState extends State<MotivationVideoPlayer> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {}); // Refresh UI once video is initialized
        _videoController.play(); // Auto-play video
        _videoController.setLooping(true); // Loop video
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _videoController.value.isInitialized
            ? AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: VideoPlayer(_videoController),
        )
            : CircularProgressIndicator(
          color: Colors.white,
        ),
        // Play/Pause Overlay
        GestureDetector(
          onTap: () {
            setState(() {
              _videoController.value.isPlaying
                  ? _videoController.pause()
                  : _videoController.play();
            });
          },
          child: _videoController.value.isPlaying
              ? SizedBox.shrink()
              : Icon(
            Icons.play_arrow,
            size: 80,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
