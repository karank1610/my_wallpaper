import 'package:flutter/material.dart';
import 'package:my_wallpaper/screens/rewarded_ad_helper.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart'; // Placeholder for the Home Page
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  RewardedAdHelper().loadRewardedAd();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyWallpaper',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) =>
            HomeScreen(), // Replace with your actual Home Page
      },
    );
  }
}
