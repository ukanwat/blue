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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              SliverAppBar(
                expandedHeight: 180,
                pinned: false,
                title: Text(
                  topicData['name'],
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Row(
                    children: <Widget>[
                      Container(
                          height: 60,
                          width: 60,
                          child: Image.network(topicData['imageUrl'])),
                      Text(
                        topicData['name'],
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ),
                automaticallyImplyLeading: false,
                leading: BackButton(
                  color: Colors.grey[600],
                ),
                elevation: 1,
                backgroundColor: Colors.white,
              ),
              SliverAppBar(
                snap: true,
                floating: true,
                expandedHeight: 0,
                bottom: TabBar(
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor:
                      Theme.of(context).primaryColor.withAlpha(220),
                  tabs: [
                    Tab(text: "Recent"),
                    Tab(text: "Top"),
                  ],
                ),
              )
            ];
          },
          body: TabBarView(
            children: [Container(), Container()],
          ),
        ),
      ),
    );
  }
}
