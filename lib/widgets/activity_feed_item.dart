// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/services/go_to.dart';

String activityItemText;
String activityItemTextData;
String activityFeedDocumentId;
//TODO activity feed item only uploads user id of heisenberg
class ActivityFeedItem extends StatefulWidget {
  final String username;
  final String displayName;
  final String userId;
  final String type;
  final String title;
  final bool seen;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem(
      {this.username,
      this.displayName,
      this.userId,
      this.type,
      this.title,
      this.postId,
      this.userProfileImg,
      this.commentData,
      this.timestamp,
      this.seen});

  factory ActivityFeedItem.fromDocument(Map doc) {
    return ActivityFeedItem(
        username: doc['username'],
        userId: doc['userId'],
        displayName: doc['displayName'],
        type: doc['type'],
        title: doc['title'],
        postId: doc['postId'],
        userProfileImg: doc['userProfileImg'],
        commentData: doc['commentData'],
        timestamp: doc['timestamp'],
        seen: doc['seen']);
  }

  @override
  _ActivityFeedItemState createState() => _ActivityFeedItemState();
}

class _ActivityFeedItemState extends State<ActivityFeedItem> {
  configureTextPreview() {
    activityItemTextData = "${widget.commentData}";
    if (widget.type == 'upvote') {
      activityItemText = 'upvoted your post';
    } else if (widget.type == 'follow') {
      activityItemText = 'is following you';
    } else if (widget.type == 'comment') {
      activityItemText = 'commented on your post: \n';
    } else if (widget.type == 'comment reply') {
      activityItemText = 'replied on your comment: \n';
    } else {
      activityItemText = '${widget.type} \n';
    }
  }

  @override
  Widget build(BuildContext context) {
    configureTextPreview();

    bool seen = this.widget.seen;
    if (this.widget.seen == null) seen = false;
    return Container(
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(width: 1, color: Theme.of(context).cardColor)),
        color: Theme.of(context).backgroundColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // activityFeedRef
            //     .doc(currentUser.id)
            //     .collection('feedItems')
            //     .doc(activityFeedDocumentId)
            //     .update({'seen': true});
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: 2.0, top: 8),
            child: Column(
              children: <Widget>[
                ListTile(
                  dense: true,
                  title: RichText(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                        children: [
                          TextSpan(
                              text: widget.username,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: 'username todo',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color
                                      .withOpacity(seen ? 0.8 : 1))),
                          TextSpan(
                              text: ' $activityItemText',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color
                                      .withOpacity(seen ? 0.8 : 1))),
                          TextSpan(
                              text: '$activityItemTextData',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color
                                      .withOpacity(seen ? 0.8 : 1)))
                        ]),
                  ),
                  leading: Container(
                    child: GestureDetector(onTap: (){
                      GoTo().profileScreen(context, widget.userId);
                    },
                                        child: CircleAvatar(
                        maxRadius: 22,
                        minRadius: 22,
                        backgroundImage: CachedNetworkImageProvider(widget.userProfileImg),
                      ),
                    ),
                  ),
                ),
                 if(widget.type == 'follow')
                 SizedBox(height: 10,),
               if(widget.type != 'follow')
                Padding(
                  padding:
                      EdgeInsets.only(top: 0, bottom: 8, left: 12, right: 12),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: Text(
                            '${widget.title}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .iconTheme
                                    .color
                                    .withOpacity(seen ? 0.8 : 1)),
                          ),
                        ),
                      ),
                      Container(
                          child: IconButton(
                        icon: Icon(
                          FluentIcons.open_24_regular,
                          color: Colors.blue.withOpacity(0.8),
                        ),
                        onPressed: () {GoTo().showPost(context,widget.postId,);},
                        iconSize: 24,
                        padding: EdgeInsets.all(0),
                      ),)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}




