// Flutter imports:
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/loadmore_widget.dart';
import 'package:blue/widgets/posts_section.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/paginated_posts.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'home.dart';

class CategoryPostsScreen extends StatefulWidget {
  final String name;
  CategoryPostsScreen(this.name, Key key) : super(key: key);
  @override
  _CategoryPostsScreenState createState() => _CategoryPostsScreenState();
}

class _CategoryPostsScreenState extends State<CategoryPostsScreen> {
  List<Post> posts = [];
  bool loading = true;
  bool blank = false;
  Widget compactPosts;

  Future refreshPosts() async {
    setState(() {
      if (widget.name == 'All')
        compactPosts = PaginatedPosts(
          length: 8,
          isCompact: true,
          key: UniqueKey(),
          orderBy: '{score:desc}',
        );
      else
        compactPosts = PaginatedPosts(
          length: 8,
          isCompact: true,
          key: UniqueKey(),
          where: '{category:{_eq:"${widget.name}"}}',
          orderBy: '{score:desc}',
        );
    });
  }

  @override
  void initState() {
    if (widget.name == 'All') {
      compactPosts = EverythingPostsScreen();
    } else
      compactPosts = PaginatedPosts(
        length: 8,
        isCompact: true,
        key: UniqueKey(),
        where: '{category:{_eq:"${widget.name}"}}',
        orderBy: '{score:desc}',
      );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: RefreshIndicator(
        onRefresh: () => refreshPosts(),
        child: Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: Theme.of(context).cardColor, width: 1))),
            child: compactPosts),
      ),
    );
  }
}

class EverythingPostsScreen extends StatefulWidget {
  @override
  _EverythingPostsScreenState createState() => _EverythingPostsScreenState();
}

class _EverythingPostsScreenState extends State<EverythingPostsScreen> {
  dynamic _items = [];
  bool loaded = false;
  int offset = 0;
  bool empty = false;
  List popTags = [];
  int length = 8;
  bool loading = false;
  // ScrollController _scrollController = ScrollController();
  double pos = 0;
  @override
  void initState() {
    addItems();
    getPopTags();
    super.initState();
  }

  getPopTags() async {
    popTags = await Hasura.getPopularTags();
    if (popTags == null) {
      popTags = [];
    }
  }

  addItems() async {
    if (loaded == true) return;
    if (loading == true) return;
    loading = true;

    var _snapshot;

    _snapshot = await Hasura.getPosts(
      length,
      offset,
      "{score:desc}",
    );

    _snapshot.forEach((doc) {
      _items.add(Post.fromDocument(
        doc,
        isCompact: true,
      ));
    });
    if (popTags != null && popTags != [] && popTags.length != 0) {
      print(popTags);
      _items.add(PostsSection(popTags[0]['tag'], 'Top'));
      popTags.removeAt(0);
    }

    if (_snapshot.length < length) {
      setState(() {
        loaded = true;
      });
      return;
    }
    offset = offset + _snapshot.length;
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return empty
        ? emptyState(context, "Nothing Here!", 'none')
        : Container(
            color: Theme.of(context).backgroundColor,
            child: LoadMore(
              isFinish: loaded,
              onLoadMore: () async {
                await addItems();
                return true;
              },
              child: ListView.builder(
                cacheExtent: 10,
                padding: EdgeInsets.only(bottom: 50),
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  return _items.elementAt(i);
                },
              ),
            ),
          );
  }
}
