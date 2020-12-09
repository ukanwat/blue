import 'package:blue/screens/all_topics_screen.dart';
import 'package:blue/screens/category_posts_screen.dart';
import 'package:blue/screens/search_screen.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/tags_wrap.dart';
import 'package:blue/widgets/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:blue/main.dart';

import 'package:blue/widgets/header.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'home.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin<ExploreScreen> ,SingleTickerProviderStateMixin{
  List<Post> posts = [];
  int noOfFollowedTopicCards = 0;
  List<Tab> topicTabs = [];
    List<Widget> topicViews = [];
 bool  loading = true; 
 TabController tabController;
  @override
  void initState() {
    getFollowedTopics();
    getExplore();
    super.initState();
  }

  getExplore() async {
    QuerySnapshot snapshot = await postsRef.limit(5).get();
    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
      loading = false;
    });
  }
   showTagsSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        child: Container(
          height: 240,
          width: MediaQuery.of(context).size.width,
          decoration: new BoxDecoration(
            color: Theme.of(context).canvasColor,
          ),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    child: Text('Tags you Follow',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 17)),
                  ),
                  IconButton(
                      icon: Icon(Icons.keyboard_arrow_down,
                          size: 26, color: Theme.of(context).iconTheme.color),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ],
              ),
              Expanded(child: TagsWrap()),
            ],
          ),
        ),
      ),
    );
  }
  getFollowedTopics() async {
    QuerySnapshot snapshot = await followedTopicsRef
        .doc('${currentUser.id}')
        .collection('userFollowedTopics')
        .get();

    print(snapshot.docs.length);
    setState(() {
      noOfFollowedTopicCards = snapshot.docs.length;
      snapshot.docs.forEach((doc) {
        topicTabs.add(
          Tab(text: doc['name'],)
        );
        topicViews.add( CategoryPostsScreen( doc['name']));
      });

     tabController = new TabController(length:  noOfFollowedTopicCards , vsync: this);
    });
  }
  // getPopularPosts() async {
  //   QuerySnapshot snapshot = await popularPostsRef.getDocuments();
  //   List<Post> posts =
  //       snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
  //   setState(() {
  //     this.posts = posts;
  //   });
  // }
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        appBar: AppBar(centerTitle: true,backgroundColor: Theme.of(context).backgroundColor,elevation: 1.2,
          title: Text(
            'Explore',
            style: TextStyle(
              fontFamily: 'Techna Sans Regular',
            ),
          ),
        bottom: loading? PreferredSize(child: Container(), preferredSize: Size.fromHeight(0)): PreferredSize(preferredSize: Size.fromHeight(40),
                  child: Container(height: 40,margin:EdgeInsets.only(left: 8,right: 8,bottom: 6,top: 4),
                    child: TabBar(indicator: ShapeDecoration(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              color: Theme.of(context).cardColor.withOpacity(0.6),
            ),
            isScrollable: true,
            controller: tabController,indicatorColor: Colors.blue,labelPadding: EdgeInsets.symmetric(horizontal: 10),
            tabs: topicTabs,),
                  ),
        ),
          actions:<Widget>[ IconButton(
              icon: Icon(FluentIcons.add_24_regular,size: 29,
                  color: Theme.of(context).iconTheme.color),
              onPressed: () {
                showTagsSheet();
              })],
          leading: IconButton(
            icon: Icon(FlutterIcons.search_oct,
            
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(SearchScreen.routeName);
            },
            color: Theme.of(context).iconTheme.color
          ),
          
        ),
        body: loading? circularProgress():TabBarView(
children: topicViews,
controller: tabController,

        ));
  }
}
