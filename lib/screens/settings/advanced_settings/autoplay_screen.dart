import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class AutoplayScreen extends StatefulWidget {
  static const routeName = 'autoplay';
  @override
  _AutoplayScreenState createState() => _AutoplayScreenState();
}

class _AutoplayScreenState extends State<AutoplayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Autoplay'),
      body: ListView(
        children: <Widget>[
          
        ],
      ),
    );
  }
}