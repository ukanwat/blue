import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
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
  void initState() {
   bool _sensitiveContent = preferences.getBool('hide_sensitive_content');
      if(_sensitiveContent != null)
        sensitiveContent =_sensitiveContent;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(    backgroundColor: Theme.of(context).backgroundColor,                                   // TODO
      appBar: settingsHeader(context, 'Safety'),
      body: ListView(
        children: <Widget>[
          settingsPageNavigationTile(
              context, 'Muted Accounts', MutedAccountsScreen.routeName),
                settingsPageNavigationTile(
              context, 'Blocked Accounts', BlockedAccountsScreen.routeName),
              settingsSwitchListTile('Hide Sensitive Content', sensitiveContent, (newValue){
                preferences.setBool('hide_sensitive_content',newValue );
                preferencesRef.doc(currentUser.id).update({
                  'hide_sensitive_content': newValue
                });
                setState(() {
                    sensitiveContent = newValue;
                });
              })
        ],
      ),
    );
  }
}