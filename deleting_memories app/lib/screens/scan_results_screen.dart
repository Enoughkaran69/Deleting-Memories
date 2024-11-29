import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanResultsScreen extends StatefulWidget {
  @override
  _ScanResultsScreenState createState() => _ScanResultsScreenState();
}

class _ScanResultsScreenState extends State<ScanResultsScreen> {
  // Mock data for results
  final List<Map<String, dynamic>> photos = [
    {'name': 'Photo 1', 'selected': false},
    {'name': 'Photo 2', 'selected': false},
    {'name': 'Photo 3', 'selected': false},
  ];

  final List<Map<String, dynamic>> chats = [
    {'name': 'Chat with John', 'selected': false},
    {'name': 'Chat with Ex', 'selected': false},
  ];

  final List<Map<String, dynamic>> socialMedia = [
    {'name': 'Instagram Post', 'selected': false},
    {'name': 'Facebook Comment', 'selected': false},
  ];

  void toggleSelection(List<Map<String, dynamic>> category, int index) {
    setState(() {
      category[index]['selected'] = !category[index]['selected'];
    });
  }

  void deleteSelectedItems() {
    // Example logic to handle deletion
    setState(() {
      photos.removeWhere((item) => item['selected']);
      chats.removeWhere((item) => item['selected']);
      socialMedia.removeWhere((item) => item['selected']);
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected items have been deleted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Scan Results',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos Section
            _buildCategorySection('Photos', photos),
            const SizedBox(height: 20),

            // Chats Section
            _buildCategorySection('Chats', chats),
            const SizedBox(height: 20),

            // Social Media Section
            _buildCategorySection('Social Media', socialMedia),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: deleteSelectedItems,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Delete Selected',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => toggleSelection(items, index),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: item['selected']
                        ? Colors.blueAccent.withOpacity(0.2)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item['selected']
                          ? Colors.blueAccent
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item['name'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
