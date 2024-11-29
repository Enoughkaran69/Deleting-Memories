import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoScanScreen extends StatefulWidget {
  final VoidCallback onPhotosDeleted;

  PhotoScanScreen({required this.onPhotosDeleted});

  @override
  _PhotoScanScreenState createState() => _PhotoScanScreenState();
}

class _PhotoScanScreenState extends State<PhotoScanScreen> {
  File? selectedImage;
  List<String> matchedPhotos = [];
  Map<String, String> sentFiles = {};
  bool isProcessing = false;

  final String pythonApiUrl = "http://10.0.2.2:5000";

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  Future<void> requestStoragePermission() async {
    final status = await Permission.manageExternalStorage.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage access is required to scan photos.')),
      );
    }
  }

  Future<void> selectImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        matchedPhotos.clear();
        sentFiles.clear();
        isProcessing = true;
      });
      await analyzeImage(selectedImage!);
    }
  }

  Future<void> analyzeImage(File targetImage) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$pythonApiUrl/upload_and_analyze'));
      request.files.add(await http.MultipartFile.fromPath('target_image', targetImage.path));

      final directoriesToScan = [
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Pictures',
      ];

      for (final directory in directoriesToScan) {
        final dir = Directory(directory);
        if (await dir.exists()) {
          await for (var entity in dir.list(recursive: true, followLinks: false)) {
            if (entity is File && (entity.path.endsWith('.jpg') || entity.path.endsWith('.png'))) {
              String filename = entity.path.split('/').last;
              sentFiles[filename] = entity.path;
              request.files.add(await http.MultipartFile.fromPath('gallery_images', entity.path));
            }
          }
        }
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        setState(() {
          matchedPhotos = List<String>.from(jsonResponse['matched_images']
              .map((url) => sentFiles[url.split('/').last])
              .where((path) => path != null));
          isProcessing = false;
        });
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error analyzing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing image. Please try again.')),
      );
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> deleteMatchedPhotos() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Memories'),
        content: Text('Are you sure you want to delete all matched photos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      int deletedCount = 0;

      for (final photoPath in matchedPhotos) {
        try {
          final file = File(photoPath);

          if (await file.exists()) {
            await file.delete();
            deletedCount++;
          } else {
            print('File not found: $photoPath');
          }
        } catch (e) {
          print('Error deleting file: $photoPath\n$e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting some files.')),
          );
        }
      }

      setState(() {
        matchedPhotos.clear();
      });

      widget.onPhotosDeleted(); // Notify ScanMemoriesScreen

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('✨ Memories Deleted'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You’ve taken a step forward! 🌟',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '"Every ending is a new beginning."',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Return to ScanMemoriesScreen
              },
              child: Text('Proceed to Next Steps'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
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
                  'Photo Scan',
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
          if (selectedImage == null)
            Center(
              child: ElevatedButton(
                onPressed: selectImage,
                child: Text('Select Image'),
              ),
            )
          else
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.file(selectedImage!, height: 200),
                    if (isProcessing)
                      CircularProgressIndicator(
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                isProcessing
                    ? Text(
                  'Scanning...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
                    : Text(
                  matchedPhotos.isEmpty
                      ? 'No matching photos found.'
                      : '${matchedPhotos.length} matching photo(s) found.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          if (matchedPhotos.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: matchedPhotos.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(matchedPhotos[index]), width: 50),
                      ),
                      title: Text('Matched Photo ${index + 1}'),
                    ),
                  );
                },
              ),
            )
          else if (isProcessing)
            const Center(child: CircularProgressIndicator()),
          Spacer(),
          if (matchedPhotos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: Icon(Icons.delete_forever, color: Colors.white),
                label: Text(
                  'Delete Memories',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: deleteMatchedPhotos,
              ),
            ),
        ],
      ),
    );
  }
}
