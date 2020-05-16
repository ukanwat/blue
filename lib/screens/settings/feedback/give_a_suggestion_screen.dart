import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class GiveASuggestionScreen extends StatefulWidget {
  static const routeName = 'give-a-suggestion';
  @override
  _GiveASuggestionScreenState createState() => _GiveASuggestionScreenState();
}

class _GiveASuggestionScreenState extends State<GiveASuggestionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Give A Suggestion'),
      body: ListView(
        children: <Widget>[
          
        ],
      ),
    );
  }
}