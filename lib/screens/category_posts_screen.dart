// Flutter imports:
import 'package:blue/services/hasura.dart';
import 'package:blue/services/post_service.dart';
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

class _CategoryPostsScreenState extends State<CategoryPostsScreen>
    with AutomaticKeepAliveClientMixin<CategoryPostsScreen> {
  List<Post> posts = [];
  bool loading = true;
  bool blank = false;
  Widget compactPosts;

  Future refreshPosts() async {
    setState(() {
      if (widget.name == 'All')
        compactPosts = EverythingPostsScreen(UniqueKey());
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
      compactPosts = EverythingPostsScreen(UniqueKey());
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

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
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
  EverythingPostsScreen(Key key) : super(key: key);
  @override
  _EverythingPostsScreenState createState() => _EverythingPostsScreenState();
}

class _EverythingPostsScreenState extends State<EverythingPostsScreen>
    with AutomaticKeepAliveClientMixin<EverythingPostsScreen> {
  List<Widget> _items = [];
  bool loaded = false;
  int offset = 0;
  bool empty = false;
  List popTags = [];
  int length = 50;
  bool loading = false;

  PostService pS;
  Future fn(int offSet) async {
    dynamic _snapshot = await Hasura.getPosts(
      length,
      offSet,
      "{created_at:desc}",
    );

    return _snapshot;
  }

  load(bool loaded) {
    setState(() {
      loaded = true;
    });
  }

  transform(dynamic doc) {
    return doc;
  }

  double pos = 0;
  @override
  void initState() {
    pS = PostService('all', fn, transform, true);
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
    if (loading == true) {
      return;
    }
    loading = true;
    List<Post> _posts = await pS.getPosts(8);
    setState(() {
      _items = _items + _posts;
    });

    if (popTags != null &&
        popTags != [] &&
        popTags.length != 0 &&
        _items.length != 0) {
      print(popTags);
      _items.add(Container(child: PostsSection(popTags[0]['tag'], 'Top')));
      popTags.removeAt(0);
    }

    loading = false;
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return empty
        ? emptyState(context, "Nothing Here!", 'none')
        : Container(
            color: Theme.of(context).backgroundColor,
            child: LoadMore(
              isFinish: pS.getLoaded,
              onLoadMore: () async {
                await addItems();
                return true;
              },
              child: ListView.builder(
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
