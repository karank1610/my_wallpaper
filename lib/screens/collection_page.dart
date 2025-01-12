import 'package:flutter/material.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Collection Page!'),
      ),
    );
  }
}