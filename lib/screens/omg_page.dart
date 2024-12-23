import 'package:flutter/material.dart';

class OmgPage extends StatefulWidget {
  @override
  _OmgPageState createState() => _OmgPageState();
}

class _OmgPageState extends State<OmgPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OMG Page'),
      ),
      body: Center(
        child: Text('This is a stateful widget with text!'),
      ),
    );
  }
}