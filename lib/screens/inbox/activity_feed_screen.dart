// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/loadmore_widget.dart';
import 'package:blue/widgets/paginated_posts.dart';
import 'package:flutter/painting.dart';
import '../../services/hasura.dart';
import '../../widgets/activity_feed_item.dart';
import '../../widgets/progress.dart';

class ActivityFeedScreen extends StatefulWidget {
  ActivityFeedScreen(Key key) : super(key: key);
  @override
  _ActivityFeedScreenState createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen>
    with AutomaticKeepAliveClientMixin<ActivityFeedScreen> {
  List<ActivityFeedItem> data = [];
  int offset = 0;
  int limit = 100;
  bool loaded = false;

  getFeed() async {
    List feedData = await Hasura.getNotifications(offset: offset, limit: limit);
    offset = offset + feedData.length;
    setState(() {
      int i = 0;
      feedData.forEach((doc) {
        i++;
        if (doc['activity'] != null && i > 8) {
          data.add(ActivityFeedItem.fromDocument(doc));
        } else if (doc['activity'] != null) {
          newItems.add(ActivityFeedItem.fromDocument(doc));
        }
      });
      loaded = true;
      print('loaded:$loaded');
    });
  }

  List newItems = [];

  @override
  void initState() {
    getFeed();
    super.initState();
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.builder(
        itemCount: loaded
            ? 2 +
                newItems.length +
                data.length +
                (data.length == 0 ? 1 : 0) +
                (newItems.length == 0 ? 1 : 0)
            : 4,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Column(
              children: [
                Container(
                  height: 38,
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('New',
                            style: TextStyle(
                                fontFamily: 'Stark Sans',
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).accentColor)),
                      ]),
                ),
                Divider(
                  color: Colors.grey.withOpacity(0.3),
                  height: 1,
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                )
              ],
            );
          }
          if (i == 1 && !loaded)
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: circularProgress(),
            );
          if (i > 0 && i < 9 && loaded && newItems.length > i - 1) {
            return newItems[i - 1] ?? Container();
          }
          if (newItems.length == 0 && loaded && i == 1) {
            return Container(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                    child: Text(
                  'No new Notifications',
                  style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Stark Sans'),
                )));
          }
          if ((i == 2 && !loaded) ||
              (i == newItems.length + 1 && loaded) ||
              (newItems.length == 0 && loaded && i == 2))
            return Column(
              children: [
                Container(
                  height: 38,
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Earlier',
                            style: TextStyle(
                              fontFamily: 'Stark Sans',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            )),
                      ]),
                ),
                Divider(
                  color: Colors.grey.withOpacity(0.3),
                  height: 1,
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                )
              ],
            );

          if (data.length == 0 && loaded) {
            return Container(
              height: 400,
              child: emptyState(context, 'No notifications yet', 'No messages',
                  subtitle:
                      'Stay tuned! Notifications about your activity will show up here'),
            );
          } else if (data.length != 0 && loaded) {
            return data[i - newItems.length - 2];
          } else if (!loaded) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: circularProgress(),
            );
          }
          return Container();
        });

    // LoadMore(
    //     onLoadMore: () async {
    //       return (await getFeed());
    //     },
    //     isFinish: loaded,
    //     child: ListView.builder(
    //       itemBuilder: (context, i) {
    //         return data[i];
    //       },
    //       itemCount: data.length,
    //     ));
  }
}
