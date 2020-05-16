import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class SafetyScreen extends StatefulWidget {
  static const routeName = 'safety';
  @override
  _SafetyScreenState createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Safety'),
      body: ListView(
        children: <Widget>[
          
        ],
      ),
    );
  }
}