import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AutoplayScreen extends StatefulWidget {
  static const routeName = 'autoplay';
  @override
  _AutoplayScreenState createState() => _AutoplayScreenState();
}

class _AutoplayScreenState extends State<AutoplayScreen> {
  bool autoplayVideos = false;
  bool autoplayGIFs = false;
  @override
  void initState() {
    if(preferences.getBool('autoplay_videos') == null)
    preferences.setBool('autoplay_videos',false);
     if(preferences.getBool('autoplay_GIFs') == null)
    preferences.setBool('autoplay_GIFs',false);
   autoplayVideos =  preferences.getBool('autoplay_videos');
      autoplayGIFs =  preferences.getBool('autoplay_GIFs');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Autoplay'),
      body: ListView(
        children: <Widget>[
          settingsSwitchListTile(
              'Autoplay Videos', autoplayVideos, (newValue) {setState(() {
                  preferences.setBool('autoplay_videos', newValue);
                 autoplayVideos = newValue;
                     preferencesRef.doc(currentUser.id).set({'autoplay_videos': newValue},SetOptions(merge: true));
              });},description: 'Autoplay Videos which appear in Posts'),
              settingsSwitchListTile(
              'Autoplay GIFs', autoplayGIFs,  (newValue) {setState(() {
                 preferences.setBool('autoplay_GIFs', newValue);
                 autoplayGIFs = newValue;
                   preferencesRef.doc(currentUser.id).set({'autoplay_GIFs': newValue},SetOptions(merge: true));
              });},description: 'Autoplay GIF messages'),
        ],
      ),
    );
  }
}