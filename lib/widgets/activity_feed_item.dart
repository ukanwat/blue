import 'package:flutter/material.dart';

import '../screens/profile_screen.dart';
import '../screens/post_view_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem({
    this.username,
    this.userId,
    this.type,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
    );
  }
  configureTextPreview() {
    if (type == 'upvote') {
      activityItemText = 'upvoted your post';
    } else if (type == 'follow') {
      activityItemText = 'is following you';
    } else if (type == 'comment') {
      activityItemText = 'replied: $commentData';
    } else {
      activityItemText = "Error: unknown type '$type'";
    }
  }




  @override
  Widget build(BuildContext context) {
    print('a');
    configureTextPreview();
    return GestureDetector(
       onTap: null,//showPost(context,postId: postId,userId:userId),//showing error TODO: fix this
          child: Padding(
        padding: EdgeInsets.only(bottom: 2.0),
        child: Container(
          color: Colors.white60,
          child: ListTile(
           
            title: GestureDetector(
              onTap: () => showProfile(context, profileId: userId),
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    style: TextStyle(fontSize: 14.0, color: Colors.black),
                    children: [
                      TextSpan(
                          text: username,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' '),
                      TextSpan(text: '$activityItemText')
                    ]),
              ),
            ),
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
          ),
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfileScreen(
        profileId: profileId,
      ),
    ),
  );
}
    showPost(BuildContext context,{String postId,String userId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostViewScreen(
          postId: postId,
          userId: userId,
        ),
      ),
    );
  }