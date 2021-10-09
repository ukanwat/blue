// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:ui';

// Flutter imports:
import 'package:blue/screens/search_screen.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';

// Project imports:
import 'package:blue/constants/app_colors.dart';
import 'package:blue/main.dart';
import 'package:blue/screens/inbox/communication_tabbar_screen.dart';
import 'package:blue/screens/post/post_screen.dart';
import 'package:blue/screens/settings/general/drafts_screen.dart';
import 'package:blue/services/auth_service.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/functions.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/services/push_notifications.dart';
import 'package:blue/widgets/progress.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quick_actions/quick_actions.dart';
import '../services/dynamic_links.dart';
import './explore_screen.dart';
import './profile_screen.dart';
import 'home_screen.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = 'tabs';
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> with WidgetsBindingObserver {
  PageController _pageController;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _page = 0;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  logout() {
    googleSignIn.signOut();
  }

  Future handleStartUpLogic(BuildContext context) async {
    // call handle dynamic links
    await DynamicLinksService.initDynamicLinks(context);
  }

  setLists() async {
    if (PreferencesUpdate().isListEmpty('blocked_accounts')) {
      List accounts = await Hasura.blockedUsers(idOnly: true);
      List<dynamic> list = accounts.map((d) => d['blocked_user_id']).toList();
      if (list == null) {
        list = [];
      }
      PreferencesUpdate().updateStringList('blocked_accounts', list);
    }
    if (PreferencesUpdate().isListEmpty('muted_messages')) {
      List accounts = await Hasura.mutedUsers(idOnly: true);

      List<dynamic> list = accounts.map((d) => d['muted_user_id']).toList();
      if (list == null) {
        list = [];
      }
      PreferencesUpdate().updateStringList('muted_messages', list);
    }

    List tags = PreferencesUpdate().getStringList('followed_tags');

    bool b = tags == null;
    if (!b) {
      b = tags.length == 0;
    } else {
      tags = [];
    }
    if (b) {
      dynamic tagsData = await Hasura.getFollowedTags();
      tagsData.forEach((tag) {
        tags.add({
          'tag': tag['tag']['tag'],
          'label': tag['tag']['label'],
          'tag_id': tag['tag']['tag_id'],
          'image_url': tag['tag']['image_id'],
          'follower_count': tag['tag']['follower_count'],
          'post_count': tag['tag']['post_count'],
        });
      });
      PreferencesUpdate().setStringList('followed_tags', tags);
    }
  }

  StreamSubscription<ConnectivityResult> subscription;
  String shortcut = 'no action set';
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Boxes.preferenceBox.put('start_time', DateTime.now().toString());
    }
  }

  quickActions() async {
    //TODO:imp bottom tab and page doesn't change on android
    // await Future.delayed(Duration(seconds: 1));
    final QuickActions quickActions = QuickActions();
    quickActions.initialize((String type) {
      if (this.mounted)
        setState(() {
          if (type == 'post') {
            Navigator.pushNamed(context, PostScreen.routeName);
          } else if (type == 'inbox') {
            setState(() {
              navigationTapped(3, postFrame: true);
            });
          } else if (type == 'explore') {
            setState(() {
              navigationTapped(1, postFrame: true);
            });
          } else if (type == 'search') {
            Navigator.of(context).pushNamed(SearchScreen.routeName);
          }
        });
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      // NOTE: This first action icon will only work on iOS.
      // In a real world project keep the same file name for both platforms.
      const ShortcutItem(
        type: 'post',
        localizedTitle: 'Post',
        icon: 'post',
      ),
      // NOTE: This second action icon will only work on Android.
      // In a real world project keep the same file name for both platforms.
      const ShortcutItem(type: 'inbox', localizedTitle: 'Inbox', icon: 'inbox'),
      const ShortcutItem(
          type: 'explore', localizedTitle: 'Explore', icon: 'explore'),
      const ShortcutItem(
          type: 'search', localizedTitle: 'Search', icon: 'search'),
    ]).then((value) {});
  }

  bool refresh = false;
  @override
  void initState() {
    try {
      Boxes.preferenceBox.put('start_time', DateTime.now().toString());
      WidgetsBinding.instance.addObserver(this);
      Functions().updateEmail();
      PushNotificationsManager().initMessage();
      if (Boxes.followingBox.isEmpty) {
        PreferencesUpdate().setFollowings();
      }
      if (Boxes.saveBox.isEmpty) {
        PreferencesUpdate().setSaves();
      }

      subscription = Connectivity()
          .onConnectivityChanged
          .listen((ConnectivityResult result) {
        if (ConnectivityResult.none == result) {
          snackbar('You are offline.', context,
              leadingIcon: Icon(FluentIcons.cloud_offline_24_regular));
        } else {
          String time = Boxes.preferenceBox.get('start_time');
          if (time != null) if (DateTime.parse(time)
              .add(Duration(seconds: 60))
              .isBefore(DateTime.now())) {
            snackbar("You're back online.", context,
                leadingIcon: Icon(
                  FluentIcons.cloud_24_regular,
                  color: Colors.greenAccent,
                ), seeMore: () {
              setState(() {
                _key = UniqueKey();
              });
            }, fnLabel: "Refresh App", duration: Duration(seconds: 10));
          }
        }
      });
      setLists();
    } catch (e) {
      refresh = true;
      print('awds');
    }
    super.initState();
  }

  Key _key = UniqueKey();

  @override
  void didChangeDependencies() {
    try {
      if (Hasura.jwtToken == null) {
        AuthService.firebaseAuth.authStateChanges().first.then((user) {
          try {
            user.getIdToken(true).then((token) {
              if (this.mounted)
                setState(() {
                  Hasura.jwtToken = token;
                });
            });
          } catch (e) {
            refresh = true;
          }
        });
      }

      Timer.periodic(Duration(minutes: 29), (Timer t) {
        AuthService.firebaseAuth.authStateChanges().first.then((user) {
          if (user != null)
            user.getIdToken(true).then((token) {
              Hasura.jwtToken = token;
            });
        });
      });
      _pageController = PageController(initialPage: 0);
      loadCurrentUser();
      handleStartUpLogic(context);
      quickActions();
    } catch (e) {
      refresh = true;
    }
    super.didChangeDependencies();
  }

  int keyIndex = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: scaffoldKey,
        body: Hasura.jwtToken == null
            ? Container(
                color: Theme.of(context).backgroundColor,
                child: Center(
                  child: circularProgress(),
                ),
              )
            : PageView(
                key: _key,
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: onPageChanged,
                children: <Widget>[
                  HomeScreen(ValueKey(keyIndex)),
                  ExploreScreen(),
                  Container(),
                  CommunicationTabbarScreen(),
                  ProfileScreen(
                    profileId: Boxes.currentUserBox.get('user_id'),
                    tabPage: true,
                  ),
                ],
              ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            // sets the background color of the `BottomNavigationBar`
            canvasColor: AppColors.navBar,
            // sets the active color of the `BottomNavigationBar` if `Brightness` is light
            primaryColor: Theme.of(context).primaryColor.withOpacity(0.8),
          ),
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 0.5))),
            height: kBottomNavigationBarHeight -
                8 +
                MediaQuery.of(context).padding.bottom,
            child: BottomNavigationBar(
              iconSize: 24,
              elevation: 10,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500, fontFamily: 'Stark Sans'),
              selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500, fontFamily: 'Stark Sans'),
              unselectedItemColor:
                  Theme.of(context).iconTheme.color == Colors.white
                      ? AppColors.navBarLight
                      : AppColors.navBarDark,
              selectedItemColor:
                  Theme.of(context).iconTheme.color == Colors.white
                      ? AppColors.navBarLight
                      : AppColors.navBarDark,
              backgroundColor: Theme.of(context).iconTheme.color == Colors.white
                  ? AppColors.navBarDark
                  : AppColors.navBarLight,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  label: 'Home',
                  icon: Icon(
                    FluentIcons.home_24_regular,
                    size: 23,
                  ),
                  activeIcon: Icon(
                    FluentIcons.home_24_filled,
                    size: 23,
                  ),
                ),
                BottomNavigationBarItem(
                  label: 'Explore',
                  icon: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      FlutterIcons.search_oct,
                      size: 19,
                      // size: 34,
                    ),
                  ),
                  activeIcon: Icon(
                    // FlutterIcons.md_planet_ion,
                    FlutterIcons.magnifying_glass_ent,
                    size: 24,
                  ),
                ),
                BottomNavigationBarItem(
                  label: 'Post',
                  icon: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Icon(
                            FlutterIcons.pen_square_faw5s,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                BottomNavigationBarItem(
                  label: 'Inbox',
                  icon: Icon(
                    FluentIcons.mail_inbox_24_regular,
                    size: 24,
                  ),
                  activeIcon: Icon(
                    FluentIcons.mail_inbox_24_filled,
                    size: 24,
                  ),
                ),
                BottomNavigationBarItem(
                  label: 'Profile',
                  icon: Container(
                    child: CircleAvatar(
                      maxRadius: 12,
                      backgroundImage: CachedNetworkImageProvider(Boxes
                              .currentUserBox
                              .get("avatar_url") ??
                          "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
                    ),
                  ),
                  activeIcon: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).iconTheme.color == Colors.white
                            ? AppColors.navBarLight
                            : AppColors.navBarDark,
                        shape: BoxShape.circle),
                    padding: EdgeInsets.all(1),
                    child: CircleAvatar(
                      maxRadius: 11,
                      backgroundImage: CachedNetworkImageProvider(Boxes
                              .currentUserBox
                              .get("avatar_url") ??
                          "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
                    ),
                  ),
                ),
              ],
              onTap: navigationTapped,
              currentIndex: _page,
            ),
          ),
        ),
      ),
    );
  }

  int pageIndex = 0;
  void navigationTapped(int page, {bool postFrame}) {
    if (page == 0 && pageIndex == 0) {
      if (this.mounted)
        setState(() {
          keyIndex = keyIndex + 1;
        });
    }
    if (page == 2) {
      showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          builder: (BuildContext context) {
            return Container(
                height: 210,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 70),
                decoration: new BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius: new BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          height: 5,
                          width: 32,
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10))),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      height: 60,
                      child: Material(
                          color: Colors.transparent,
                          borderRadius: new BorderRadius.circular(10),
                          child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context)
                                    .pushNamed(PostScreen.routeName);
                              },
                              child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Create new Post',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18),
                                      ),
                                      Icon(
                                        FluentIcons.edit_24_regular,
                                        color: Colors.black,
                                      )
                                    ],
                                  )))),
                      decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(10),
                          color: Color(0xFF1ee682)),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      height: 60,
                      child: Material(
                        borderRadius: new BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(DraftsScreen.routeName);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'See Drafts',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  '${Boxes.draftBox.keys.length}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 19,
                                      color: Colors.grey),
                                ),
                                Expanded(child: Container()),
                                Icon(FluentIcons.drafts_24_regular)
                              ],
                            ),
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: new BorderRadius.circular(10)),
                    )
                  ],
                ));
          });
      // Navigator.pushNamed(context, PostScreen.routeName);
    } else {
      if (postFrame == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pageController.jumpToPage(page);
        });
      } else
        _pageController.jumpToPage(page);
    }

    pageIndex = page;
  }

  Future loadCurrentUser() async {}
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    subscription.cancel();
  }

  void onPageChanged(int page) {
    if (this.mounted)
      setState(() {
        this._page = page;
      });
  }
}
