// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:widgets_visibility_provider/widgets_visibility_provider.dart';

// Project imports:
import 'package:blue/services/hasura.dart';
import 'package:blue/services/post_service.dart';
import 'package:blue/widgets/paginated_posts.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';

class TagRecentScreen extends StatefulWidget {
  final String tag;
  TagRecentScreen(this.tag);
  @override
  _TagRecentScreenState createState() => _TagRecentScreenState();
}

class _TagRecentScreenState extends State<TagRecentScreen>
    with AutomaticKeepAliveClientMixin<TagRecentScreen> {
  List<Post> p = [];
  PostService pS;
  int length = 100;
  bool loaded = false;

  double pos = 0;
  ScrollController _scrollController = ScrollController();
  double currOff = 0;

  Future refreshPosts() async {
    p = [];
    addItems();
  }

  Future fn(int offSet) async {
    dynamic _snapshot = await Hasura.getTagPosts(length, offSet, "{score:desc}",
        tag: widget.tag);

    return _snapshot;
  }

  transform(dynamic doc) {
    return doc;
  }

  @override
  void didChangeDependencies() {
    pS = PostService('tag_top', fn, transform, false, false);
    addItems();
    super.didChangeDependencies();
  }

  addItems() async {
    if (loaded == true) {
      return;
    }
    List<Post> _posts = await pS.getPosts(8);
    if (_posts.length == 0) {
      setState(() {
        loaded = true;
      });
    }
    _posts.forEach((element) {});
    setState(() {
      p = p + _posts;
    });
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(context) {
    super.build(context);
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () {
            refreshPosts();
          },
          child: WidgetsVisibilityProvider(
            condition: (PositionData positionData) =>
                positionData.endPosition >= 0 &&
                positionData.startPosition <= positionData.viewportSize,
            child: Container(
              color: Theme.of(context).backgroundColor,
              child: RefreshIndicator(
                onRefresh: () => refreshPosts(),
                child: LazyLoadScrollView(
                  isLoading: loaded,
                  onEndOfPage: () {
                    addItems();
                  },
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: p.length + 1,
                      itemBuilder: (context, i) {
                        if (i == p.length) {
                          return Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width,
                            child: loaded
                                ? Container()
                                : Center(child: circularProgress()),
                          );
                        }
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
                          child: p.elementAt(i),
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
                      }),
                ),
              ),
            ),
          ),
        ),
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
                  _scrollController.animateTo(currOff + 5 + initialOff + 100,
                      duration: Duration(
                          milliseconds:
                              (300 * (currOff / viewPort).ceil()) < 100
                                  ? 100
                                  : (300 * (currOff / viewPort).ceil())),
                      curve: Curves.easeInOut);
                },
                child: Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          Theme.of(context).backgroundColor.withOpacity(0.5)),
                  child: Icon(
                    FluentIcons.chevron_down_16_filled,
                    color: Theme.of(context).iconTheme.color.withOpacity(0.6),
                    size: 24,
                  ),
                ),
              ),
            ))
      ],
    );
  }
}
