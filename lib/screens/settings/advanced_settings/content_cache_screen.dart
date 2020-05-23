import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class ContentCacheScreen extends StatefulWidget {
  static const routeName = 'content-cache';
  @override
  _ContentCacheScreenState createState() => _ContentCacheScreenState();
}

class _ContentCacheScreenState extends State<ContentCacheScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Content Cache'),
      body: ListView(
        children: <Widget>[
          settingsActionTile(context, 'Clear Content Cache', (){}),
        ],
      ),
    );
  }
}