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
    with AutomaticKeepAliveClientMixin<ExploreScreen> ,TickerProviderStateMixin{
  List<Post> posts = [];
  List<Tab> topicTabs = [ Tab(child: Text('All',style: TextStyle(fontFamily: 'OpenSans',fontWeight: FontWeight.w600,fontSize: 16))
        )];
    List<Widget> topicViews = [CategoryPostsScreen( 'All')];
 bool  loading = true; 
 TabController tabController;
   List<String> t = ['Humor','Art & Design','Technology','News','Entertainment','Lifestyle','Science'];
  @override
  void initState() {
     

    getTopics();
    getExplore();
    super.initState();
  }

  getExplore() async {
    QuerySnapshot snapshot = await postsRef.limit(5).get();
    List<Post> posts = snapshot.docs.map((doc) => Post.fromDocument(doc.data())).toList();
    setState(() {
      this.posts = posts;
      loading = false;
    });
  }
 
   showTagsSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      builder: (context) => TagsWrap()
    );
  }
  getTopics() async {
    QuerySnapshot snapshot = await topicsRef
        .get();
      
    setState(() {
      List _topics =  snapshot.docs.first.data()['topics'];
      print(_topics);
      if (_topics !=  t){
         List<Tab> _topicTabs = [];
            List<Widget> _topicViews = [];
      _topics.forEach((topic) {
        _topicTabs.add(
          Tab(child: Text(topic,style: TextStyle(fontFamily: 'OpenSans',fontWeight: FontWeight.w600,fontSize: 16))
        ));
       
        _topicViews.add( CategoryPostsScreen( topic));
      });
      topicViews = _topicViews;
      topicTabs =_topicTabs;

     tabController = new TabController(length: topicTabs.length , vsync: this);
      }
       
    });
  }
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        appBar: AppBar(centerTitle: true,backgroundColor: Theme.of(context).backgroundColor,elevation: 1.2,
          title: Text(
            'Explore',
            style: TextStyle(
              fontFamily: 'Techna Sans Regular',
            ),
          ),
        bottom: loading? PreferredSize(child: Container(), preferredSize: Size.fromHeight(0)): PreferredSize(preferredSize: Size.fromHeight(40),
                  child: Container(height: 40,margin:EdgeInsets.only(left: 8,right: 8,bottom: 6,top: 4),
                    child: TabBar(
            
            indicatorWeight: 2.5,indicatorPadding: EdgeInsets.symmetric(vertical: 1,horizontal: 15),


            isScrollable: true,
            controller: tabController,indicatorColor: Colors.deepOrange,labelPadding: EdgeInsets.symmetric(horizontal: 10),
            tabs: topicTabs,),
                  ),
        ),
          actions:<Widget>[ IconButton(
              icon: Icon(FluentIcons.add_24_regular,size: 29,
                  color: Theme.of(context).iconTheme.color),
              onPressed: () {
                showTagsSheet();
              })],
          leading: IconButton(
            icon: Icon(FlutterIcons.search_oct,
            
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(SearchScreen.routeName);
            },
            color: Theme.of(context).iconTheme.color
          ),
          
        ),
        body: loading? circularProgress():TabBarView(
children: topicViews,
controller: tabController,
        ));
  }
}
