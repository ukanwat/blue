// Flutter imports:
import 'dart:io';

import 'package:blue/constants/app_colors.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/post_service.dart';
import 'package:blue/widgets/bottom_sheet.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/show_dialog.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Project imports:
import 'package:blue/screens/following_posts_screen.dart';
import 'package:blue/widgets/paginated_posts.dart';
import 'package:blue/widgets/tags_wrap.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:share/share.dart';
import 'package:widgets_visibility_provider/widgets_visibility_provider.dart';
import '../widgets/header.dart';
import './home.dart';
import '../widgets/banner_dialog.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen(Key key) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with
        AutomaticKeepAliveClientMixin<HomeScreen>,
        SingleTickerProviderStateMixin {
  List<Post> p = [];
  PostService pS;
  bool followingPosts = false;
  int length = 100;
  bool loaded = false;

  double pos = 0;
  ScrollController _scrollController = ScrollController();
  double currOff = 0;
  showTagsSheet() {
    showSheet(
      context,
      TagsWrap(),
      Material(
        child: Container(
          height: 54,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Text('Tags You Follow',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    )),
              ),
              Expanded(
                child: Container(),
              ),
              IconButton(
                  icon: Icon(Icons.keyboard_arrow_down,
                      size: 28, color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          ),
        ),
      ),
    );
  }

  Future refreshPosts() async {
    p = [];
    addItems();
  }

  Future fn(int offSet) async {
    dynamic _snapshot = await Hasura.getPosts(
      length,
      offSet,
      "{score:desc}",
    );

    print(_snapshot.length);
    return _snapshot;
  }

  transform(dynamic doc) {
    return doc;
  }

  @override
  void didChangeDependencies() {
    pS = PostService('home', fn, transform, false, false);
    addItems();
    super.didChangeDependencies();
  }

  addItems() async {
    if (loaded == true) {
      return;
    }
    List<Post> _posts = await pS.getPosts(8);
    print('posts: $_posts');
    if (_posts.length == 0) {
      setState(() {
        loaded = true;
      });
    }

    print('loaded:$loaded');
    _posts.forEach((element) {
      print(element.title);
    });
    setState(() {
      p = p + _posts;
    });
    print(_posts.length);
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: header(
        context,
        implyLeading: false,
        title: Row(
          children: [
            Text(
              'Stark',
              style: TextStyle(
                fontSize: 26,
                fontFamily: 'Techna Sans Regular',
              ),
            ),
            followingPosts
                ? Padding(
                    padding: const EdgeInsets.only(left: 10, top: 8),
                    child: Text('FOLLOWING',
                        style: TextStyle(
                          fontFamily: 'Stark Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.withOpacity(0.7),
                        )),
                  )
                : Container(),
          ],
        ),
        actionButton2: Row(
          children: [
            if (!Platform.isAndroid)
              TextButton(
                  child: Text(
                    'INVITE',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ShowDialog(
                          noLeft: true,
                          description: 'Invite your friends to Stark',
                          rightButtonText: 'Invite',
                          leftButtonText: 'Cancel',
                          rightButtonFunction: () {
                            Navigator.pop(context);
                            Share.share(
                                "I'm inviting you to Stark https://starkinvite.page.link/i",
                                subject: 'App Invitation');
                          },
                          title: 'App Invitation',
                        );
                      },
                    );
                  }),
            IconButton(
                icon: Icon(
                  followingPosts
                      ? FluentIcons.arrow_hook_up_left_24_regular
                      : FluentIcons.new_24_regular,
                  size: 26,
                ),
                onPressed: () {
                  setState(() {
                    followingPosts = !followingPosts;
                  });
                }),
          ],
        ),
        actionButton: IconButton(
          icon: Icon(
            FluentIcons.add_24_regular,
            size: 27,
          ),
          onPressed: () {
            showTagsSheet();
          },
        ),
        centerTitle: false,
      ),
      body: PageTransitionSwitcher(
          transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: followingPosts
              ? FollowingPostsScreen()
              : Stack(
                  children: [
                    WidgetsVisibilityProvider(
                      condition: (PositionData positionData) =>
                          positionData.endPosition >= 0 &&
                          positionData.startPosition <=
                              positionData.viewportSize,
                      child: Container(
                        color: Theme.of(context).canvasColor,
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
                                      color: Theme.of(context).canvasColor,
                                      height: 120,
                                      width: MediaQuery.of(context).size.width,
                                      child: loaded
                                          ? Container()
                                          : Center(child: circularProgress()),
                                    );
                                  }
                                  return VisibleNotifierWidget(
                                    data: i,
                                    listener:
                                        (context, notification, positionData) {
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
                                      if (previousPositionData !=
                                          currentPositionData) return true;
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
                    Positioned(
                        bottom: 6,
                        left: 6,
                        child: Material(
                          color: Colors.transparent,
                          child: GestureDetector(
                            onTap: () {
                              double viewPort =
                                  MediaQuery.of(context).size.height -
                                      MediaQuery.of(context).padding.vertical;
                              double initialOff = _scrollController.offset;
                              _scrollController.animateTo(
                                  currOff + 5 + initialOff,
                                  duration: Duration(
                                      milliseconds:
                                          (300 * (currOff / viewPort).ceil()) <
                                                  100
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
                )),
    );
  }
}
