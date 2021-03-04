// Flutter imports:
import 'package:blue/services/hasura.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/all_saved_posts_screen.dart';
import 'package:blue/widgets/progress.dart';
import '../../collection_posts_screen.dart';
import '../../home.dart';
import 'collection_screens/create_collection_screen.dart';

class CollectionsScreen extends StatefulWidget {
  static const routeName = 'collections';
  @override
  _CollectionsScreenState createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
 dynamic  snapshot ;
  bool loading  = true;
  @override
  void initState() {
    getCollections();
    super.initState();
  }
      getCollections() async {
        setState(() {
  loading = true;
});
snapshot =await Hasura.getCollections();
setState(() {
  loading = false;
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
                    ).then((value){
                      if(value == true){
                        getCollections();
                      }
                    });
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
      body: loading ? circularProgress(): ListView.builder(
        padding: EdgeInsets.only(top: 6),
        itemBuilder: (_,i){
        i = i-1;
          return Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 0),
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),

              decoration: BoxDecoration(
borderRadius: BorderRadius.circular(15),
border: Border.all(width: 2,color:  Theme.of(context).cardColor,)
            
              ), child:InkWell(
             onTap: (){
           if(i== -1){
              Navigator.of(context).pushNamed( AllSavedPostsScreen.routeName);
           }else{
              Navigator.of(context).pushNamed( CollectionPostsScreen.routeName,arguments: snapshot[i]['collection']);
           }
             },
                      child:  Center(
               child: Text(i== -1? 'All Saved':
                snapshot[i ]['collection'],maxLines: 1,overflow: TextOverflow.ellipsis,
                style: TextStyle(
               
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
                )
             )
            ),
          );
      },
      itemCount: snapshot.length + 1,
      )
    );
  }
}
