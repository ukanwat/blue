import 'package:blue/screens/topic/topic_popular_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:blue/main.dart';
import 'home.dart';

class TopicPostsScreen extends StatefulWidget {
  static const routeName = 'topic-posts';

  @override
  _TopicPostsScreenState createState() => _TopicPostsScreenState();
}

class _TopicPostsScreenState extends State<TopicPostsScreen> {
  Map<String, dynamic> topicData;
  @override
  void didChangeDependencies() {
    topicData =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    super.didChangeDependencies();
  }
  //  TabController tabController;
  // Widget _tabBarView;
  // var scrollController = ScrollController();

  // @override
  // void initState() {
  //   super.initState();
  //   tabController = TabController(
  //     length: 2,
  //     vsync: this,
  //   );
  //   _tabBarView = TabBarView(children: [
  //     DemoTab(parentController : scrollController),
  //     DemoTab(parentController : scrollController),
  //   ]);
  // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: NestedScrollView(
//           controller: scrollController,

//           physics: ScrollPhysics(parent: PageScrollPhysics()),
//           headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
//             return <Widget>[
//               SliverList(
//                 delegate: SliverChildListDelegate(

//                     [Container(height: 300, color: Colors.blue)]),
//               ),
//             ];
//           },
//           body: SafeArea(
//             child: DefaultTabController(
//               length: 2,
//               child: Column(
//                 children: <Widget>[
//                   Container(
//                     child: TabBar(labelColor: Colors.grey, tabs: [
//                       Tab(
//                         text: 'One',
//                       ),
//                       Tab(
//                         text: 'two',
//                       )
//                     ]),
//                   ),
//                   Expanded(
//                     child: Container(child: _tabBarView),
//                   ),
//                 ],
//               ),
//             ),
//           )),
//     );
//   }
// }
// class DemoTab extends StatefulWidget {

//   DemoTab({
//     this.parentController
//   });

//   final ScrollController parentController;

//   DemoTabState createState() => DemoTabState();
// }

// class DemoTabState extends State<DemoTab>
//     with AutomaticKeepAliveClientMixin<DemoTab> {
//   @override
//   // TOO: implement wantKeepAlive
//   bool get wantKeepAlive => true;

//   ScrollController _scrollController;

//   ScrollPhysics ph;
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();

//     _scrollController.addListener((){

//       var innerPos      = _scrollController.position.pixels;
//       var maxOuterPos   = widget.parentController.position.maxScrollExtent;
//       var currentOutPos = widget.parentController.position.pixels;

//       if(innerPos >= 0 && currentOutPos < maxOuterPos) {

//         //print("parent pos " + currentOutPos.toString() + "max parent pos " + maxOuterPos.toString());
//         widget.parentController.position.jumpTo(innerPos+currentOutPos);

//       }else{
//         var currenParentPos = innerPos + currentOutPos;
//         widget.parentController.position.jumpTo(currenParentPos);
//       }

//     });

//     widget.parentController.addListener((){
//       var currentOutPos = widget.parentController.position.pixels;
//       if(currentOutPos <= 0) {
//         _scrollController.position.jumpTo(0);
//       }
//     });

//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       key: UniqueKey(),
//       controller: _scrollController,
//       itemBuilder: (b, i) {
//         return Container(
//           height: 50,
//           color: Colors.green,
//           margin: EdgeInsets.only(bottom: 3),
//           child: Text(
//             i.toString(),
//           ),
//         );
//       },
//       itemCount: 30,
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              SliverAppBar(
                  expandedHeight: 110,
                  pinned: true,
                  floating: true,
                  snap: true,
                  titleSpacing: 0.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: topicData['imageUrl'],
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                Colors.black.withOpacity(0.2),
                                Colors.black.withOpacity(0.2)
                              ],
                                  begin: Alignment(0, 0),
                                  end: Alignment.bottomCenter)),
                        )
                      ],
                    ),
                    collapseMode: CollapseMode.pin,
                    title: Text(
                      topicData['name'],
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: 'Techna Sans Regular'),
                    ),
                  ),
                  automaticallyImplyLeading: false,
                  leading: BackButton(
                    color: Colors.white,
                  ),
                  actions: <Widget>[
                    PopupMenuButton(
                      itemBuilder: (_) => [
                        PopupMenuItem(child: Text('follow'), value: 'follow'),
                      ],
                      icon: Icon(Icons.more_vert),
                      onSelected: (selectedValue) {
                        if (selectedValue == 'follow') {
                          followedTopicsRef
                              .document(currentUser.id)
                              .collection('userFollowedTopics')
                              .document(topicData['id'])
                              .setData({
                            'name': topicData['name'],
                            'imageUrl': topicData['imageUrl'],
                            'id': topicData['id'],
                            'info': topicData['info']
                          });
                        } else if (selectedValue == "") {
                          //
                        } else {
                          //
                        }
                      },
                    )
                  ],
                  elevation: 1,
                  backgroundColor: Theme.of(context).primaryColor),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    unselectedLabelStyle: TextStyle(
                        backgroundColor: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                    labelStyle:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor:
                        Theme.of(context).primaryColor.withAlpha(220),
                    tabs: [
                      Tab(
                        text: "Popular",
                      ),
                      Tab(text: "Today"),
                      Tab(text: "Top"),
                    ],
                  ),
                ),
                //  /
                // ),
              ),
            ];
          },
          body: TabBarView(
            physics: BouncingScrollPhysics(),
            children: [
              TopicPopularScreen(topicData['id']),
              Container(),
              Container()
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      padding: EdgeInsets.symmetric(horizontal: 28),
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}