// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Project imports:
import 'package:blue/screens/following_posts_screen.dart';
import 'package:blue/widgets/paginated_posts.dart';
import 'package:blue/widgets/tags_wrap.dart';
import '../widgets/header.dart';
import '../widgets/loading_indicator.dart';
import './home.dart';    
import '../widgets/bottom_bar.dart';                                                                                                       
                                                                                                                                                                       
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with
        AutomaticKeepAliveClientMixin<HomeScreen>,
        SingleTickerProviderStateMixin {                                                     
Widget posts = Container();
  bool followingPosts = false;
  bool topicLoading = true;
  bool banner = false;
OverlayEntry tabToggleBanner;
 

OverlayEntry toggleBanner() {
    return   
    OverlayEntry(
        builder: (context) => Positioned(
              left: MediaQuery.of(context).size.width * 0.5 - 60,                                                               
              top: 100,
              width: 120,
              height: 40,
              child: Material(
                  borderRadius: BorderRadius.circular(5),
                  elevation: 1.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      height: 70,
                      width: 240,
                      child: Text(
                        followingPosts ? 'Following' : 'Home',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).primaryColor),
                    ),
                  )),
            ));
  }


  showTagsSheet() {
    //  bottomBar(_scaffoldKey,'sssss',);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        child: Container(
          height: 300,
          width: MediaQuery.of(context).size.width,
          decoration: new BoxDecoration(
            color: Theme.of(context).canvasColor,
          ),
          child: TagsWrap()
        ),
      ),
    );
  }

 Future refreshPosts()async{
      setState(() {
        posts = PaginatedPosts(length: 2,query: postsRef.orderBy('timeStamp',descending: true,),key: UniqueKey(),);
      }); 
  }

  @override
  void didChangeDependencies() {
   
    super.didChangeDependencies();

    posts = PaginatedPosts(length: 2,query: postsRef.orderBy('timeStamp',descending: true,),key: UniqueKey(),);
    tabToggleBanner = toggleBanner();
  }
    bool get wantKeepAlive => true;
  @override
  Widget build(context) {
    super.build(context);
    return Scaffold( 
        backgroundColor: Theme.of(context).cardColor,
        appBar: header(
          context,implyLeading: false,
          title: Text(
            'FlipBoard',
            style: TextStyle(
              fontSize: 26,
              fontFamily: 'Techna Sans Regular',
            ),
          ),
          actionButton2: IconButton(
              icon: Icon(
                followingPosts
                    ? FluentIcons.person_24_regular
                    : FluentIcons.new_24_regular,
                size: 26,
              ),
              onPressed: () {
                setState(() {
                  followingPosts = !followingPosts;
                  banner = !banner;
                  if (banner)
                    Overlay.of(context).insert(tabToggleBanner);
                  else
                    tabToggleBanner?.remove();
                });
                Future.delayed(const Duration(milliseconds: 1800), () {
                  setState(() {
                    if (banner) {
                      tabToggleBanner?.remove();
                      banner = false;
                    }
                  });
                });
              }),
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
          child: 
          followingPosts
              ? FollowingPostsScreen()
              : RefreshIndicator(
                  onRefresh: () => refreshPosts(),
                  child:posts,
                ),
        ));
  }
}
                                                      
