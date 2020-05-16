import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class EmailNotificationsScreen extends StatefulWidget {
  static const routeName = 'email-notifications';
  @override
  _EmailNotificationsScreenState createState() => _EmailNotificationsScreenState();
}

class _EmailNotificationsScreenState extends State<EmailNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Email Notifications'),
      body: ListView(
        children: <Widget>[
          
        ],
      ),
    );
  }
}