import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

import 'account_screens/deactivate_account_screen.dart';
import 'account_screens/email_screen.dart';
import 'account_screens/logins.dart';
import 'account_screens/password_screen.dart';

class AccountScreen extends StatelessWidget {
   static const routeName = 'account';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Account'),
      body: ListView(
        children: <Widget>[
          settingsPageNavigationTile(
              context, 'Password', PasswordScreen.routeName),
          settingsPageNavigationTile(
              context, 'Email', EmailScreen.routeName),
              settingsPageNavigationTile(
              context, 'Deactivate Account', DeactivateAccountScreen.routeName),
              settingsPageNavigationTile(
              context, 'Logins', LoginsScreen.routeName),
              
        ],
      ),
    );
  }
}
