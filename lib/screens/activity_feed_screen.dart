// Flutter imports:
import 'package:blue/widgets/loadmore_widget.dart';
import 'package:blue/widgets/paginated_posts.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/widgets/empty_state.dart';
import '../widgets/activity_feed_item.dart';
import '../widgets/progress.dart';
import './home.dart';
import '../services/hasura.dart';

class ActivityFeedScreen extends StatefulWidget {
  ActivityFeedScreen(Key key) : super(key: key);
  @override
  _ActivityFeedScreenState createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen>
    with AutomaticKeepAliveClientMixin<ActivityFeedScreen> {
  List<ActivityFeedItem> data = [];
  DateTime time = DateTime.utc(2019);
  bool empty = false;
  int offset = 0;
  int limit = 100;
  bool loaded = false;
  getFeed() async {
    List feedData = await Hasura.getNotifications(offset: offset, limit: limit);
    print(feedData);
    offset = offset + feedData.length;
    setState(() {
      feedData.forEach((doc) {
        if (doc['activity'] != null) {
          data.add(ActivityFeedItem.fromDocument(doc));
        }
      });
    });
    if (feedData.length == 0) {
      setState(() {
        loaded = true;
      });
    }
    if (feedData.length == 0 && offset == 0) {
      setState(() {
        empty = true;
      });
    }

    return true;
  }

  refreshFeed() async {}

  bool get wantKeepAlive => true;

  @override
  void initState() {
    getFeed();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (empty == true) {
      return emptyState(context, 'No notifications yet', 'No messages',
          subtitle:
              'Stay tuned! Notifications about your activity will show up here');
    }
    return RefreshIndicator(
        onRefresh: () async {
          await refreshFeed();
        },
        child: LoadMore(
            onLoadMore: () async {
              return (await getFeed());
            },
            isFinish: loaded,
            child: ListView.builder(
              itemBuilder: (context, i) {
                return data[i];
              },
              itemCount: data.length,
            )));
  }
}
