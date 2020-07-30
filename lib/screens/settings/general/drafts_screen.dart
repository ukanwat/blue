import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class DraftsScreen extends StatefulWidget {
  static const routeName = 'drafts';
  @override
  _DraftsScreenState createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Drafts'),
      body: ListView(
        children: <Widget>[
          
        ],
      ),
    );
  }
}