// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/widgets/settings_widgets.dart';

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
