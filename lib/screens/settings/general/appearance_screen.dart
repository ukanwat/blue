import 'package:blue/main.dart';
import 'package:blue/providers/theme.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceScreen extends StatefulWidget {
  static const routeName = 'appearance';
  @override
  _AppearanceScreenState createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  String themeMode = 'System Default';
  @override
  void initState(){
     getTheme();
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
        ), Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
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
          ),),Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
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

        ],
      ),)
    );
  }
}