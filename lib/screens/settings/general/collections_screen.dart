import 'package:blue/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blue/main.dart';

import '../../home.dart';
import 'collection_screens/create_collection_screen.dart';

class CollectionsScreen extends StatefulWidget {
  static const routeName = 'collections';
  @override
  _CollectionsScreenState createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  DocumentSnapshot  snapshot ;
  bool loading  = true;
  @override
  void initState() {
    getCollections();
    super.initState();
  }
      getCollections() async {
snapshot =await collectionsRef
        .document(currentUser?.id).get();
        setState((){
          loading  = false;
        });
   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: 
      Theme.of(context).backgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            backgroundColor: Theme.of(context).canvasColor,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Collections',
              style: TextStyle(),
            ),
            automaticallyImplyLeading: false,
            leading: CupertinoNavigationBarBackButton(
              color: Colors.blue,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                      CreateCollectionScreen.routeName,
                    );
                },
                child: Text(
                  'New',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                  ),
                ),
              )
            ],
          ),),
      body: loading ? circularProgress(): ListView.builder(itemBuilder: (_,i){
          return Container(
            height: 80,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),

            decoration: BoxDecoration(
color: Theme.of(context).cardColor,
borderRadius: BorderRadius.circular(15),

            ),
          );
      },
      itemCount: snapshot.data.length + 1,
      )
    );
  }
}
