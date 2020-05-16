import 'package:blue/screens/all_topics_screen.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/topic_card.dart';
import 'package:blue/widgets/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:blue/widgets/header.dart';

import 'home.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Post> posts = [];
  bool horizontalListViewIsLoading;
  int noOfTopicCards = 0;
  List<TopicCard> topics = [];
  @override
  void initState() {
    getFollowedTopics();
    // getPopularPosts();
    super.initState();
  }

  getFollowedTopics() async {
    setState(() {
      horizontalListViewIsLoading = true;
    });
    QuerySnapshot snapshot = await topicsRef.getDocuments();

    //followedTopicsRef
    // .document(currentUser.id)
    // .collection('userFollowedTopics')
    // .getDocuments();
    setState(() {
      horizontalListViewIsLoading = false;
      noOfTopicCards = snapshot.documents.length;
      snapshot.documents.forEach((doc) {
        topics.add(
          TopicCard(doc['name'], doc['imageUrl'], doc['id'], doc['info'], 100),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,title: Text('Explore',style: TextStyle(color: Theme.of(context).primaryColor),),
        leadingButton: IconButton(
            icon: Icon(Icons.grid_on, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.pushNamed(context, AllTopicsScreen.routeName);
            }),
        actionButton: IconButton(
          icon: Icon(
            Icons.search,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: null,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            horizontalListViewIsLoading
                ? linearProgress()
                : SizedBox(
                    height: 3,
                  ),
            if (!horizontalListViewIsLoading)
              Container(
                height: 100.0,
                child: ListView(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: topics,
                ),
              ),
            if (!horizontalListViewIsLoading)
              Divider(
                height: 7,
              ),
            ListView(
              children: posts,
              shrinkWrap: true, //TODO: remove shrinkwrap
            )
          ],
        ),
      ),
    );
  }
}
