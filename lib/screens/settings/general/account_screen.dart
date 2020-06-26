import 'package:blue/main.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../edit_profile_screen.dart';
import 'account_screens/deactivate_account_screen.dart';
import 'account_screens/email_screen.dart';
import 'account_screens/logins.dart';
import 'account_screens/password_screen.dart';

class AccountScreen extends StatefulWidget {
  static const routeName = 'account';

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Account'),
      body: ListView(
        children: <Widget>[
          Visibility(
            visible: accountType != 'google',
            child: settingsPageNavigationTile(
                context, 'Password', PasswordScreen.routeName),
          ),
          Visibility(
            visible: 
            accountType != 'google',
            child: settingsPageNavigationTile(
                context, 'Email', EmailScreen.routeName,),
          ),
          settingsPageNavigationTile(
              context, 'Edit Profile',EditProfileScreen.routeName),
          // settingsPageNavigationTile(             TODO
          //     context, 'Deactivate Account', DeactivateAccountScreen.routeName),
          settingsPageNavigationTile(context, 'Logins', LoginsScreen.routeName),
        ],
      ),
    );
  }
}
