import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:my_wallpaper/screens/rewarded_ad_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';

class FullScreenWallpaper extends StatefulWidget {
  final String imagePath;

  FullScreenWallpaper({required this.imagePath});

  @override
  _FullScreenWallpaperState createState() => _FullScreenWallpaperState();
}

class _FullScreenWallpaperState extends State<FullScreenWallpaper> {
  final RewardedAdHelper adHelper = RewardedAdHelper();
  String? wallpaperName;
  String? wallpaperSize;
  String? imageUrl;
  int likesCount = 0;
  bool isLiked = false;
  bool isLoading = true;
  bool isPremium = false; // Flag for premium wallpapers
  String? wallpaperKey;
  int userCredits = 0;
  bool isUploadedByUser = false;

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: "ca-app-pub-3940256099942544/5224354917",
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          print('Failed to load a rewarded ad: $error');
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    adHelper.loadRewardedAd();
    Future.delayed(const Duration(seconds: 3), () {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && adHelper.shouldShowAd() && adHelper.isAdLoaded) {
        adHelper.showRewardedAd(context);
      }
    });
    _loadRewardedAd();
    _fetchUserCredits(); // Ensure credits are fetched at startup
    _fetchWallpaperDetails();
  }

  Future<void> _fetchUserCredits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data()!.containsKey('credits')) {
          setState(() {
            userCredits = userDoc['credits'];
          });
        } else {
          setState(() {
            userCredits = 0; // Default to 0 if credits field is missing
          });
        }
      } catch (e) {
        print("Error fetching user credits: $e");
      }
    }
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
            isPremium = value['isPremium'] ?? false;
            likesCount = value['likes'] ?? 0;
            String uploadedBy = value['uploadedBy'] ?? "";

            final storageRef =
                FirebaseStorage.instance.refFromURL(value['imageUrl']);
            imageUrl = await storageRef.getDownloadURL();

            final metadata = await storageRef.getMetadata();
            wallpaperSize = _formatFileSize(metadata.size ?? 0);

            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              isUploadedByUser = user.uid == uploadedBy;

              await _fetchUserCredits(); // Fetch credits for logged-in user
            }

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

      final wallpaperSnapshot = await wallpaperRef.get();
      if (!wallpaperSnapshot.exists) return;

      // Extract wallpaper data
      Map<dynamic, dynamic>? wallpaperData =
          wallpaperSnapshot.value as Map<dynamic, dynamic>?;

      String? uploadedBy = wallpaperData?['uploadedBy'];

      if (isLiked) {
        // Unlike the wallpaper
        await likesRef.remove();
        await wallpaperRef
            .update({'likes': (likesCount - 1).clamp(0, double.infinity)});
        setState(() {
          isLiked = false;
          likesCount = (likesCount - 1).clamp(0, double.infinity).toInt();
        });
      } else {
        // Like the wallpaper
        await likesRef.set(true);
        await wallpaperRef.update({'likes': likesCount + 1});
        setState(() {
          isLiked = true;
          likesCount += 1;
        });

        // Send notification if the wallpaper is not the user's own
        if (uploadedBy != null && uploadedBy != user.uid) {
          await _sendLikeNotification(
              uploadedBy, wallpaperData?['name'], wallpaperData?['imageUrl']);
        }
      }
    } catch (e) {
      print("❌ Error updating like count: $e");
    }
  }

// 🔹 Fixed `_sendLikeNotification()` function
  Future<void> _sendLikeNotification(
      String uploadedBy, String? wallpaperName, String? imageUrl) async {
    try {
      if (wallpaperKey == null) return;

      // Fetch wallpaper details from Realtime Database
      DatabaseReference wallpaperRef = FirebaseDatabase.instance
          .ref()
          .child('wallpapers')
          .child(wallpaperKey!);

      final wallpaperSnapshot = await wallpaperRef.get();
      if (!wallpaperSnapshot.exists) return;

      // Extract wallpaper data
      Map<dynamic, dynamic>? wallpaperData =
          wallpaperSnapshot.value as Map<dynamic, dynamic>?;

      String? uploadedBy =
          wallpaperData?['uploadedBy']; // User who uploaded the wallpaper
      String? imageUrl = wallpaperData?['imageUrl']; // Wallpaper image URL
      String? wallpaperName = wallpaperData?['name']; // Wallpaper name

      if (uploadedBy == null || imageUrl == null || wallpaperName == null) {
        print("Missing required fields, skipping notification...");
        return;
      }

      // Send notification to the uploadedBy user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uploadedBy)
          .collection('notifications')
          .add({
        'title': "Your wallpaper received a like!",
        'message': "Someone liked your wallpaper: $wallpaperName",
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      print("Notification sent successfully!");
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  void _showAdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Not enough credits"),
        content: Text("Watch an ad to earn 10 credits?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showRewardedAd();
            },
            child: Text("Watch Ad"),
          ),
        ],
      ),
    );
  }

  RewardedAd? _rewardedAd;
  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final userDoc =
                FirebaseFirestore.instance.collection('users').doc(user.uid);

            // Add 10 credits
            await userDoc.update({'credits': userCredits + 10});

            setState(() {
              userCredits += 10;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You earned 10 credits!')),
            );
          }
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ad not available. Try again later.')),
      );
    }
  }

  Future<void> _handleDownload(BuildContext context, String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to download wallpapers')),
      );
      return;
    }

    // Prevent downloading own premium wallpaper
    if (isUploadedByUser) {
      return;
    }

    // 🔹 Fetch latest user data (credits & subscription status)
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User data not found. Please try again.')),
      );
      return;
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    bool isSubscribed = userData['subscriptionActive'] ?? false;
    userCredits = userData['credits'] ?? 0;

    // 🔹 Handle premium wallpaper download logic
    if (isPremium) {
      if (!isSubscribed) {
        // Non-subscribed users require 10 credits
        if (userCredits < 10) {
          _showAdDialog(context); // Show ad option if not enough credits
          return;
        }

        // Deduct 10 credits for premium wallpaper download
        await userDocRef.update({'credits': userCredits - 10});
        setState(() {
          userCredits -= 10;
        });

        print('10 credits deducted! Remaining credits: $userCredits');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('10 credits deducted for premium wallpaper download.')),
        );
      } else {
        // ✅ Subscribed users download without credit deduction
        print('User is subscribed. Downloading without credit deduction.');
      }
    }

    // Proceed with the download
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
          await MediaScanner.loadMedia(path: filePath);
        } catch (e) {
          print('Error notifying media scanner: $e');
        }
      }

      // 🔹 Increment the download count
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
        SnackBar(content: Text('Wallpaper downloaded successfully!')),
      );
    } catch (e) {
      print('Error downloading wallpaper: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download wallpaper')),
      );
    }
  }

  Future<void> _handleShare() async {
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to share wallpaper')),
      );
      return;
    }

    try {
      // Step 1: Download the original image
      final response = await Dio().get(
        imageUrl!,
        options: Options(responseType: ResponseType.bytes),
      );

      // Step 2: Create watermark
      final watermarkedImage = await _addWatermark(response.data);

      // Step 3: Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/shared_wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);
      await file.writeAsBytes(watermarkedImage);

      // Step 4: Share with watermark
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Check out this awesome wallpaper from MyWallpaper App!',
        subject: 'Amazing Wallpaper for you!',
      );

      // Clean up
      await file.delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: ${e.toString()}')),
      );
    }
  }

  Future<Uint8List> _addWatermark(Uint8List originalImage) async {
    // Load the original image
    final codec = await instantiateImageCodec(originalImage);
    final frame = await codec.getNextFrame();
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Draw original image
    canvas.drawImage(
      frame.image,
      Offset.zero,
      Paint(),
    );

    // Load watermark image
    final logo = await loadImageFromAssets('assets/logo.png');

    // Resize logo to 15% of original image width (maintain aspect ratio)
    final logoWidth = frame.image.width * 0.2;
    final logoHeight = logo.height * (logoWidth / logo.width);

    // Calculate position (bottom-right corner with 16px padding)
    final position = Offset(
      frame.image.width - logoWidth - 16,
      frame.image.height - logoHeight - 16,
    );

    // Draw watermark with proper transparency
    final paint = Paint()
      ..colorFilter = ColorFilter.mode(
        Colors.white.withOpacity(0.7), // 70% opacity white overlay
        BlendMode.modulate, // Preserves transparency
      );

    canvas.drawImageRect(
      logo,
      Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
      Rect.fromLTWH(position.dx, position.dy, logoWidth, logoHeight),
      paint,
    );

    // Convert to byte array
    final image = await pictureRecorder.endRecording().toImage(
          frame.image.width,
          frame.image.height,
        );
    final byteData = await image.toByteData(format: ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  Future<ui.Image> loadImageFromAssets(String path) async {
    final byteData = await rootBundle.load(path);
    final codec = await instantiateImageCodec(byteData.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
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
                      isUploadedByUser
                          ? SizedBox() // Hide button if uploaded by user
                          : IconButton(
                              icon: Icon(Icons.download, color: Colors.white),
                              onPressed: () =>
                                  _handleDownload(context, imageUrl!),
                            ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
