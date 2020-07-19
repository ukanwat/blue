import 'package:flutter/material.dart';
import '../screens/home.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String postId;
  final String commentId;
  final String id;

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
                            commentsRef
                                  .document(widget.postId)
                                  .collection('userComments')
                                  .document(widget.commentId)
                                  .updateData( widget.vote == Vote.upvote ?{ 'replies.${widget.id}.upvotes':FieldValue.increment(1)}:
                                  { 'replies.${widget.id}.downvotes':FieldValue.increment(1)}
                                  );
                          }else{
                                commentsRef
                                  .document(widget.postId)
                                  .collection('userComments')
                                  .document(widget.commentId)
                                  .updateData( widget.vote == Vote.upvote ?{ 'upvotes':FieldValue.increment(1)}:
                                  { 'downvotes':FieldValue.increment(1)}
                                  );
                          }

                        },
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(widget.vote == Vote.upvote ?FlutterIcons.arrow_up_bold_mco:FlutterIcons.arrow_down_bold_mco,size: 20,   color: voteButtonColor ,)));
  }
}