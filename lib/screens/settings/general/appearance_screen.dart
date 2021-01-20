// Flutter imports:
import 'package:blue/services/preferences_update.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/providers/theme.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/settings_widgets.dart';
enum AppTheme{
  sysDefault,
  dark,
  light
}
class AppearanceScreen extends StatefulWidget {
  static const routeName = 'appearance';
  @override
  _AppearanceScreenState createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  AppTheme themeMode = AppTheme.sysDefault;
    bool autoplayVideos = false;
      bool serif = false;
  // bool autoplayGIFs = false;
  @override
  void initState(){
     getTheme();
         if(PreferencesUpdate().getBool('autoplay_videos') == null)
    PreferencesUpdate().updateBool('autoplay_videos',false);
    //  if(preferences.getBool('autoplay_GIFs') == null)
    // preferences.setBool('autoplay_GIFs',false);
   autoplayVideos =  PreferencesUpdate().getBool('autoplay_videos');
      // autoplayGIFs =  preferences.getBool('autoplay_GIFs');
        if(PreferencesUpdate().getBool('serif') == null){
     PreferencesUpdate().updateBool('serif',false);
    }
    serif = PreferencesUpdate().getBool('serif');
    super.initState();
  }
  getTheme()async{
     switch( PreferencesUpdate().getBool('theme')){
       case true: 
       setState(() {
        themeMode =AppTheme.dark;
         
       });
        break;
        case false: 
        setState(() {
           themeMode =AppTheme.light;
        });
       
        break;
        default: 
          setState(() {
            themeMode = AppTheme.sysDefault;
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
                  themeMode = AppTheme.sysDefault;
                notifier.toggleTheme(null,context);
              });
                       preferencesRef.doc(currentUser.id).set({'theme': themeMode.toString().substring(9)  },SetOptions(merge: true));
            },
          title: Text('System Default'),
          trailing: Visibility(
            visible: themeMode ==AppTheme.sysDefault,
                      child: Icon(FlutterIcons.check_circle_faw5s,
            color: Colors.blue
            ),
          ),
        ), 
           ListTile( onTap: (){
             setState(() {
              themeMode = AppTheme.light;
                        notifier.toggleTheme(false,context);
             });
                    
            }, title: Text('Light Mode'),
          trailing: Visibility( visible: themeMode == AppTheme.light,
                      child: Icon(FlutterIcons.check_circle_faw5s,
            color: Colors.blue),
          ),),
              ListTile( onTap: (){
                setState(() {
              themeMode = AppTheme.dark;
                           notifier.toggleTheme(true,context);
                });
                     
            }, title: Text('Dark Mode'),
              
          trailing: Visibility( visible: themeMode == AppTheme.dark,

                      child: Icon(FlutterIcons.check_circle_faw5s,
            color: Colors.blue
                ),
          ),),Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
   settingsSectionTitle("Autoplay", Icon(FluentIcons.play_24_regular,), context),
Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
  settingsSwitchListTile(
              'Autoplay Videos', autoplayVideos, (newValue) {setState(() {
                 PreferencesUpdate().updateBool('autoplay_videos', newValue);
                 autoplayVideos = newValue;
                   
              });},description: 'Autoplay Videos which appear in Posts'),
              // settingsSwitchListTile(
              // 'Autoplay GIFs', autoplayGIFs,  (newValue) {setState(() {
              //    preferences.setBool('autoplay_GIFs', newValue);
              //    autoplayGIFs = newValue;
              //      preferencesRef.doc(currentUser.id).set({'autoplay_GIFs': newValue},SetOptions(merge: true));
              // });},description: 'Autoplay GIF messages'),
              Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
          settingsSectionTitle("Title font", Icon(FluentIcons.text_font_size_24_regular,), context),
          Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
           ListTile( onTap: (){
               setState(() {
                serif = false;
                PreferencesUpdate().updateBool('serif',false);
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
                PreferencesUpdate().updateBool('serif',true);
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
