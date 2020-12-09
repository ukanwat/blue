import 'package:flutter/material.dart';

import './home.dart';
import '../widgets/progress.dart';
import '../widgets/activity_feed_item.dart';
import 'package:blue/main.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityFeedScreen extends StatefulWidget {
  @override
  _ActivityFeedScreenState createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> with AutomaticKeepAliveClientMixin<ActivityFeedScreen>{
 
  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .doc(currentUser.id)
        .collection('feedItems')
        .limit(50)
        .get();
    List<ActivityFeedItem> feedItems = [];
    snapshot.docs.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc.data()));
      // print('Activity Feed Item: ${doc.data}');
    });
    return feedItems;
  }
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
          future: getActivityFeed(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return circularProgress();
            }
            return ListView(children: snapshot.data,);
          },
      
    );
  }
}