import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class ChatInfoScreen extends StatefulWidget {
   static const routeName = 'chat-info';
  @override
  _ChatInfoScreenState createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends State<ChatInfoScreen> {
 
  bool muteMessages = false;
  @override
  Widget build(BuildContext context) {
  Map<String,String> peer =   ModalRoute.of(context).settings.arguments as Map;
    return Scaffold(
      appBar: header(context,title: Text('Info',style: TextStyle(color: Colors.black),),
      centerTitle: false,
      leadingButton: CupertinoNavigationBarBackButton(),


      ),
      body: Column(children: <Widget>[
        settingsSwitchListTile('Mute Messages', muteMessages, (newValue){
          setState(() {
             muteMessages = newValue;
          });
        }),
        settingsActionTile(context,'Block',(){},),
        settingsActionTile(context,'Report',(){}),
       settingsActionTile(context,'Delete Messages',(){}),
      ],),

      
    );
  }
}