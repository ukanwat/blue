// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/providers/theme.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/settings_widgets.dart';

class AppearanceScreen extends StatefulWidget {
  static const routeName = 'appearance';
  @override
  _AppearanceScreenState createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  String themeMode = 'System Default';
    bool autoplayVideos = false;
      bool serif = false;
  // bool autoplayGIFs = false;
  @override
  void initState(){
     getTheme();
         if(preferences.getBool('autoplay_videos') == null)
    preferences.setBool('autoplay_videos',false);
    //  if(preferences.getBool('autoplay_GIFs') == null)
    // preferences.setBool('autoplay_GIFs',false);
   autoplayVideos =  preferences.getBool('autoplay_videos');
      // autoplayGIFs =  preferences.getBool('autoplay_GIFs');
        if(preferences.getBool('serif') == null){
      preferences.setBool('serif',false);
    }
    serif = preferences.getBool('serif');
    super.initState();
  }
  getTheme()async{
 SharedPreferences preferences = await SharedPreferences.getInstance();
     switch( preferences.get('theme')){
       case true: 
       setState(() {
        themeMode = 'Dark Mode';
         
       });
        break;
        case false: 
        setState(() {
           themeMode = 'Light Mode';
        });
       
        break;
        default: 
          setState(() {
            themeMode = 'System Default';
        });
      
        break;
     }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Appearance'),
      body:   Consumer<ThemeNotifier>(
                          builder: (context,notifier,child) => ListView(
        children: <Widget>[
          settingsSectionTitle("Theme", Icon(FluentIcons.paint_bucket_24_regular,), context),
          Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
        ListTile(
            onTap: (){
              setState(() {
                  themeMode = 'System Default';
                notifier.toggleTheme(null);
              });
                       preferencesRef.doc(currentUser.id).set({'theme': themeMode },SetOptions(merge: true));
            },
          title: Text('System Default'),
          trailing: Visibility(
            visible: themeMode == 'System Default',
                      child: Icon(FlutterIcons.check_circle_faw5s,
            color: Colors.blue
            ),
          ),
        ), 
           ListTile( onTap: (){
             setState(() {
              themeMode = 'Light Mode';
                        notifier.toggleTheme(false);
             });
                    preferencesRef.doc(currentUser.id).set({'theme': themeMode },SetOptions(merge: true));
            }, title: Text('Light Mode'),
          trailing: Visibility( visible: themeMode == 'Light Mode',
                      child: Icon(FlutterIcons.check_circle_faw5s,
            color: Colors.blue),
          ),),
              ListTile( onTap: (){
                setState(() {
              themeMode = 'Dark Mode';
                           notifier.toggleTheme(true);
                });
                       preferencesRef.doc(currentUser.id).set({'theme': themeMode },SetOptions(merge: true));
            }, title: Text('Dark Mode'),
              
          trailing: Visibility( visible: themeMode == 'Dark Mode',

                      child: Icon(FlutterIcons.check_circle_faw5s,
            color: Colors.blue
                ),
          ),),Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
   settingsSectionTitle("Autoplay", Icon(FluentIcons.play_24_regular,), context),
Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
  settingsSwitchListTile(
              'Autoplay Videos', autoplayVideos, (newValue) {setState(() {
                  preferences.setBool('autoplay_videos', newValue);
                 autoplayVideos = newValue;
                     preferencesRef.doc(currentUser.id).set({'autoplay_videos': newValue},SetOptions(merge: true));
              });},description: 'Autoplay Videos which appear in Posts'),
              // settingsSwitchListTile(
              // 'Autoplay GIFs', autoplayGIFs,  (newValue) {setState(() {
              //    preferences.setBool('autoplay_GIFs', newValue);
              //    autoplayGIFs = newValue;
              //      preferencesRef.doc(currentUser.id).set({'autoplay_GIFs': newValue},SetOptions(merge: true));
              // });},description: 'Autoplay GIF messages'),
              Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
          settingsSectionTitle("Post font", Icon(FluentIcons.text_font_size_24_regular,), context),
          Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
           ListTile( onTap: (){
               setState(() {
                serif = false;
                  preferences.setBool('serif',false);
                    preferencesRef.doc(currentUser.id).set({'serif': false},SetOptions(merge: true));
               });
              }, title: Text('Sans Serif'),
            trailing: Visibility( visible: serif == false,
                        child: Icon(FlutterIcons.check_circle_faw5s,
              color: Colors.blue),
            ),),
              ListTile( onTap: (){
               setState(() {
                serif = true;
                  preferences.setBool('serif',true);
                 preferencesRef.doc(currentUser.id).set({'serif': true},SetOptions(merge: true));
               });
              }, title: Text('Serif',style: TextStyle(fontFamily: 'Georgia'),),
            trailing: Visibility( visible: serif == true,
                        child: Icon(FlutterIcons.check_circle_faw5s,
              color: Colors.blue),
            ),),Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
        ],
      ),)
    );
  }
}
