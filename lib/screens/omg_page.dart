import 'package:flutter/material.dart';

class OmgPage extends StatefulWidget {
  const OmgPage({super.key});

  @override
  _OmgPageState createState() => _OmgPageState();
}

class _OmgPageState extends State<OmgPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OMG Page'),
      ),
      body: const Center(
        child: Text('This is a stateful widget with text!'),
      ),
    );
  }
}