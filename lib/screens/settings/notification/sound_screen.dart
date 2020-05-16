import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class SoundScreen extends StatefulWidget {
  static const routeName = 'sound';
  @override
  _SoundScreenState createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Sound'),
      body: ListView(
        children: <Widget>[
          
        ],
      ),
    );
  }
}