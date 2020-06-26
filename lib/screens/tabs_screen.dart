import 'package:blue/models/user.dart';
import 'package:blue/providers/provider_widget.dart';
import 'package:blue/screens/communication_tabbar_screen.dart';
import 'package:blue/screens/post_screen.dart';
import 'package:blue/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'home_screen.dart';
import './explore_screen.dart';
import './profile_screen.dart';
import './home.dart';
import 'package:blue/main.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = 'tabs';
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
        HomeScreen(),
       // RaisedButton(onPressed: logout,child: Text('Logout'),),
          ExploreScreen(),
          Container(),
         CommunicationTabbarScreen(),
          ProfileScreen(profileId: currentUser.id,
          profileName: currentUser.displayName,
          ),
        ],
      ),

      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          
          // sets the background color of the `BottomNavigationBar`
          canvasColor: Theme.of(context).canvasColor,
          // sets the active color of the `BottomNavigationBar` if `Brightness` is light
          primaryColor: Theme.of(context).primaryColor.withOpacity(0.8),
          
        ),
        child: SizedBox(
          height: 50,
                  child: BottomNavigationBar(iconSize: 25,elevation: 10,
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: Theme.of(context).unselectedWidgetColor,
            selectedItemColor: Colors.blueAccent,

            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                 FlutterIcons.home_fea,
                 size: 26,
                ),
                activeIcon: Icon(
 FlutterIcons.home_fea,
                ),
                title: Container(height: 0.0),
              ),

              BottomNavigationBarItem(
                icon: Icon(
                  // FontAwesome.compass,
                FlutterIcons.search_oct,
                // size: 34,
                ),
                activeIcon: Icon(
                  // FontAwesome.compass,
                FlutterIcons.search_oct
                ),
                title: Container(height: 0.0),
              ),

              BottomNavigationBarItem(
                icon: Icon(
                 FlutterIcons.edit_fea,
                ),
                title: Container(height: 0.0),
              ),

              BottomNavigationBarItem(
                icon: Icon(FlutterIcons.notification_ent,
                   size: 24,
                ),
                activeIcon: Icon(FlutterIcons.notification_ent,
                   size: 24.4,
                ),
                title: Container(height: 0.0),
              ),

              BottomNavigationBarItem(
                icon: Icon(
                  FlutterIcons.user_faw5,
                  size: 23,
                ),
                title: Container(height: 0.0),
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
    if(page == 2){
      Navigator.pushNamed(context, PostScreen.routeName);
    }else
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    loadCurrentUser();
  }
  Future loadCurrentUser()async{
    
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