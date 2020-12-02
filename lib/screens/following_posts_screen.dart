import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
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
        .getDocuments();

    setState(() {
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  buildFollowingPosts() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container();
    } else {
      return ListView(children: posts);
    }
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
        onRefresh: () => getFollowingPosts(),
        child: buildFollowingPosts(),
      );
  }
}
