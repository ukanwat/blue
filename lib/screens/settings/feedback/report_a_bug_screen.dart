import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class ReportABugScreen extends StatefulWidget {
  static const routeName = 'report-a-bug';
  @override
  _ReportABugScreenState createState() => _ReportABugScreenState();
}

class _ReportABugScreenState extends State<ReportABugScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Report a Bug'),
      body: ListView(
        children: <Widget>[
          
        ],
      ),
    );
  }
}