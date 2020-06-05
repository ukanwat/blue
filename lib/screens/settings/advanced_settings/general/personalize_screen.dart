import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class PersonalizeScreen extends StatefulWidget {
  static const routeName = 'personalize';
  @override
  _PersonalizeScreenState createState() => _PersonalizeScreenState();
}

class _PersonalizeScreenState extends State<PersonalizeScreen> {
  bool darkMode = false;
   bool  amoledDarkTheme  = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Personalize'),
      body: ListView(
        children: <Widget>[
          settingsSwitchListTile('Dark Mode', darkMode, (newValue){
            setState(() {
              
            darkMode = newValue;
            });

          }),
             settingsSwitchListTile('AMOLED Dark Theme', darkMode, (newValue){
            setState(() {
              
           amoledDarkTheme  = newValue;
            });

          })
        ],
      ),
    );
  }
}