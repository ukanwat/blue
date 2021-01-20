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

class ActivityFeedScreen extends StatefulWidget {
  @override
  _ActivityFeedScreenState createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen>
    with AutomaticKeepAliveClientMixin<ActivityFeedScreen> {
  List<ActivityFeedItem> data = [];
  Timestamp timestamp = Timestamp.fromDate(DateTime.utc(2019));
  bool loading = true;

  cachedFeed() async {
    
  }
   refreshFeed()async{
         
   }
  
 

  bool get wantKeepAlive => true;

@override
  void initState() {
    cachedFeed();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // return StreamBuilder(
    //       stream: await activityStream(),
    //       builder: (context, snapshot){
    if (loading == true) {
      return circularProgress();
    }
    if (data.length == 0) {
      //TODO
      return emptyState(context, 'No notifications yet', 'No messages',
          subtitle:
              'Stay tuned! Notifications about your activity will show up here');
    }
    return RefreshIndicator(
      onRefresh: ()async {
       await refreshFeed();
        
      },

          child: ListView(
        children: data,
      ),
    );
  }
}
