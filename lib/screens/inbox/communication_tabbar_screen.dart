// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/inbox/activity_feed_screen.dart';
import 'package:blue/screens/inbox/chats_screen.dart';
import 'package:blue/services/boxes.dart';
import 'package:uuid/uuid.dart';

class CommunicationTabbarScreen extends StatefulWidget {
  const CommunicationTabbarScreen({Key key}) : super(key: key);
  @override
  _CommunicationTabbarScreenState createState() =>
      _CommunicationTabbarScreenState();
}

class _CommunicationTabbarScreenState extends State<CommunicationTabbarScreen>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<CommunicationTabbarScreen> {
  TextEditingController searchController = TextEditingController();
  String title = 'Activity';
  clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => searchController.clear());
  }

  TabController _tabController;
  Widget screen1;
  Widget screen2;
  @override
  void initState() {
    super.initState();
    screen1 = ActivityFeedScreen(UniqueKey());
    screen2 = ChatsScreen(
      archivedChats,
      UniqueKey(),
    );
    _tabController = new TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
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

  bool archivedChats = false;
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(54 + buildTabbar().preferredSize.height),
          child: AppBar(
            brightness: Theme.of(context).brightness,
            actions: [
              if (title == 'Direct')
                IconButton(
                  icon: Icon(
                    archivedChats
                        ? FluentIcons.archive_24_filled
                        : FluentIcons.archive_24_regular,
                  ),
                  onPressed: () {
                    String uuid = Uuid().v4();
                    setState(() {
                      archivedChats = !archivedChats;
                      screen2 = ChatsScreen(
                        archivedChats,
                        ValueKey(uuid),
                      );
                    });
                  },
                ),
              IconButton(
                icon: Icon(
                  FluentIcons.arrow_clockwise_24_filled,
                ),
                onPressed: () {
                  String uuid = Uuid().v4();
                  setState(() {
                    if ('Notifications' == title) {
                      screen1 = ActivityFeedScreen(UniqueKey());
                    } else
                      screen2 = ChatsScreen(
                        archivedChats,
                        ValueKey(uuid),
                      );
                  });
                },
              ),
              SizedBox(
                width: 10,
              )
            ],
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).backgroundColor,
            elevation: 0,
            title: Row(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: CircleAvatar(
                    minRadius: 22,
                    maxRadius: 22,
                    backgroundImage: CachedNetworkImageProvider(Boxes
                            .currentUserBox
                            .get('avatar_url') ??
                        "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
                  ),
                ),
                Text(
                  title, // title,
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
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 1, color: Colors.grey.withOpacity(0.3)))),
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
                      icon: Icon(
                        FluentIcons.mail_inbox_24_filled,
                        size: 26,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        FluentIcons.chat_24_filled,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
            controller: _tabController,
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Container(
                  color: Theme.of(context).backgroundColor, child: screen1),
              Container(
                  color: Theme.of(context).backgroundColor, child: screen2),
            ]),
      ),
    );
  }
}
