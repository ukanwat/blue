// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_icons/flutter_icons.dart';

// Project imports:
import '../screens/home.dart';

enum Vote{
  upvote,
  downvote
}
enum CommentType{
  comment,
  reply
}
class CommentVoteButton extends StatefulWidget {
  final CommentType type;
  final Vote vote;
  final int postId;
  final int commentId;
  final int id;

  CommentVoteButton(
    {
      this.type,
      this.vote,
      this.postId,
      this.commentId,
      this.id
    }
  );

  @override
  _CommentVoteButtonState createState() => _CommentVoteButtonState();
}

class _CommentVoteButtonState extends State<CommentVoteButton> {
  Color voteButtonColor = Colors.grey;
  @override
  Widget build(BuildContext context) {
    return                     GestureDetector(
                        onTap: () {
                          setState((){
                            voteButtonColor = Colors.blue;
                          });
                          if(widget.type == CommentType.reply){
                            // commentsRef
                            //       .doc(widget.postId)
                            //       .collection('userComments')
                            //       .doc(widget.commentId)
                            //       .update( widget.vote == Vote.upvote ?{ 'replies.${widget.id}.upvotes':FieldValue.increment(1)}:
                            //       { 'replies.${widget.id}.downvotes':FieldValue.increment(1)}
                            //       );
                          }else{
                                // commentsRef
                                //   .doc(widget.postId)
                                //   .collection('userComments')
                                //   .doc(widget.commentId)
                                //   .update( widget.vote == Vote.upvote ?{ 'upvotes':FieldValue.increment(1)}:
                                //   { 'downvotes':FieldValue.increment(1)}
                                //   );
                          }

                        },
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(widget.vote == Vote.upvote ?FlutterIcons.arrow_up_bold_mco:FlutterIcons.arrow_down_bold_mco,size: 20,   color: voteButtonColor ,)));
  }
}
