import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  static const routeName = 'activity';
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  bool trackActivity =  true;
  bool setPrivate =  false;
  @override
  void initState() {
   bool _setPrivate = preferences.getBool('set_private');
      bool _trackActivity = preferences.getBool('track_activity');
      print(_setPrivate);
       print(_trackActivity);
      if(_setPrivate != null)
        setPrivate =_setPrivate;
          if(_trackActivity != null)
        trackActivity =_trackActivity;

    super.initState();
  }
  @override
  Widget build(BuildContext context) {                 
    return Scaffold(backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Activity'),
      body: ListView(
        children: <Widget>[
                  settingsSwitchListTile('Set your profile private', setPrivate, (newValue){
                 //TODO
                                preferences.setBool('set_private',newValue );
                preferencesRef.doc(currentUser.id).update({
                  'set_private': newValue
                });
                setState(() {
                    setPrivate = newValue;
                });}),  Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),   

              settingsSwitchListTile('Personalised recommendations based on your activity', trackActivity, (newValue){
                
                                preferences.setBool('track_activity',newValue );
                preferencesRef.doc(currentUser.id).update({
                  'track_activity': newValue
                });
                setState(() {
                    trackActivity = newValue;
                });}),Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
        ],
      ),
    );
  }
}