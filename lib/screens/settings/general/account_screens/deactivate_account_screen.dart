// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Project imports:
import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/show_dialog.dart';

class DeactivateAccountScreen extends StatelessWidget {
  static const routeName = 'deactivate-account';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Deactivate Account'),
      body: ListView(
        children: <Widget>[
          settingsActionTile(context, 'Deactivate Account', () {
            showDialog(
              context: context,
              builder: (BuildContext context) => ShowDialog(
                title: "Come Back Anytime!",
                description:
                    "People will not be able to see your Profile after account deactivation but they will still see private messages sent by you. Your profile data will be deleted forever after 30 unless you sign in again.",
                leftButtonText: "Deactivate",
                rightButtonText: "Cancel",
              ),
            );
          }, FluentIcons.delete_24_filled, isRed: true),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Deactivating your account will not delete the content of posts and comments you've made on Stark. To do so please delete them individually.",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }
}
