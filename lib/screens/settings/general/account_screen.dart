// Flutter imports:
import 'package:blue/services/preferences_update.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/widgets/settings_widgets.dart';
import '../../edit_profile_screen.dart';
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
    return Scaffold(backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Account'),
      body: ListView(
        children: <Widget>[
          Visibility(
            visible: PreferencesUpdate().getString('accountType') != 'google',
            child: settingsPageNavigationTile(
                context, 'Password', PasswordScreen.routeName),
          ),
          Visibility(
            visible: 
         PreferencesUpdate().getString('accountType') != 'google',
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
