// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';

// Project imports:
import 'package:blue/screens/category_posts_screen.dart';
import 'package:blue/screens/search_screen.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/tags_wrap.dart';
import 'home.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with
        AutomaticKeepAliveClientMixin<ExploreScreen>,
        TickerProviderStateMixin {
  List<Post> posts = [];

  Widget tabView;
  List<Tab> topicTabs = [
    Tab(
        child: Text('Everything',
            style: TextStyle(
              fontFamily: 'Stark Sans',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            )))
  ];
  bool loading = true;
  TabController tabController;
  List<String> t = [
    'Humor',
    'Art & Design',
    'Tech & Science',
    'News',
    'Entertainment',
    'Lifestyle'
  ];
  int index;
  @override
  void initState() {
    getTopics();
    tabView = CategoryPostsScreen('All', UniqueKey());
    super.initState();
  }

  showTagsSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        builder: (context) => TagsWrap());
  }

  getTopics() async {
    t.forEach((topic) {
      topicTabs.add(Tab(
          child: Text(topic,
              style: TextStyle(
                  fontFamily: 'Stark Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16))));
    });
    setState(() {
      tabController = new TabController(length: t.length + 1, vsync: this);
      loading = false;
    });
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        appBar: AppBar(
          centerTitle: true,
          brightness: Theme.of(context).brightness,
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0,
          title: Text(
            'Explore',
            style: TextStyle(
              fontFamily: 'Techna Sans Regular',
            ),
          ),
          leading: IconButton(
              icon: Icon(
                FlutterIcons.search_oct,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(SearchScreen.routeName);
              },
              color: Theme.of(context).iconTheme.color),
        ),
        body: Column(
          children: [
            loading
                ? Container(
                    height: 0,
                    color: Theme.of(context).backgroundColor,
                  )
                : Container(
                    color: Theme.of(context).backgroundColor,
                    height: 40,
                    padding:
                        EdgeInsets.only(left: 8, right: 8, bottom: 0, top: 0),
                    child: TabBar(
                      onTap: (i) {
                        setState(() {
                          index = i - 1;
                        });
                      },
                      indicatorWeight: 2.5,
                      indicatorPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      isScrollable: true,
                      controller: tabController,
                      indicatorColor: Colors.deepOrange,
                      // labelPadding:
                      //     EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      tabs: topicTabs,
                    ),
                  ),
            Expanded(
              child: CategoryPostsScreen(
                  index == null || index == -1 ? 'All' : t[index],
                  ValueKey(index == null || index == -1 ? 'All' : t[index])),
            ),
          ],
        ));
  }
}
