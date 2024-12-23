import 'package:flutter/material.dart';
import 'package:my_wallpaper/screens/login_page.dart';
import 'package:my_wallpaper/screens/profile_page.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart'; // Placeholder for the Home Page
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
