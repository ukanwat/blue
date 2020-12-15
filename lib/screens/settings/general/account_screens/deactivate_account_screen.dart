import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/show_dialog.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class DeactivateAccountScreen extends StatelessWidget {
  static const routeName = 'deactivate-account';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Deactivate Account'),
      body: ListView(children: <Widget>[settingsActionTile(context, 'Deactivate Account', (){

        showDialog(
  context: context,
  builder: (BuildContext context) => ShowDialog(
        title: "Come Back Anytime!",
        description:
            "To use Scrible again , just login with your email. People will not be able to see your Profile after account deactivation but they will still see private messages sent by you.",
        leftButtonText: "Deactivate account",
        rightButtonText: "Cancel",
      ),
);
      },FluentIcons.access_time_24_regular)],),
      
    );
  }
}
