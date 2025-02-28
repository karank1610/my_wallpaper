import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class RewardedAdHelper {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false; // ✅ Track if the ad is ready
  bool get isAdLoaded => _isAdLoaded;
  // Test AdMob Rewarded Ad Unit ID
  final String rewardedAdUnitId = "ca-app-pub-3940256099942544/5224354917";

  // Load Rewarded Ad
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint("✅ Rewarded Ad Loaded Successfully!");
          _rewardedAd = ad;
          _isAdLoaded = true; // ✅ Mark the ad as ready
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint("❌ Failed to load Rewarded Ad: ${error.message}");
          _rewardedAd = null;
          _isAdLoaded = false; // ❌ Reset ad state
          Future.delayed(
              const Duration(seconds: 3), loadRewardedAd); // 🔄 Retry
        },
      ),
    );
  }

  // Show Rewarded Ad and Give Credits
  void showRewardedAd(BuildContext context) {
    if (!_isAdLoaded || _rewardedAd == null) {
      debugPrint("⚠️ Ad not ready yet. Loading a new one...");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Ad not ready yet. Try again in a few seconds.")),
      );
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint("✅ Ad Dismissed! Loading a new one...");
        _isAdLoaded = false; // ❌ Reset ad state
        ad.dispose();
        loadRewardedAd(); // 🚀 Load a new ad instantly
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint("❌ Ad failed to show: ${error.message}");
        _isAdLoaded = false;
        ad.dispose();
        loadRewardedAd(); // 🚀 Reload immediately
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
        debugPrint("🎉 User earned reward! Adding 10 credits...");
        await _addCreditsToUser(10);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You earned 10 credits!")),
        );
      },
    );

    _rewardedAd = null; // ✅ Reset after showing
    _isAdLoaded = false;
  }

  // Add credits to Firestore
  Future<void> _addCreditsToUser(int credits) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    DocumentSnapshot userDoc = await userRef.get();

    if (userDoc.exists) {
      int currentCredits = userDoc['credits'] ?? 0;
      await userRef.update({'credits': currentCredits + credits});
    } else {
      await userRef.set({'credits': credits});
    }
  }

  // Random chance to show rewarded ad (33% chance)
  bool shouldShowAd() {
    Random random = Random();
    return random.nextInt(2) == 0; // 1 in 3 chance
  }
}
