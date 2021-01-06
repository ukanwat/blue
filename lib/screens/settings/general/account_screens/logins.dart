// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Project imports:
import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/show_dialog.dart';
import 'package:blue/services/auth_service.dart';
class LoginsScreen extends StatelessWidget {
  static const routeName = 'logins';
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Theme.of(context).backgroundColor,
        appBar: settingsHeader(context, 'Logins'),
        body: ListView(children: <Widget>[
InkWell(
    onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => ShowDialog(
               leftButtonFunction:  (){
                 AuthService.logout(context);
               },
                title: "Sign Out of Scrible?",
                description: "",
                leftButtonText: "Sign Out",
                rightButtonText: "Cancel",
              ),
            );
          },
    child: Container(alignment: Alignment.centerLeft,width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: 
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
               'Sign Out',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: Colors.red),
              ),Icon(FluentIcons.sign_out_24_regular,color: Colors.red,)
            ],
          ),
    ),
  ),


        ],),);
  }
}
