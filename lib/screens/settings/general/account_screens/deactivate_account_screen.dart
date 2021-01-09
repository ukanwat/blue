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

    return Scaffold(backgroundColor: 
  Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Deactivate Account'),
      body: ListView(children: <Widget>[settingsActionTile(context, 'Deactivate Account', (){

        showDialog(
  context: context,
  builder: (BuildContext context) => ShowDialog(
        title: "Come Back Anytime!",
        description:
            "People will not be able to see your Profile after account deactivation but they will still see private messages sent by you.\nTo use Stark again , just login with your email. ",
        leftButtonText: "Deactivate account",
        rightButtonText: "Cancel",
      ),
);
      },FluentIcons.delete_forever_24_filled,isRed: true),
      Padding(padding: EdgeInsets.all(10),
      child: Text("!!! Deactivating your account will not delete the content of posts and comments you've made on Stark. To do so please delete them individually.",style: TextStyle(color: Colors.red),),
      )
      ],),
      
    );
  }
}
