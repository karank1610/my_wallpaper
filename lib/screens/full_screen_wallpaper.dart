import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FullScreenWallpaper extends StatefulWidget {
  final String imagePath; // The image URL passed as an argument

  FullScreenWallpaper({required this.imagePath});

  @override
  _FullScreenWallpaperState createState() => _FullScreenWallpaperState();
}

class _FullScreenWallpaperState extends State<FullScreenWallpaper> {
  String? wallpaperName;
  String? wallpaperSize;
  String? imageUrl;
  int? likesCount;
  int? commentsCount;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWallpaperDetails();
  }

  // Fetch wallpaper details from Firebase
  Future<void> _fetchWallpaperDetails() async {
    try {
      DatabaseReference wallpaperRef =
          FirebaseDatabase.instance.ref().child('wallpapers');

      final snapshot = await wallpaperRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> wallpapersData =
            snapshot.value as Map<dynamic, dynamic>;

        wallpapersData.forEach((key, value) async {
          if (value['imageUrl'] == widget.imagePath) {
            setState(() {
              wallpaperName = value['name'] ?? 'No Name';
              likesCount = value['likes'] ?? 0;
              commentsCount = value['comments'] ?? 0;
            });

            final storageRef =
                FirebaseStorage.instance.refFromURL(value['imageUrl']);
            imageUrl = await storageRef.getDownloadURL();

            final metadata = await storageRef.getMetadata();
            wallpaperSize = _formatFileSize(metadata.size ?? 0);

            setState(() {
              isLoading = false;
            });
          }
        });
      } else {
        print("No wallpapers found.");
      }
    } catch (e) {
      print('Error fetching wallpaper details: $e');
    }
  }

  String _formatFileSize(int sizeInBytes) {
    double sizeInKB = sizeInBytes / 1024;
    if (sizeInKB < 1024) {
      return '${sizeInKB.toStringAsFixed(2)} KB';
    } else {
      double sizeInMB = sizeInKB / 1024;
      return '${sizeInMB.toStringAsFixed(2)} MB';
    }
  }

  Future<void> _handleDownload() async {
    // Check and request storage permission
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        // Get the directory to save the wallpaper
        Directory? appDocDir =
            await getApplicationDocumentsDirectory(); // Get the correct directory
        String filePath =
            '${appDocDir.path}/wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Create a reference to the storage file
        final storageRef = FirebaseStorage.instance.refFromURL(imageUrl!);

        // Download the file data from Firebase Storage
        final data = await storageRef.getData();

        // Save the downloaded data to a file
        if (data != null) {
          final file = File(filePath);
          await file.writeAsBytes(data);

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Wallpaper downloaded successfully')));
        } else {
          throw Exception("Failed to download file.");
        }
      } catch (e) {
        print('Error downloading wallpaper: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to download wallpaper')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Storage permission denied')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Full-screen wallpaper
                Positioned.fill(
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
                // Icons and details overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wallpaperName ?? 'No Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Size: ${wallpaperSize ?? 'Unknown Size'}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Action icons (Like, Share, Download)
                Positioned(
                  right: 16,
                  bottom: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.thumb_up, color: Colors.white),
                        onPressed: () {},
                      ),
                      Text(
                        '${likesCount ?? 0}',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      IconButton(
                        icon: Icon(Icons.comment, color: Colors.white),
                        onPressed: () {},
                      ),
                      Text(
                        '${commentsCount ?? 0}',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      IconButton(
                        icon: Icon(Icons.share, color: Colors.white),
                        onPressed: () {},
                      ),
                      SizedBox(height: 16),
                      IconButton(
                        icon: Icon(Icons.download, color: Colors.white),
                        onPressed: _handleDownload,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
