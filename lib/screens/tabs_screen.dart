// Flutter imports:
import 'dart:async';
import 'dart:ui';

import 'package:blue/screens/settings/general/drafts_screen.dart';
import 'package:blue/services/auth_service.dart';
import 'package:blue/services/hasura.dart';
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
  void didChangeDependencies() {
    Timer.periodic(Duration(minutes: 29), (Timer t) {
      AuthService().firebaseAuth.authStateChanges().first.then((user) {
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
                  profileId: currentUser.id,
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
          height: 56,
          child: BottomNavigationBar(
            iconSize: 26,
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
                  FlutterIcons.home_fea,
                  size: 26,
                ),
                activeIcon: Icon(
                  FlutterIcons.home_fea,
                ),
              ),
              BottomNavigationBarItem(
                label: 'Explore',
                icon: Icon(
                  FlutterIcons.compass_fea, size: 26,
                  // size: 34,
                ),
                activeIcon: Icon(
                  // FontAwesome.compass,
                  FlutterIcons.compass_fea, size: 26,
                ),
              ),
              BottomNavigationBarItem(
                label: 'Post',
                icon: Icon(
                  FlutterIcons.edit_fea,
                ),
              ),
              BottomNavigationBarItem(
                label: 'Notifications',
                icon: Icon(
                  FlutterIcons.notification_ent,
                  size: 23.6,
                ),
                activeIcon: Icon(
                  FlutterIcons.notification_ent,
                  size: 23.6,
                ),
              ),
              BottomNavigationBarItem(
                label: 'Profile',
                icon: Icon(
                  FlutterIcons.user_faw5,
                  size: 23,
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
                          color: Colors.blue[900]),
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
