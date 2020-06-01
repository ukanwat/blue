import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'collection_screens/create_collection_screen.dart';

class CollectionsScreen extends StatefulWidget {
  static const routeName = 'collections';
  @override
  _CollectionsScreenState createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  List<String> collectionNames = [];
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
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                      CreateCollectionScreen.routeName,
                      arguments: {'collectionNames': collectionNames});
                },
                child: Text(
                  'New',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              )
            ],
          )),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: MediaQuery.of(context).size.width / 2,
        ),
        itemBuilder: (_, i) {
          return Card(
            child: Text(collectionNames[i]),
            color: Colors.grey[200],
            margin: EdgeInsets.all(5),
          );
        },
        itemCount: collectionNames.length,
      ),
    );
  }
}
