import 'package:blue/screens/home.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/show_dialog.dart';
import 'package:flutter/material.dart';

class LoginsScreen extends StatelessWidget {
  static const routeName = 'logins';
   logout() {
    googleSignIn.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: settingsHeader(context, 'Logins'),
        body: ListView(children: <Widget>[
          settingsActionTile(context, 'Log Out', () {
            showDialog(
              context: context,
              builder: (BuildContext context) => ShowDialog(
               leftButtonFunction:  logout,
                title: "Log Out of Scrible?",
                description: "",
                leftButtonText: "Log Out",
                rightButtonText: "Cancel",
              ),
            );
          }),
        ]));
  }
}
