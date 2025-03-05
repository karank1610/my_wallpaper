import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomAdScreen extends StatefulWidget {
  final VoidCallback onAdComplete;

  const CustomAdScreen({Key? key, required this.onAdComplete})
      : super(key: key);

  @override
  _CustomAdScreenState createState() => _CustomAdScreenState();
}

class _CustomAdScreenState extends State<CustomAdScreen> {
  VideoPlayerController? _controller;
  bool _isSkippable = false;
  String? videoUrl;

  @override
  void initState() {
    super.initState();
    _addNewAdsToFirestore(); // Step 1: Auto-add new ads to Firestore
  }

  /// **Step 1: Fetch Videos from Firebase Storage & Add to Firestore**
  Future<void> _addNewAdsToFirestore() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get all files from 'ads/' folder in Firebase Storage
    ListResult result = await storage.ref('ads').listAll();

    for (var file in result.items) {
      // Get the download URL
      String downloadUrl = await file.getDownloadURL();

      // Add to Firestore if it doesn't exist
      QuerySnapshot existingAds = await firestore
          .collection('ads')
          .where('videoUrl', isEqualTo: downloadUrl)
          .get();

      if (existingAds.docs.isEmpty) {
        await firestore.collection('ads').add({
          'videoUrl': downloadUrl,
          'duration': 30, // Default duration in seconds
          'isActive': true,
          'addedAt': FieldValue.serverTimestamp(),
        });
        print("✅ Added: $downloadUrl");
      } else {
        print("⚠️ Already Exists: $downloadUrl");
      }
    }
    _fetchRandomAd(); // After adding, fetch and display an ad
  }

  /// **Step 2: Fetch a Random Ad from Firestore**
  void _fetchRandomAd() async {
    FirebaseFirestore.instance
        .collection('ads')
        .where('isActive', isEqualTo: true)
        .get()
        .then((querySnapshot) {
      debugPrint("📢 Total Ads Found: ${querySnapshot.docs.length}");

      if (querySnapshot.docs.isNotEmpty) {
        Random random = Random();
        int randomIndex = random.nextInt(querySnapshot.docs.length);
        String selectedVideoUrl = querySnapshot.docs[randomIndex]['videoUrl'];

        debugPrint("🎥 Selected Ad URL: $selectedVideoUrl");

        setState(() {
          videoUrl = selectedVideoUrl;
          _loadVideo();
        });
      } else {
        debugPrint("⚠️ No Active Ads Found!");
        widget.onAdComplete(); // Close if no ads
      }
    }).catchError((error) {
      debugPrint("❌ Error fetching ads: $error");
      widget.onAdComplete();
    });
  }

  void _loadVideo() {
    if (videoUrl == null) return;

    _controller = VideoPlayerController.network(videoUrl!)
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
        Future.delayed(Duration(seconds: 10), () {
          setState(() {
            _isSkippable = true;
          });
        });
      });

    _controller!.addListener(() {
      if (_controller!.value.position >= _controller!.value.duration) {
        _onAdComplete();
      }
    });
  }

  void _onAdComplete() {
    widget.onAdComplete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          _controller != null && _controller!.value.isInitialized
              ? Center(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                )
              : Center(child: CircularProgressIndicator()),
          if (_isSkippable)
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: _onAdComplete,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
