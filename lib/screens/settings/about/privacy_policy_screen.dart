import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  static const routeName = 'privacy-policy';
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Privacy Policy'),
      body: ListView(
        children: <Widget>[
          
        ],
      ),
    );
  }
}