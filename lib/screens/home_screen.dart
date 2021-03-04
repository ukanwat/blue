// Flutter imports:
import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Project imports:
import 'package:blue/screens/following_posts_screen.dart';
import 'package:blue/widgets/paginated_posts.dart';
import 'package:blue/widgets/tags_wrap.dart';
import '../widgets/header.dart';
import './home.dart';                                                                                                        
                                                                                                                                                                       
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
        posts = PaginatedPosts(length: 5,key: UniqueKey(),);
      }); 
  }

  @override
  void didChangeDependencies() {
   
    super.didChangeDependencies();

    posts = PaginatedPosts(length: 2,key: UniqueKey(),);
  }
    bool get wantKeepAlive => true;
  @override
  Widget build(context) {
    super.build(context);
    return Scaffold( 
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: header(
          context,implyLeading: false,
          title: Row(
            children: [
              Text(
                'Stark',
                style: TextStyle(
                  fontSize: 26,
                  fontFamily: 'Techna Sans Regular',
                ),
              ),
              followingPosts? Padding(

                padding: const EdgeInsets.only(left:10,top:8),
                child: Text('FOLLOWING',style: TextStyle(fontSize:12, fontWeight: FontWeight.w700,color: Colors.grey.withOpacity(0.7),)),
              ): Container(),
            ],
          ),
          actionButton2: IconButton(
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
                : Container(color: Theme.of(context).backgroundColor,
                  child: RefreshIndicator(
                      onRefresh: () => refreshPosts(),
                      child:posts,
                    ),
                ),
          ),
        );
  }
}
                                                      
