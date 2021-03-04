// Flutter imports:
import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';

class FollowingPostsScreen extends StatefulWidget {
  @override
  _FollowingPostsScreenState createState() => _FollowingPostsScreenState();
}

class _FollowingPostsScreenState extends State<FollowingPostsScreen>
    with AutomaticKeepAliveClientMixin<FollowingPostsScreen> {
    List<dynamic> posts;
    bool noFollowings = false;
   getFollowingPosts() async {
    print(currentUser);
    dynamic snapshot = await Hasura.getFollowingPosts(false);
      print(snapshot);
    if(this.mounted)setState(() {
      posts = 
      snapshot.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  buildFollowingPosts(BuildContext context,) {
    if (Boxes.followingBox.isEmpty) {
      return emptyState(context,'Follow new People','Earth and Moon',subtitle: 'You are not following anyone',);//TODO no posts even with following
    } else if (posts == null  ) {
      return circularProgress();
    } else if ( posts.isEmpty) {
      return emptyState(context,'Nothing Here!','none');
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
          child: 
          buildFollowingPosts(context),
        ),
    );
  }
}
