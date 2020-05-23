import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

import 'activity_screens/account_privacy_screen.dart';

class ActivityScreen extends StatefulWidget {
  static const routeName = 'activity';
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  bool currentValue =  false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Activity'),
      body: ListView(
        children: <Widget>[
           settingsPageNavigationTile(
              context, 'Password', AccountPrivacyScreen.routeName),
              // settingsPageNavigationTile(
              // context, 'Personalised recommendations based on your activity', AccountPrivacyScreen.routeName),
              settingsSwitchListTile('Personalised recommendations based on your activity', currentValue, (newValue){currentValue = newValue;},description: 'Improve the ')
        ],
      ),
    );
  }
}