// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:blue/env.dart';
import 'package:blue/screens/rewards_screen.dart';
import 'package:blue/services/scroll_direction.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:get/get.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:share/share.dart';
import 'package:widgets_visibility_provider/widgets_visibility_provider.dart';

// Project imports:
import 'package:blue/constants/app_colors.dart';
import 'package:blue/screens/home/following_posts_screen.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/post_service.dart';
import 'package:blue/widgets/bottom_sheet.dart';
import 'package:blue/widgets/paginated_posts.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/dialogs/show_dialog.dart';
import 'package:blue/widgets/tags_wrap.dart';
import '../widgets/dialogs/banner_dialog.dart';
import '../widgets/header.dart';

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
  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();
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
    pS;
    loaded = false;
    pS = PostService('home', fn, transform, false, false);
    addItems();
    setState(() {});
    return;
  }

  Future fn(int offSet) async {
    dynamic _snapshot = await Hasura.getPosts(
      length,
      offSet,
      "{score:desc}",
    );

    return _snapshot;
  }

  transform(dynamic doc) {
    return doc;
  }

  // Scroll sc;
  @override
  void didChangeDependencies() {
    pS = PostService('home', fn, transform, false, false);
    // sc = Get.put(Scroll(_scrollController));
    // sc.init();

    addItems();
    if (!Env.introShown && (Env.newUser == true)) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => Future.delayed(Duration(milliseconds: 500), () {
                Env.intro.start(context);
                Env.introShown = true;
              }));
    }

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
    if (this.mounted)
      setState(() {
        p = p + _posts;
      });
  }

  BuildContext myContext;

  bool get wantKeepAlive => true;
  @override
  Widget build(context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          title: Row(
            children: [
              Text(
                'Stark',
                style: TextStyle(
                  fontSize: 26,
                  fontFamily: 'Techna Sans Regular',
                ),
              ),
              GestureDetector(
                key: Env.intro.keys[0],
                onTap: () {
                  setState(() {
                    followingPosts = !followingPosts;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      height: 20,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 5, top: 0, right: 0),
                        child: Center(
                          child: Text(followingPosts ? 'FOLLOWING' : 'FOR YOU',
                              style: TextStyle(
                                fontFamily: 'Stark Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.withOpacity(0.7),
                              )),
                        ),
                      ),
                    ),
                    Icon(
                      FluentIcons.arrow_sync_circle_24_regular,
                      color: Colors.grey.withOpacity(0.7),
                      size: 18,
                    )
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                GestureDetector(
                    key: Env.intro.keys[1],
                    child: Container(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          FluentIcons.gift_24_regular,
                          color: Theme.of(context).accentColor,
                          size: 26,
                        )),
                    onTap: () {
                      Navigator.pushNamed(context, RewardsScreen.routeName);
                      // showDialog(
                      //   context: context,
                      //   builder: (context) {
                      //     return
                      //     ShowDialog(
                      //       noLeft: true,
                      //       description: 'Invite your friends to Stark',
                      //       rightButtonText: 'Invite',
                      //       leftButtonText: 'Cancel',
                      //       rightButtonFunction: () {
                      //         Navigator.pop(context);
                      //         Share.share(
                      //             "I'm inviting you to Stark https://starkinvite.page.link/i",
                      //             subject: 'App Invitation');
                      //       },
                      //       title: 'App Invitation',
                      //     );
                      //   },
                      // );
                    }),
                if (!followingPosts)
                  IconButton(
                      icon: Icon(
                        FluentIcons.arrow_clockwise_24_regular,
                        size: 26,
                      ),
                      onPressed: () {
                        refreshPosts();
                      }),
              ],
            ),
            IconButton(
              icon: Icon(
                FluentIcons.add_24_regular,
                size: 27,
              ),
              onPressed: () {
                showTagsSheet();
              },
            ),
          ],
          elevation: 0,
          automaticallyImplyLeading: false,
          brightness: Theme.of(context).brightness,
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(0.5),
              child: Column(
                children: [
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: Theme.of(context).iconTheme.color.withOpacity(0.1),
                  ),
                ],
              )),
          backgroundColor: Theme.of(context).backgroundColor,
        ),
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
            : Container(
                child: Stack(
                  children: [
                    WidgetsVisibilityProvider(
                      condition: (PositionData positionData) =>
                          positionData.endPosition >= 0 &&
                          positionData.startPosition <=
                              positionData.viewportSize,
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
                                      color: Theme.of(context).canvasColor,
                                      height: 120,
                                      width: MediaQuery.of(context).size.width,
                                      child: loaded
                                          ? Container()
                                          : Container(
                                              color: Theme.of(context)
                                                  .backgroundColor,
                                              child: Center(
                                                  child: circularProgress()),
                                            ),
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
                ),
              ),
      ),
    );
  }
}
