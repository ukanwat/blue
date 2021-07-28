// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Project imports:
import 'package:blue/services/auth_service.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/dialogs/show_dialog.dart';
import '../../profile/edit_profile_screen.dart';
import 'account_screens/date_of_birth_screen.dart';
import 'account_screens/deactivate_account_screen.dart';
import 'account_screens/email_screen.dart';
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
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Account'),
      body: ListView(
        children: <Widget>[
          Visibility(
            visible: PreferencesUpdate().getString('accountType') != 'google' &&
                PreferencesUpdate().getString('accountType') != 'facebook',
            child: settingsPageNavigationTile(
                context, 'Password', PasswordScreen.routeName),
          ),
          Visibility(
            visible: PreferencesUpdate().getString('accountType') != 'google' &&
                PreferencesUpdate().getString('accountType') != 'facebook',
            child: settingsPageNavigationTile(
              context,
              'Email',
              EmailScreen.routeName,
            ),
          ),
          settingsPageNavigationTile(
              context, 'Edit Profile', EditProfileScreen.routeName),
          settingsPageNavigationTile(
              context, 'Date Of Birth', DateOfBirthScreen.routeName),
          settingsPageNavigationTile(
              context, 'Deactivate Account', DeactivateAccountScreen.routeName),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => ShowDialog(
                  leftButtonFunction: () {
                    AuthService.logout(context);
                  },
                  title: "Sign Out?",
                  description: "Are you sure you want to sign out of stark?",
                  leftButtonText: "Sign Out",
                  rightButtonText: "Cancel",
                ),
              );
            },
            child: Container(
              alignment: Alignment.centerLeft,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sign Out',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.red),
                  ),
                  Icon(
                    FluentIcons.sign_out_24_regular,
                    color: Colors.red,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
