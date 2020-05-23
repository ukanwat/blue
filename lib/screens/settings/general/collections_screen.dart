import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'collection_screens/create_collection_screen.dart';

class CollectionsScreen extends StatefulWidget {
  static const routeName = 'collections';
  @override
  _CollectionsScreenState createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Collections',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            automaticallyImplyLeading: false,
            leading: CupertinoNavigationBarBackButton(
              color: Colors.grey,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: <Widget>[FlatButton(onPressed: (){
              Navigator.of(context).pushNamed(CreateCollectionScreen.routeName);
              }, child: Text(
                'New',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ))
              
            ],
          )),
      body: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[],
      ),
    );
  }
}
