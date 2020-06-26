import 'package:blue/screens/all_topics_screen.dart';
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
    with AutomaticKeepAliveClientMixin<ExploreScreen> {
  List<Post> posts = [];
  bool horizontalListViewIsLoading;
  int noOfFollowedTopicCards = 0;
  List<TopicCard> followedTopics = [];
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
    });
  }

  getFollowedTopics() async {
    setState(() {
      horizontalListViewIsLoading = true;
    });
    QuerySnapshot snapshot = await followedTopicsRef
        .document('${currentUser.id}')
        .collection('userFollowedTopics')
        .getDocuments();

    print(snapshot.documents.length);
    setState(() {
      noOfFollowedTopicCards = snapshot.documents.length;
      snapshot.documents.forEach((doc) {
        print(doc.data);
        followedTopics.add(
          TopicCard(doc['name'], doc['imageUrl'], doc['id'], doc['info'],
              MediaQuery.of(context).size.width / 4.3),
        );
        horizontalListViewIsLoading = false;
      });
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
        appBar: header(

          context,
          title: Text(
            'Explore',
            style: TextStyle(
              fontFamily: 'Techna Sans Regular',
            ),
          ),
          actionButton: IconButton(
              icon: Icon(FlutterIcons.plus_ant,size: 29,
                  color: Theme.of(context).iconTheme.color),
              onPressed: () {
                Navigator.pushNamed(context, AllTopicsScreen.routeName);
              }),
          leadingButton: IconButton(
            icon: Icon(FlutterIcons.search_oct,
            
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(SearchScreen.routeName);
            },
            color: Theme.of(context).iconTheme.color
          ),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: horizontalListViewIsLoading
                  ? linearProgress()
                  : SizedBox(
                      height: 0,
                    ),
            ),
            SliverToBoxAdapter(
              child: horizontalListViewIsLoading
                  ? Container()
                  : Container(
                      color: Theme.of(context).backgroundColor,
                      height: MediaQuery.of(context).size.width / 4,
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: ListView(
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: followedTopics,
                      ),
                    ),
            ),
            SliverToBoxAdapter(
              child: horizontalListViewIsLoading
                  ? Container()
                  : Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: Colors.grey[850],
                    ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  return posts[i];
                },
                childCount: posts.length,
              ),
            ),
          ],
        ));
  }
}
