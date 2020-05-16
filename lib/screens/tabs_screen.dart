import 'package:blue/screens/communication_tabbar_screen.dart';
import 'package:blue/screens/post_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import './explore_screen.dart';
import './chats_screen.dart';
import './profile_screen.dart';
import './home.dart';
import './activity_feed_screen.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  PageController _pageController;

  int _page = 0;
    logout() {
    googleSignIn.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: <Widget>[
        HomeScreen(currentUser: currentUser),
       // RaisedButton(onPressed: logout,child: Text('Logout'),),
          ExploreScreen(),
          Container(),
         CommunicationTabbarScreen(),
          ProfileScreen(profileId: currentUser?.id),
        ],
      ),

      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
          canvasColor: Colors.transparent,
          // sets the active color of the `BottomNavigationBar` if `Brightness` is light
          primaryColor: Theme.of(context).primaryColor.withOpacity(0.8),
          
        ),
        child: BottomNavigationBar(iconSize: 28,elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              title: Container(height: 0.0),
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.explore,
              ),
              title: Container(height: 0.0),
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle_outline,
              ),
              title: Container(height: 0.0),
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              title: Container(height: 0.0),
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              title: Container(height: 0.0),
            ),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),
      ),

    );
  }

  void navigationTapped(int page) {
    if(page == 2){
      Navigator.pushNamed(context, PostScreen.routeName);
    }else
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

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