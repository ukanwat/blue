import 'package:blue/screens/settings/privacy/safety_screens/blocked_accounts_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screens/muted_accounts_screen.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class SafetyScreen extends StatefulWidget {
  static const routeName = 'safety';
  @override
  _SafetyScreenState createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  bool sensitiveContent =  true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Safety'),
      body: ListView(
        children: <Widget>[
          settingsPageNavigationTile(
              context, 'Muted Accounts', MutedAccountsScreen.routeName),
                settingsPageNavigationTile(
              context, 'Blocked Accounts', BlockedAccountsScreen.routeName),
              settingsSwitchListTile('Hide Sensitive Content', sensitiveContent, (newValue){sensitiveContent = newValue;})
        ],
      ),
    );
  }
}