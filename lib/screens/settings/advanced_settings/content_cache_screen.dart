import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/show_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ContentCacheScreen extends StatefulWidget {
  static const routeName = 'content-cache';
  @override
  _ContentCacheScreenState createState() => _ContentCacheScreenState();
}

class _ContentCacheScreenState extends State<ContentCacheScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Content Cache'),
      body: ListView(
        children: <Widget>[
          settingsActionTile(context, 'Clear Content Cache', (){
                 showDialog(
  context: context,
  builder: (BuildContext context) => ShowDialog(
        title: "Clear cache",
        description:
            "lopem ipsum",
        leftButtonText: "Clear Cache",
        rightButtonText: "Cancel",
        leftButtonFunction: (){
              DefaultCacheManager manager = new DefaultCacheManager();
                     manager.emptyCache(); 
        },
      ),
);
          }),
        ],
      ),
    );
  }
}