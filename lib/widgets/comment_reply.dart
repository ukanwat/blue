import 'dart:convert';

import 'package:blue/main.dart';
import 'package:blue/providers/comment.dart';
import 'package:blue/screens/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart'  as timeago; 
import 'comment_vote_button.dart';

class CommentReply extends StatelessWidget {
    final String id;
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final String commentId;
   final int upvotes;
   final int downvotes;
   final String postId;
   final String referName;
   final Timestamp timestamp;
  CommentReply({
    this.id,
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.commentId,
    this.upvotes,
    this.downvotes,
    this.postId,
    this.referName,
    this.timestamp
  });
  @override
  Widget build(BuildContext context) {
   int  votes = upvotes - downvotes;
    return   Consumer<CommentNotifier>(
                          builder: (context,notifier,child) =>Column(
      children: <Widget>[ Divider(
                   color: Colors.grey,
                   height: 18,
                   thickness: 0.2,
                 ),
        ListTile(
         title: Row(
           children: <Widget>[
                
             Text('currentUser.username',style: TextStyle(fontSize: 15,color: Colors.grey),),
                Container(
                        margin: EdgeInsets.symmetric(horizontal: 2),
                       height: 3,
                       width: 3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
 color: Colors.grey,
                        ),
                      ),
                  Text(   '${timeago.format(timestamp.toDate())}',
                  style: TextStyle(
                    fontSize: 13
                  ),
                  ),
                  Expanded(child: Container()),
            SizedBox(
              height: 24,
              width: 24,
                          child: PopupMenuButton(
                        padding: EdgeInsets.zero,
                        
                        color: Theme.of(context).canvasColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                            side: BorderSide(width: 0,
                            color: Theme.of(context).canvasColor
                            )
                        ),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                              child: Text('Report'),
                              value:'Report'),
                        ],
                        icon: Icon(Icons.more_vert,
                        size: 22,
                        color: Colors.grey,
                        ),

                        onSelected: (selectedValue) async {
                          if (selectedValue == 'Report') {
                            commentsRef
                                  .document(postId)
                                  .collection('userComments')
                                  .document(commentId)
                                  .updateData( {'replies.$id.reports': FieldValue.increment(1)});
                          }
                        },
                    ),
            )
           ],
         ),
         subtitle: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
           children: <Widget>[
             RichText(text:TextSpan(text:referName != null?'@$referName ': '',style: TextStyle(fontSize: 16,color: Colors.blue),
             children: <TextSpan>[TextSpan(text:'$comment',style: TextStyle(fontSize: 16,color: Theme.of(context).iconTheme.color),
            
             ),]
             ),
              // make sure of color
             maxLines: 5,  
                   overflow: TextOverflow.ellipsis,     
             ),
Row(children: <Widget>[
              
         Expanded(child: Container()),
                          InkWell(
                            onTap: () {
                              notifier.changeCommentType({
                                'type': 'reply',
                                'ownerId': userId,
                                'commentId': commentId,
                                'referName': username,
                              }, focus: true);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.reply,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  Text(
                                    'Reply',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 30,),
        CommentVoteButton(
          type: CommentType.reply,
          vote: Vote.upvote,
          commentId: commentId,
          id: id,
          postId: postId,
        ),
          SizedBox(width: 8),
          Text(votes.toString(),style: TextStyle(fontSize: 18,color: Colors.blue),), SizedBox(width: 8),
                      CommentVoteButton(
                        type: CommentType.reply,
          vote: Vote.downvote,
          commentId: commentId,
          id: id,
          postId: postId,
        ),
        ],),


           ],
         ),
         
         leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(avatarUrl),
         maxRadius: 13,
         minRadius: 13,
         ),
     // subtitle: Text(timestamp.toDate().toString())//timeago.format(timestamp.toDate()))
        ),
      
    
      ],
      
     ) );
  }
}


