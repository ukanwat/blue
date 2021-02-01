// Flutter imports:
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
  @override
  _ActivityFeedScreenState createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen>
    with AutomaticKeepAliveClientMixin<ActivityFeedScreen> {
  List<ActivityFeedItem> data = [];
   DateTime time =DateTime.utc(2019);
  bool loading = true;

  getFeed() async {
    List feedData =await Hasura.getActivityFeed();
  data =feedData.map((doc) => ActivityFeedItem.fromDocument({
    "username": doc['data']['username'],
        "userId": doc['data']['user_id'],
        "displayName": doc['data']['name'],
        "type": doc['action'],
        "title": doc['data']['title'],
        "postId": doc['data']['post_id'],
        "userProfileImg": doc['data']['image_url'],
        "commentData": doc['data']['text'],
        "timestamp": doc['created_at'],
  
  })).toList();
  setState(() {
    loading = false;
  });
  }
   refreshFeed()async{
         
   }
  
 

  bool get wantKeepAlive => true;

@override
  void initState() {
    getFeed();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (loading == true) {
      return circularProgress();
    }
    if (data.length == 0) {
      return emptyState(context, 'No notifications yet', 'No messages',
          subtitle:
              'Stay tuned! Notifications about your activity will show up here');
    }
    return RefreshIndicator(
      onRefresh: ()async {
       await refreshFeed();
      },

          child: ListView.builder(
            itemBuilder: (context,i){
return data[i];
            },
            itemCount: data.length,
      ),
    );
  }
}
