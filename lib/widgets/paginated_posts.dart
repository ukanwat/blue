// Flutter imports:
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/loadmore_widget.dart';
import 'package:flutter/material.dart';

// Package imports:

// Project imports:
//
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/progress.dart';
import 'post.dart';

class PaginatedPosts extends StatefulWidget {
  final int length;
  final bool isCompact;
  final bool neverScroll;
  final String orderBy;
  final String where;
  final String tag;
  PaginatedPosts({
    this.length,
    this.orderBy,
    this.isCompact,
    this.neverScroll,
    this.where,
    this.tag,
    Key key,
  }) : super(key: key);
  @override
  _PaginatedPostsState createState() => _PaginatedPostsState();
}

class _PaginatedPostsState extends State<PaginatedPosts> {
  dynamic _posts = [];
  bool loaded = false;
  int lastDoc;
  bool empty = false;
  // ScrollController _scrollController = ScrollController();
  double pos = 0;
  @override
  void initState() {
    addPosts();
    // _scrollController.addListener(() {
    //   if (true) {
    //     print('${_scrollController.position.pixels}');
    //     print('max');
    //     print('${_scrollController.position.maxScrollExtent}');
    //   }
    //   if (((_scrollController.position.pixels >
    //               _scrollController.position.maxScrollExtent - 50) &&
    //           (_scrollController.position.pixels <=
    //               _scrollController.position.maxScrollExtent)) &&
    //       empty != true &&
    //       loaded != true &&
    //       (pos - _scrollController.position.pixels > 51 ||
    //           pos - _scrollController.position.pixels < -51)) {
    //     pos = _scrollController.position.pixels;
    //     print('adding');
    //     addPosts();
    //   }
    // });
    super.initState();
  }

  addPosts() async {
    print('adding posts');
    if (loaded == true) return;

    if (lastDoc == null) {
      dynamic _p;
      if (widget.tag != null) {
        _p = await Hasura.getTagPosts(
          widget.length,
          0,
          widget.orderBy ?? "{created_at:desc}",
          tag: widget.tag,
        );
      } else {
        _p = await Hasura.getPosts(
            widget.length, 0, widget.orderBy ?? "{created_at:desc}",
            where: widget.where ?? null);
      }
      _posts = _p
          .map((doc) => Post.fromDocument(
                doc,
                isCompact: widget.isCompact ?? false,
              ))
          .toList();
      if (this.mounted) setState(() {});
      if (_p.length == 0) {
        if (this.mounted)
          setState(() {
            empty = true;
          });
        return;
      }
      lastDoc = _p.length;
      if (_p.length < widget.length) {
        if (this.mounted)
          setState(() {
            loaded = true;
          });
        return;
      }
    } else {
      var _snapshot;
      if (widget.tag != null) {
        _snapshot = await Hasura.getTagPosts(
          widget.length,
          lastDoc,
          widget.orderBy ?? "{created_at:desc}",
          tag: widget.tag,
        );
      } else {
        _snapshot = await Hasura.getPosts(
            widget.length, lastDoc, widget.orderBy ?? "{created_at:desc}",
            where: widget.where ?? null);
      }
      _snapshot.forEach((doc) {
        _posts.add(Post.fromDocument(
          doc,
          isCompact: widget.isCompact ?? false,
        ));
      });

      if (_snapshot.length < widget.length) {
        setState(() {
          loaded = true;
        });
        return;
      }
      lastDoc = lastDoc + _snapshot.length;
    }

    //  List d = [];
    //  d.elementAt(i)
  }

  @override
  Widget build(BuildContext context) {
    if (widget.neverScroll == null ? false : widget.neverScroll) {
      return ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return _posts.elementAt(i);
        },
        itemCount: _posts.length,
      );
    }
    return empty
        ? emptyState(context, "Can't find any posts ", 'none')
        : Container(
            color: Theme.of(context).backgroundColor,
            child: LoadMore(
              isFinish: loaded,
              onLoadMore: () async {
                await addPosts();
                return true;
              },
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: _posts.length,
                itemBuilder: (context, i) {
                  return _posts.elementAt(i);
                },
              ),
            ),
          );
  }
}
