import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:share_plus/share_plus.dart';

class FullScreenWallpaper extends StatefulWidget {
  final String imagePath;

  FullScreenWallpaper({required this.imagePath});

  @override
  _FullScreenWallpaperState createState() => _FullScreenWallpaperState();
}

class _FullScreenWallpaperState extends State<FullScreenWallpaper> {
  String? wallpaperName;
  String? wallpaperSize;
  String? imageUrl;
  int likesCount = 0;
  bool isLiked = false;
  bool isLoading = true;
  bool isPremium = false; // Flag for premium wallpapers
  String? wallpaperKey;

  @override
  void initState() {
    super.initState();
    _fetchWallpaperDetails();
  }

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
            wallpaperKey = key;
            wallpaperName = value['name'] ?? 'No Name';
            isPremium = value['isPremium'] ?? false; // Check premium status
            likesCount = value['likes'] ?? 0;

            final storageRef =
                FirebaseStorage.instance.refFromURL(value['imageUrl']);
            imageUrl = await storageRef.getDownloadURL();

            final metadata = await storageRef.getMetadata();
            wallpaperSize = _formatFileSize(metadata.size ?? 0);

            _checkUserLikeStatus();

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

  void _checkUserLikeStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && wallpaperKey != null) {
      DatabaseReference likesRef = FirebaseDatabase.instance
          .ref()
          .child('wallpapers')
          .child(wallpaperKey!)
          .child('likedBy');

      final snapshot = await likesRef.child(user.uid).get();
      setState(() {
        isLiked = snapshot.exists;
      });
    }
  }

  Future<void> _handleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to like wallpapers')),
      );
      return;
    }

    try {
      DatabaseReference wallpaperRef = FirebaseDatabase.instance
          .ref()
          .child('wallpapers')
          .child(wallpaperKey!);

      DatabaseReference likesRef =
          wallpaperRef.child('likedBy').child(user.uid);

      if (isLiked) {
        await likesRef.remove();
        await wallpaperRef
            .update({'likes': (likesCount - 1).clamp(0, double.infinity)});
        setState(() {
          isLiked = false;
          likesCount = (likesCount - 1).clamp(0, double.infinity).toInt();
        });
      } else {
        await likesRef.set(true);
        await wallpaperRef.update({'likes': likesCount + 1});
        setState(() {
          isLiked = true;
          likesCount += 1;
        });
      }
    } catch (e) {
      print("Error updating like count: $e");
    }
  }

  Future<void> _handleDownload(BuildContext context, String imageUrl) async {
    if (isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('This is a premium wallpaper. Download not allowed.')),
      );
      return;
    }

    if (Platform.isAndroid) {
      if (await Permission.mediaLibrary.request().isDenied ||
          await Permission.manageExternalStorage.request().isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }
    }

    try {
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      final data = await storageRef.getData();

      if (data == null) {
        throw Exception("Failed to download file.");
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Pictures');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      String filePath =
          '${directory.path}/wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File file = File(filePath);
      await file.writeAsBytes(data);

      if (Platform.isAndroid) {
        try {
          final String? scannedFilePath =
              await MediaScanner.loadMedia(path: filePath);
          print(scannedFilePath != null
              ? 'File scanned: $scannedFilePath'
              : 'Failed to scan file');
        } catch (e) {
          print('Error notifying media scanner: $e');
        }
      }

      // ✅ **Increment the download count in Firebase**
      if (wallpaperKey != null) {
        DatabaseReference wallpaperRef = FirebaseDatabase.instance
            .ref()
            .child('wallpapers')
            .child(wallpaperKey!);

        final snapshot = await wallpaperRef.child('downloads').get();
        int currentDownloads = snapshot.exists ? snapshot.value as int : 0;

        await wallpaperRef.update({'downloads': currentDownloads + 1});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wallpaper downloaded to Pictures folder')),
      );

      print('File saved at: $filePath');
    } catch (e) {
      print('Error downloading wallpaper: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download wallpaper')),
      );
    }
  }

  void _handleShare() async {
    if (imageUrl != null) {
      await Share.share(
        'Check out this awesome wallpaper: $imageUrl',
        subject: 'Awesome Wallpaper!',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to share wallpaper')),
      );
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
                Positioned.fill(
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
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
                Positioned(
                  right: 16,
                  bottom: 60,
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: Colors.white,
                        ),
                        onPressed: _handleLike,
                      ),
                      Text('$likesCount',
                          style: TextStyle(color: Colors.white)),
                      SizedBox(height: 16),
                      IconButton(
                        icon: Icon(Icons.share, color: Colors.white),
                        onPressed: _handleShare,
                      ),
                      SizedBox(height: 16),
                      IconButton(
                        icon: Icon(Icons.download, color: Colors.white),
                        onPressed: () => _handleDownload(context, imageUrl!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
