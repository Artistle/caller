import 'package:flutter/material.dart';

class RecorderScreen extends StatefulWidget {
  @override
  _RecorderScreenState createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  @override
  Widget build(BuildContext context) {
    var sizeX = MediaQuery.of(context).size;
    return Material(
      elevation: 3.0,
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
        ),
        height: sizeX.height / 3,
        width: sizeX.width,
        child: Center(child: Text('here will be a Recorder')),
      ),
    );
  }
}
