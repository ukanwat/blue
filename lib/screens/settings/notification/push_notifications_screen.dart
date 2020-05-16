import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class PushNotificationsScreen extends StatefulWidget {
  static const routeName = 'push-notifications';
  @override
  _PushNotificationsScreenState createState() => _PushNotificationsScreenState();
}

class _PushNotificationsScreenState extends State<PushNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Account'),
      body: ListView(
        children: <Widget>[
          
        ],
      ),
    );
  }
}