// Flutter imports:
import 'package:blue/services/preferences_update.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/screens/settings/privacy/safety_screens/blocked_accounts_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screens/muted_accounts_screen.dart';
import 'package:blue/widgets/settings_widgets.dart';

class SafetyScreen extends StatefulWidget {
  static const routeName = 'safety';
  @override
  _SafetyScreenState createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  bool sensitiveContent = true;
  @override
  void initState() {
    sensitiveContent =
        PreferencesUpdate().getBool('hide_sensitive_content', def: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor, // TODO
      appBar: settingsHeader(context, 'Safety'),
      body: ListView(
        children: <Widget>[
          settingsPageNavigationTile(
              context, 'Muted Accounts', MutedAccountsScreen.routeName),
          settingsPageNavigationTile(
              context, 'Blocked Accounts', BlockedAccountsScreen.routeName),
          settingsSwitchListTile('Hide Sensitive Content', sensitiveContent,
              (newValue) {
            PreferencesUpdate().updateBool('hide_sensitive_content', newValue);

            setState(() {
              sensitiveContent = newValue;
            });
          }),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(
                  color: Theme.of(context).iconTheme.color.withOpacity(0.16),
                  width: 1),
            )),
          ),
        ],
      ),
    );
  }
}
