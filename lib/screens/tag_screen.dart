// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/screens/tag/tag_popular_screen.dart';
import 'package:blue/screens/tag/tag_recent_screen.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/services/preferences_update.dart';

class TagScreen extends StatefulWidget {
  static const routeName = 'tag';
  @override
  _TagScreenState createState() => _TagScreenState();
}

class _TagScreenState extends State<TagScreen> {
  String tag;
  bool isFollowing = false;
  @override
  void didChangeDependencies() {
    tag = ModalRoute.of(context).settings.arguments;
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          elevation: 0,
          actions: <Widget>[
            preferences.getStringList('followed_tags').contains(tag) 
                ?  PopupMenuButton(
                      padding: EdgeInsets.zero,
                      
                      color: Theme.of(context).canvasColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            child: Text('Unfollow'),
                            value:'Unfollow'),
                      ],
                      icon: Icon(Icons.more_vert),
                      onSelected: (selectedValue) async {
                        if (selectedValue == 'Unfollow') {
                             setState(() {
                               PreferencesUpdate().removeStringFromList('followed_tags', tag);

                        }); 
           await   followedTagsRef.doc(currentUser.id).update({tag: FieldValue.delete()});
           
                        }
                      },
                    )
                : IconButton(
                 icon:    Icon( Icons.add,
                 size: 34,
                 color: Colors.blue
                 ),

                    onPressed: () async { // TODO

                        followedTagsRef.doc(currentUser.id).set({
                          tag: DateTime.now(),
                        }, SetOptions(merge: true));
                         
                        setState(() {
                          PreferencesUpdate().addStringToList('followed_tags', tag);
                        });
                      
                    },
                  )
          ],
          backgroundColor: Theme.of(context).canvasColor,
          automaticallyImplyLeading: false,
          leading: CupertinoNavigationBarBackButton(color: Colors.blue),
          centerTitle: true,
          title: Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Text(
              '#$tag',
              overflow: TextOverflow.ellipsis,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.lightBlue),
          ),
          bottom: TabBar(
            unselectedLabelStyle: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600),
            labelStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Theme.of(context).iconTheme.color,
            labelColor: Theme.of(context).iconTheme.color,
            unselectedLabelColor: Theme.of(context).iconTheme.color.withAlpha(200),
            tabs: [
              Tab(
                text: "Latest",
              ),
              Tab(text: "Top"),
            ],
          ),
        ),
        body: TabBarView(children: [
          TagPopularScreen(tag),
          TagRecentScreen(tag),
        ]),
      ),
    );
  }
}
