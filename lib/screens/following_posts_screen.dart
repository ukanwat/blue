import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowingPostsScreen extends StatefulWidget {
  @override
  _FollowingPostsScreenState createState() => _FollowingPostsScreenState();
}

class _FollowingPostsScreenState extends State<FollowingPostsScreen>
    with AutomaticKeepAliveClientMixin<FollowingPostsScreen> {
    List<Post> posts;
   getFollowingPosts() async {
    print(currentUser);
    QuerySnapshot snapshot = await postsRef
        .get();

    setState(() {
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc.data())).toList();
      posts = [];
    });
  }

  buildFollowingPosts(BuildContext context,) {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return emptyState(context,'Follow new People','Earth and Moon',subtitle: 'You are not following anyone',);//TODO no posts even with following
    } else {
      return ListView(children: [...posts,Container(height: 100,)]);
    }
  }

  bool get wantKeepAlive => true;
  @override
  void initState() {
      getFollowingPosts() ;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(color: Theme.of(context).backgroundColor,
      child: RefreshIndicator(
          onRefresh: () => getFollowingPosts(),
          child: buildFollowingPosts(context),
        ),
    );
  }
}
