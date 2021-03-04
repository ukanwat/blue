// Flutter imports:
import 'dart:math';
import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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
  
  List colors = [Colors.red, Colors.green, Colors.yellow,Colors.blue, Colors.amber,Colors.deepOrange,Colors.indigo,];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  elevation: 0,
                  expandedHeight: 160.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Theme.of(context).backgroundColor,
                  actions: [
                    PreferencesUpdate()
                            .containsInList('followed_tags', tag)
                        ? PopupMenuButton(
                            padding: EdgeInsets.zero,
                            color: Theme.of(context).canvasColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                  child: Text('Unfollow'), value: 'Unfollow'),
                            ],
                            icon: Icon(Icons.more_vert),
                            onSelected: (selectedValue) async {
                              if (selectedValue == 'Unfollow') {
                                setState(() {
                                  PreferencesUpdate().removeFromList(
                                      'followed_tags', tag);
                                });
                                await followedTagsRef
                                    .doc(currentUser.id)
                                    .update({tag: FieldValue.delete()});
                              }
                            },
                          )
                        : IconButton(
                            onPressed: () async {
                              // TODO

                              followedTagsRef.doc(currentUser.id).set({
                                tag: DateTime.now(),
                              }, SetOptions(merge: true));

                              setState(() {
                                PreferencesUpdate()
                                    .addToList('followed_tags', tag);
                              });
                            },
                            icon: Icon(Icons.add, size: 34, color: Colors.blue),
                          )
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: new ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: new BackdropFilter(
                            filter: new ImageFilter.blur(
                                sigmaX: 10.0, sigmaY: 10.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.transparent),
                              child: Text('#$tag',
                                  style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w700)),
                            ),
                          )),
                      background: Container(height: double.infinity,width: double.infinity,color:colors.elementAt(Random().nextInt(colors.length)))),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      indicatorColor: Colors.deepOrange,
                      tabs: [
                        Tab(
                          child: Row(
                            children: [
                              Icon(FluentIcons.arrow_trending_24_filled),
                              Text(
                                'Top',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              )
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            children: [
                              Icon(FluentIcons.new_24_filled),
                              Text(
                                'Latest',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(children: <Widget>[
              SingleChildScrollView(child: TagPopularScreen(tag)),
              SingleChildScrollView(child: TagRecentScreen(tag))
            ])),
        
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Theme.of(context).backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
