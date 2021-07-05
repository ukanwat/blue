// Flutter imports:
import 'package:blue/services/functions.dart';
import 'package:blue/widgets/action_button.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Project imports:
import 'package:blue/constants/strings.dart';
import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/services/go_to.dart';
import 'package:blue/services/notification_functions.dart';
import 'package:blue/widgets/custom_image.dart';

class ActivityFeedItem extends StatefulWidget {
  final String imageUrl;
  final int sourceId;
  final String action;
  final String title;
  final bool seen;
  final String avatarUrl;
  final String data;
  final DateTime time;

  ActivityFeedItem(
      {this.imageUrl,
      this.sourceId,
      this.action,
      this.title,
      this.avatarUrl,
      this.data,
      this.time,
      this.seen});

  factory ActivityFeedItem.fromDocument(Map doc) {
    return ActivityFeedItem(
        sourceId: doc['source_id'],
        imageUrl: doc['activity']['image_url'],
        action: doc['action'],
        title: doc['activity']['title'],
        avatarUrl: doc['activity']['avatar_url'],
        data: doc['activity']['data'],
        time: DateTime.parse(doc['created_at']),
        seen: doc['seen']);
  }

  @override
  _ActivityFeedItemState createState() => _ActivityFeedItemState();
}

class _ActivityFeedItemState extends State<ActivityFeedItem> {
  // configureTextPreview() {
  //   activityItemTextData = "${widget.data}";
  //   if (widget.action == 'upvote') {
  //     activityItemText = 'upvoted your post';
  //   } else if (widget.action == 'follow') {
  //     activityItemText = 'is following you';
  //   } else if (widget.action == 'comment') {
  //     activityItemText = 'commented on your post: \n';
  //   } else if (widget.action == 'comment reply') {
  //     activityItemText = 'replied on your comment: \n';
  //   } else {
  //     activityItemText = '${widget.action} \n';
  //   }
  // }
  Widget trailing;
  @override
  Widget build(BuildContext context) {
    if (widget.action == 'follow') {
      trailing = ActionButton(() {
        Functions().handleFollowUser(widget.sourceId);
      }, Colors.blue, 'Follow', true);
    }

    return ListTile(
        onTap: () {
          if (widget.action == 'follow') {
            NotifFunctions.goToProfile(widget.sourceId, context);
          }
          if (widget.action == 'comment') {
            NotifFunctions.goToComment(widget.sourceId, context);
          }
          if (widget.action == 'comment_reply') {
            NotifFunctions.goToCommentReply(widget.sourceId, context);
          }
        },
        trailing: trailing ??
            Icon(
              FluentIcons.arrow_right_16_filled,
              color: Colors.blue,
            ),
        title: Text(
          widget.title ?? '',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        subtitle: Text(
          widget.data ?? '',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).iconTheme.color.withOpacity(0.94)),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
            widget.avatarUrl == null || widget.avatarUrl == '_'
                ? Strings.emptyAvatarUrl
                : widget.avatarUrl,
          ),
        ));

    // configureTextPreview();

    // bool seen = this.widget.seen;
    // if (this.widget.seen == null) seen = false;
    // return Container(
    //   decoration: BoxDecoration(
    //     border: Border(
    //         bottom: BorderSide(width: 1, color: Theme.of(context).cardColor)),
    //     color: Theme.of(context).backgroundColor,
    //   ),
    //   child: Material(
    //     color: Colors.transparent,
    //     child: InkWell(
    //       onTap: () {
    //         // activityFeedRef
    //         //     .doc(currentUser.id)
    //         //     .collection('feedItems')
    //         //     .doc(activityFeedDocumentId)
    //         //     .update({'seen': true});
    //       },
    //       child: Padding(
    //         padding: EdgeInsets.only(bottom: 2.0, top: 8),
    //         child: Column(
    //           children: <Widget>[
    //             ListTile(
    //               dense: true,
    //               title: RichText(
    //                 maxLines: 3,
    //                 overflow: TextOverflow.ellipsis,
    //                 text: TextSpan(
    //                     style: TextStyle(
    //                       fontSize: 15.0,
    //                     ),
    //                     children: [
    //                       TextSpan(
    //                           text: widget.username,
    //                           style: TextStyle(fontWeight: FontWeight.bold)),
    //                       TextSpan(
    //                           text: 'username todo',
    //                           style: TextStyle(
    //                               fontWeight: FontWeight.w500,
    //                               color: Theme.of(context)
    //                                   .iconTheme
    //                                   .color
    //                                   .withOpacity(seen ? 0.8 : 1))),
    //                       TextSpan(
    //                           text: ' $activityItemText',
    //                           style: TextStyle(
    //                               color: Theme.of(context)
    //                                   .iconTheme
    //                                   .color
    //                                   .withOpacity(seen ? 0.8 : 1))),
    //                       TextSpan(
    //                           text: '$activityItemTextData',
    //                           style: TextStyle(
    //                               color: Theme.of(context)
    //                                   .iconTheme
    //                                   .color
    //                                   .withOpacity(seen ? 0.8 : 1)))
    //                     ]),
    //               ),
    //               leading: Container(
    //                 child: GestureDetector(onTap: (){
    //                   GoTo().profileScreen(context, widget.sourceId);
    //                 },
    //                                     child: CircleAvatar(
    //                     maxRadius: 22,
    //                     minRadius: 22,
    //                     backgroundImage: CachedNetworkImageProvider(widget.avatarUrl),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //              if(widget.action == 'follow')
    //              SizedBox(height: 10,),
    //            if(widget.action != 'follow')
    //             Padding(
    //               padding:
    //                   EdgeInsets.only(top: 0, bottom: 8, left: 12, right: 12),
    //               child: Row(
    //                 children: <Widget>[
    //                   Expanded(
    //                     child: Center(
    //                       child: Text(
    //                         '${widget.title}',
    //                         maxLines: 2,
    //                         overflow: TextOverflow.ellipsis,
    //                         style: TextStyle(
    //                             fontSize: 16,
    //                             fontWeight: FontWeight.w500,
    //                             color: Theme.of(context)
    //                                 .iconTheme
    //                                 .color
    //                                 .withOpacity(seen ? 0.8 : 1)),
    //                       ),
    //                     ),
    //                   ),
    //                   Container(
    //                       child: IconButton(
    //                     icon: Icon(
    //                       FluentIcons.open_24_regular,
    //                       color: Colors.blue.withOpacity(0.8),
    //                     ),
    //                     onPressed: () {GoTo().showPost(context,widget.postId,);},
    //                     iconSize: 24,
    //                     padding: EdgeInsets.all(0),
    //                   ),)
    //                 ],
    //               ),
    //             )
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
