// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/loadmore_widget.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';

class FollowingPostsScreen extends StatefulWidget {
  @override
  _FollowingPostsScreenState createState() => _FollowingPostsScreenState();
}

class _FollowingPostsScreenState extends State<FollowingPostsScreen>
    with AutomaticKeepAliveClientMixin<FollowingPostsScreen> {
  dynamic _posts = [];
  bool loaded = false;
  int lastDoc = 0;
  bool empty = false;
  int length = 10;
  // ScrollController _scrollController = ScrollController();
  double pos = 0;
  @override
  void initState() {
    addPosts();
    super.initState();
  }

  int _lastDoc;

  addPosts() async {
    if (lastDoc == _lastDoc) {
      return;
    }
    _lastDoc = lastDoc;
    if (loaded == true) return;
    dynamic _p;

    _p = await Hasura.getFollowingPosts(lastDoc, length);
    lastDoc = lastDoc + _p.length;

    _posts = _posts +
        _p
            .map((doc) => Post.fromDocument(
                  doc['post'],
                ))
            .toList();

    if (this.mounted) setState(() {});
    if (_p.length == 0) {
      if (this.mounted)
        setState(() {
          empty = true;
          loaded = true;
        });
      return;
    }

    if (_p.length < length) {
      if (this.mounted)
        setState(() {
          loaded = true;
        });
      return;
    }
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return (empty)
        ? Container(
            color: Theme.of(context).backgroundColor,
            child: emptyState(context, "Empty!", 'Earth and Moon',
                subtitle: "Posts from people you follow will appear here"),
          )
        : Container(
            color: Theme.of(context).backgroundColor,
            child: LoadMore(
              isFinish: loaded,
              onLoadMore: () async {
                await addPosts();
                return true;
              },
              child: ListView.builder(
                itemCount: _posts.length + 1,
                itemBuilder: (context, i) {
                  if (i == _posts.length) {
                    return Container(height: 100, child: circularProgress());
                  }
                  return _posts.elementAt(i);
                },
              ),
            ),
          );
  }
}
