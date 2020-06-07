import 'dart:math';

import 'package:blue/widgets/custom_image.dart';
import 'package:blue/widgets/header.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
                expandedHeight: 100,
                pinned: true,
                floating: true,
                snap: true,
                titleSpacing: 0.0,
                flexibleSpace: FlexibleSpaceBar(
                  background:
                      cachedNetworkImage(context, topicData['imageUrl']),
                  collapseMode: CollapseMode.pin,
                  title: Text(
                    topicData['name'],
                    style: TextStyle(
                        fontSize: 20, color: Theme.of(context).primaryColor,
                        fontFamily: 'Techna Sans Regular'
                        ),
                  ),
                ),
                automaticallyImplyLeading: false,
                leading: BackButton(
                  color: Theme.of(context).primaryColor,
                ),
                elevation: 1,
                backgroundColor: Colors.white,
              ),
              SliverPersistentHeader(
                //             child: PreferredSize(
                // preferredSize: Size.fromHeight(0),
                //               child: SliverAppBar(
                // snap: true,
                // floating: true,
                // expandedHeight: 0,
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  height: 45.0,
                  //  maxHeight: 200.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: TabBar(
                      unselectedLabelStyle:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                          labelStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
                ),
                //  /
                // ),
              )
            ];
          },
          body: TabBarView(
            physics: BouncingScrollPhysics(),
            children: [Container(), Container(), Container()],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.height,
    // @required this.maxHeight,
    @required this.child,
  });
  final double height;
  // final double maxHeight;
  final Widget child;
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height; //max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
    //  maxHeight != oldDelegate.maxHeight ||
    //     minHeight != oldDelegate.minHeight ||
    //     child != oldDelegate.child;
  }
}
