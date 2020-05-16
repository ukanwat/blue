import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class CollectionsScreen extends StatefulWidget {
  static const routeName = 'collections';
  @override
  _CollectionsScreenState createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Collections'),
      body: ListView(
        children: <Widget>[
          
        ],
      ),
    );
  }
}