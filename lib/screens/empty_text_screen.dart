import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class EmptyTextScreen extends StatelessWidget {
  EmptyTextScreen(this.title, this.content);
  final String title;
  final String content;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, title),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Text(content)),
    );
  }
}
