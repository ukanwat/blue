import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
class FontScreen extends StatefulWidget {
    static const routeName = 'font';
  @override
  _FontScreenState createState() => _FontScreenState();
}

class _FontScreenState extends State<FontScreen> {
  bool serif = false;
  @override
  void initState() {
    if(preferences.getBool('serif') == null){
      preferences.setBool('serif',false);
    }
    serif = preferences.getBool('serif');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Post Font'),
          body: Column(
        children: <Widget>[
           ListTile( onTap: (){
               setState(() {
                serif = false;
                  preferences.setBool('serif',false);
                    preferencesRef.document(currentUser.id).setData({'serif': false},merge: true);
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
                 preferencesRef.document(currentUser.id).setData({'serif': true},merge: true);
               });
              }, title: Text('Serif',style: TextStyle(fontFamily: 'Georgia'),),
            trailing: Visibility( visible: serif == true,
                        child: Icon(FlutterIcons.check_circle_faw5s,
              color: Colors.blue),
            ),),
        ],
      ),
    );
  }
}