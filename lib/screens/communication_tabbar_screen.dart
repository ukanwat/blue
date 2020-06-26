import 'package:blue/screens/activity_feed_screen.dart';
import 'package:blue/screens/chats_screen.dart';
import 'package:blue/screens/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:blue/main.dart';

class CommunicationTabbarScreen extends StatefulWidget {
  const CommunicationTabbarScreen({Key key}) : super(key: key);
  @override
  _CommunicationTabbarScreenState createState() =>
      _CommunicationTabbarScreenState();
}

class _CommunicationTabbarScreenState extends State<CommunicationTabbarScreen>
    with SingleTickerProviderStateMixin ,AutomaticKeepAliveClientMixin<CommunicationTabbarScreen> {
  TextEditingController searchController = TextEditingController();
  String title = 'Activity';
  clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => searchController.clear());
  }

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
  _tabController.addListener(() { 
    setState(() {

  switch(_tabController.index) {
    case 0:
    title = 'Notifications';
    break;
    case 1:
    title = 'Direct';
    break;
  }
  });
  });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  TabBar buildTabbar() {
    return const TabBar(
      tabs: <Widget>[
        Tab(
          icon: Icon(Icons.inbox),
        ),
        Tab(
          icon: Icon(Icons.chat_bubble),
        ),
      ],
    );
  }
bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    print(MediaQuery.of(context).viewInsets.top);
    print(currentUser.bio);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(54 + buildTabbar().preferredSize.height),
          child: AppBar(
            backgroundColor: Theme.of(context).canvasColor,
            elevation: 0,
            title: Row(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: CircleAvatar(
                    minRadius: 22,
                    maxRadius: 22,
                    backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl),
                  ),
                ),
                Text(
               title ,// title,
                  style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Techna Sans Regular',
                     ),
                ),
              ],
            ),
            titleSpacing: 0,
            bottom: PreferredSize(
              preferredSize: new Size(double.infinity, 36),
              child: TabBar(
                controller: _tabController,
                
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                labelColor: Theme.of(context).iconTheme.color,
                indicatorColor: Theme.of(context).iconTheme.color,
                tabs: <Widget>[
                  Tab(
                    icon: Icon(Icons.inbox),
                  ),
                  Tab(
                    icon: Icon(Icons.chat_bubble),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller:_tabController ,
          physics: BouncingScrollPhysics(), children: <Widget>[
          Container(
            color: Theme.of(context).backgroundColor,
            child: ActivityFeedScreen()),
          Container(
            color: Theme.of(context).backgroundColor,
            child: ChatsScreen()),
        ]),
      ),
    );
  }
}