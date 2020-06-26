import 'package:blue/screens/home.dart';
import 'package:blue/screens/tag/tag_popular_screen.dart';
import 'package:blue/screens/tag/tag_recent_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blue/main.dart';

class TagScreen extends StatefulWidget {
  static const routeName = 'tag';
  @override
  _TagScreenState createState() => _TagScreenState();
}

class _TagScreenState extends State<TagScreen> {
  String tag;
  bool isFollowing = false;
  @override
  void didChangeDependencies() {
    tag = ModalRoute.of(context).settings.arguments;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          elevation: 0,
          actions: <Widget>[
            isFollowing
                ? IconButton(icon: Icon(Icons.more_vert,
                color: Theme.of(context).iconTheme.color,
                ), onPressed: null)
                : FlatButton(
                    child: Text(
                      'Follow',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () async { // TODO

                      if (isFollowing == false) {
                        followedTagsRef.document(currentUser.id).setData({
                          tag: 0,
                        }, merge: true);

                        setState(() {
                          isFollowing = true;
                        });
                      }
                    },
                  )
          ],
          backgroundColor: Theme.of(context).canvasColor,
          automaticallyImplyLeading: false,
          leading: CupertinoNavigationBarBackButton(color: Colors.blue),
          centerTitle: true,
          title: Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Text(
              '#$tag',
              overflow: TextOverflow.ellipsis,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.lightBlue),
          ),
          bottom: TabBar(
            unselectedLabelStyle: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600),
            labelStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Theme.of(context).iconTheme.color,
            labelColor: Theme.of(context).iconTheme.color,
            unselectedLabelColor: Theme.of(context).iconTheme.color.withAlpha(200),
            tabs: [
              Tab(
                text: "Latest",
              ),
              Tab(text: "Top"),
            ],
          ),
        ),
        body: TabBarView(children: [
          TagPopularScreen(tag),
          TagRecentScreen(tag),
        ]),
      ),
    );
  }
}
