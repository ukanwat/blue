import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../screens/profile_screen.dart';
import '../screens/post_view_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

String activityItemText;
String activityItemTextData;
String activityFeedDocumentId;
class ActivityFeedItem extends StatelessWidget {
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

  ActivityFeedItem({
    this.username,
    this.displayName,
    this.userId,
    this.type,
    this.title,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp,
    this.seen
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
   activityFeedDocumentId = doc.documentID;
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
      seen: doc['seen']
    );
  }
  configureTextPreview() {
     activityItemTextData =  "$commentData";
    if (type == 'upvote') {
      activityItemText = 'upvoted your post';
    } else if (type == 'follow') {
      activityItemText = 'is following you';
    } else if (type == 'comment') {
      activityItemText = 'commented on your post: \n';
     
    }  else if (type == 'comment reply') {
      activityItemText = 'replied on your comment: \n';
     
    }else {
       activityItemText = '$type \n';
    }
  }




  @override
  Widget build(BuildContext context) {

    configureTextPreview();
   
    bool seen = this.seen;
     if(this.seen == null)
    seen = false;
    return  Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 1,color: Theme.of(context).cardColor)),
            color: Theme.of(context).backgroundColor,
          ),
          
          child: Material(
            color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
  activityFeedRef.document(currentUser.id).collection('feedItems').document(activityFeedDocumentId).updateData({'seen' : true});
                                  },
                        child: Padding(
         padding: EdgeInsets.only(bottom: 2.0,top: 8) ,
                child: Column(
                  children: <Widget>[
                    ListTile(dense: true,
                     
                      title: RichText(
maxLines: 3,
overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                              style: TextStyle(fontSize: 15.0,),
                              children: [
                                TextSpan(
                                    text: username,
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'username todo', style: TextStyle(  fontWeight: FontWeight.w500, color:Theme.of(context).iconTheme.color.withOpacity(seen?0.8:1))),
                                TextSpan(text: ' $activityItemText', style: TextStyle(color:Theme.of(context).iconTheme.color.withOpacity(seen?0.8:1))),
                                 TextSpan(text: '$activityItemTextData',
                                 style: TextStyle(color:Theme.of(context).iconTheme.color.withOpacity(seen?0.8:1))
                                 )
                              ]),
                        ),
                      
                      leading: CircleAvatar(
                        maxRadius: 22,
                        minRadius: 22,
                        backgroundImage: CachedNetworkImageProvider(userProfileImg),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(
                      top: 4,
                      bottom: 8,
                      left: 12,
                      right: 12
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                                            child: Center(
                                              child: Text('$title',
                          maxLines: 2,overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400,color:Theme.of(context).iconTheme.color.withOpacity(seen?0.8:1)),
                          ),
                        ),
                        ),
                        Container(child: IconButton(icon: Icon(FluentIcons.open_24_regular,color: Colors.blue.withOpacity(0.8),),onPressed: (){},iconSize: 24,padding: EdgeInsets.all(0),))
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

showProfile(BuildContext context, {String profileId,String username}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfileScreen(
        profileId: profileId,
        profileUsername: username,
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