import 'package:blue/screens/all_topics_screen.dart';
import 'package:blue/screens/category_posts_screen.dart';
import 'package:blue/screens/search_screen.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/topic_card.dart';
import 'package:blue/widgets/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    QuerySnapshot snapshot = await postsRef.limit(5).getDocuments();
    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
      loading = false;
    });
  }

  getFollowedTopics() async {
    QuerySnapshot snapshot = await followedTopicsRef
        .document('${currentUser.id}')
        .collection('userFollowedTopics')
        .getDocuments();

    print(snapshot.documents.length);
    setState(() {
      noOfFollowedTopicCards = snapshot.documents.length;
      snapshot.documents.forEach((doc) {
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
        appBar: AppBar(centerTitle: true,backgroundColor: Theme.of(context).canvasColor,elevation: 1,
          title: Text(
            'Explore',
            style: TextStyle(
              fontFamily: 'Techna Sans Regular',
            ),
          ),
        bottom: loading? PreferredSize(child: Container(), preferredSize: Size.fromHeight(0)): PreferredSize(preferredSize: Size.fromHeight(40),
                  child: Container(height: 40,
                    child: TabBar(
            
            isScrollable: true,
            controller: tabController,indicatorColor: Colors.blue,labelPadding: EdgeInsets.symmetric(horizontal: 10),
            tabs: topicTabs,),
                  ),
        ),
          actions:<Widget>[ IconButton(
              icon: Icon(FlutterIcons.plus_ant,size: 29,
                  color: Theme.of(context).iconTheme.color),
              onPressed: () {
                Navigator.pushNamed(context, AllTopicsScreen.routeName);
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
