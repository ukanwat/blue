import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class GesturesScreen extends StatefulWidget {
  static const routeName = 'gestures';
  @override
  _GesturesScreenState createState() => _GesturesScreenState();
}

class _GesturesScreenState extends State<GesturesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Gestures'),
      body: ListView(
        children: <Widget>[
          
        ],
      ),
    );
  }
}