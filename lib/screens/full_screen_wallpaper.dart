import 'package:flutter/material.dart';

class FullScreenWallpaper extends StatelessWidget {
  final ImageProvider imageProvider;

  FullScreenWallpaper({required this.imageProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image(
          image: imageProvider,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
