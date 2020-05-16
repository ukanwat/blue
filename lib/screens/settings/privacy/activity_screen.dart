import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  static const routeName = 'activity';
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Activity'),
      body: ListView(
        children: <Widget>[
          
        ],
      ),
    );
  }
}