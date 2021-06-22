// Flutter imports:
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/loadmore_widget.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

// Package imports:

// Project imports:
//
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/progress.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:widgets_visibility_provider/widgets_visibility_provider.dart';
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
  double pos = 0;
  bool loading = false;
  ScrollController _scrollController = ScrollController();
  double currOff = 0;
  @override
  void initState() {
    addPosts();

    super.initState();
  }

  addPosts() async {
    if (loading) return;
    loading = true;
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

      print('ddddgg $_p');
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
        for (int i = 0; i < _snapshot.length; i++) {
          _snapshot[i] = _snapshot[i]['post'];
        }
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

    loading = false;
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
        : Stack(
            children: [
              WidgetsVisibilityProvider(
                condition: (PositionData positionData) =>
                    positionData.endPosition >= 0 &&
                    positionData.startPosition <= positionData.viewportSize,
                // No need to wrap directly
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: LoadMore(
                    isFinish: loaded,
                    onLoadMore: () async {
                      await addPosts();
                      return true;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(bottom: 50, top: 0),
                      physics: widget.tag == null
                          ? AlwaysScrollableScrollPhysics()
                          : NeverScrollableScrollPhysics(),
                      itemCount: _posts.length,
                      itemBuilder: (context, i) {
                        if (widget.isCompact != true) {
                          return VisibleNotifierWidget(
                            data: i,
                            listener: (context, notification, positionData) {
                              if (positionData != null) {
                                if (positionData.endPosition > 0 &&
                                    positionData.startPosition <= 0) {
                                  currOff = positionData.endPosition;
                                } else {}
                              }
                            },
                            child: _posts.elementAt(i),
                            condition: (
                              previousNotification,
                              previousPositionData,
                              currentNotification,
                              currentPositionData,
                            ) {
                              if (previousPositionData != currentPositionData)
                                return true;
                              if (previousPositionData != null &&
                                  currentPositionData != null)
                                return previousNotification !=
                                    currentNotification;
                              return false;
                            },
                          );
                        }

                        return _posts.elementAt(i);
                      },
                    ),
                  ),
                ),
              ),
              if (widget.isCompact != true)
                Positioned(
                    bottom: 6,
                    left: 6,
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: () {
                          double viewPort = MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.vertical;
                          double initialOff = _scrollController.offset;
                          _scrollController.animateTo(currOff + 5 + initialOff,
                              duration: Duration(
                                  milliseconds:
                                      (300 * (currOff / viewPort).ceil()) < 100
                                          ? 100
                                          : (300 *
                                              (currOff / viewPort).ceil())),
                              curve: Curves.easeInOut);
                        },
                        child: Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .backgroundColor
                                  .withOpacity(0.5)),
                          child: Icon(
                            FluentIcons.chevron_down_16_filled,
                            color: Theme.of(context)
                                .iconTheme
                                .color
                                .withOpacity(0.6),
                            size: 24,
                          ),
                        ),
                      ),
                    ))
            ],
          );
  }
}
