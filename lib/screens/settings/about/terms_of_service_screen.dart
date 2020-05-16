import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatefulWidget {
  static const routeName = 'terms-of-service';
  @override
  _TermsOfServiceScreenState createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Terms of Service'),
      body: ListView(
        children: <Widget>[
          
        ],
      ),
    );
  }
}