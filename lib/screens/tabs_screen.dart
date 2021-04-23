// Flutter imports:
import 'dart:async';
import 'dart:ui';

import 'package:blue/screens/settings/general/drafts_screen.dart';
import 'package:blue/services/auth_service.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/services/push_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_icons/flutter_icons.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/communication_tabbar_screen.dart';
import 'package:blue/screens/post_screen.dart';
import './explore_screen.dart';
import './home.dart';
import './profile_screen.dart';
import 'home_screen.dart';
import '../services/dynamic_links.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = 'tabs';
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  PageController _pageController;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _page = 0;
  logout() {
    googleSignIn.signOut();
  }

  Future handleStartUpLogic(BuildContext context) async {
    // call handle dynamic links
    await DynamicLinksService.initDynamicLinks(context);
  }

  @override
  void initState() {
    PushNotificationsManager().init();
    if (Boxes.followingBox.isEmpty) {
      PreferencesUpdate().setFollowings();
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (Hasura.jwtToken == null) {
      AuthService.firebaseAuth.authStateChanges().first.then((user) {
        user.getIdToken(true).then((token) {
          setState(() {
            Hasura.jwtToken = token;
          });
        });
      });
    }

    Timer.periodic(Duration(minutes: 29), (Timer t) {
      AuthService.firebaseAuth.authStateChanges().first.then((user) {
        user.getIdToken(true).then((token) {
          Hasura.jwtToken = token;
        });
      });
    });
    _pageController = PageController(initialPage: 0);
    loadCurrentUser();
    handleStartUpLogic(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    print(currentUser.id);
    return Scaffold(
      key: scaffoldKey,
      body: Hasura.jwtToken == null
          ? Container()
          : PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: onPageChanged,
              children: <Widget>[
                HomeScreen(),
                ExploreScreen(),
                Container(),
                CommunicationTabbarScreen(),
                ProfileScreen(
                  profileId: Boxes.currentUserBox.get('user_id'),
                ),
              ],
            ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
          canvasColor: Colors.grey[900],
          // sets the active color of the `BottomNavigationBar` if `Brightness` is light
          primaryColor: Theme.of(context).primaryColor.withOpacity(0.8),
        ),
        child: SizedBox(
          height: 54,
          child: BottomNavigationBar(
            iconSize: 24,
            elevation: 10,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            unselectedItemColor: Color.fromRGBO(200, 200, 200, 1),
            selectedItemColor: Color.fromRGBO(250, 250, 250, 1),
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                label: 'Home',
                icon: Icon(
                  FluentIcons.home_24_filled,
                  size: 24,
                ),
                activeIcon: Icon(
                  FluentIcons.home_24_filled,
                  size: 24,
                ),
              ),
              BottomNavigationBarItem(
                label: 'Explore',
                icon: Icon(
                  FlutterIcons.search_faw,
                  size: 22,
                  // size: 34,
                ),
                activeIcon: Icon(
                  FlutterIcons.search_faw,
                  size: 22,
                ),
              ),
              BottomNavigationBarItem(
                label: 'Post',
                activeIcon: Container(
                    height: 24,
                    child: Image.asset("assets/images/stark-bnb-icon-wa.png")),
                icon: Container(
                    height: 24,
                    child: Image.asset("assets/images/stark-bnb-icon-wi.png")),
              ),
              BottomNavigationBarItem(
                label: 'Notifications',
                icon: Icon(
                  FluentIcons.alert_24_filled,
                  size: 24,
                ),
                activeIcon: Icon(
                  FluentIcons.alert_24_filled,
                  size: 24,
                ),
              ),
              BottomNavigationBarItem(
                label: 'Profile',
                icon: CircleAvatar(
                  maxRadius: 12,
                  backgroundImage: CachedNetworkImageProvider(Boxes
                          .currentUserBox
                          .get("avatar_url") ??
                      "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
                ),
                activeIcon: CircleAvatar(
                  maxRadius: 12,
                  backgroundImage: CachedNetworkImageProvider(Boxes
                          .currentUserBox
                          .get("avatar_url") ??
                      "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
                ),
              ),
            ],
            onTap: navigationTapped,
            currentIndex: _page,
          ),
        ),
      ),
    );
  }

  void navigationTapped(int page) {
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
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        'Select Option',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
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
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18),
                                      ),
                                      Icon(
                                        FluentIcons.edit_24_regular,
                                        color: Colors.white,
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
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18),
                                ),
                                Icon(FluentIcons.drafts_24_regular)
                              ],
                            ),
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: new BorderRadius.circular(10)),
                    )
                  ],
                ));
          });
      // Navigator.pushNamed(context, PostScreen.routeName);
    } else
      _pageController.jumpToPage(page);
  }

  Future loadCurrentUser() async {}
  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }
}
