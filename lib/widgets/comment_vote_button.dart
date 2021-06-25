// // Flutter imports:
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';
// import 'package:flutter/material.dart';

// // Package imports:
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_icons/flutter_icons.dart';

// // Project imports:
// //
// import '../screens/home.dart';
// import 'dart:math' as math;

// enum CommentVote { upvote, downvote }
// enum CommentType { comment, reply }

// class CommentVoteButton extends StatefulWidget {
//   final CommentType type;
//   final CommentVote vote;
//   final int postId;
//   final int commentId;
//   final int id;

//   CommentVoteButton(
//       {this.type, this.vote, this.postId, this.commentId, this.id});

//   @override
//   _CommentVoteButtonState createState() => _CommentVoteButtonState();
// }

// class _CommentVoteButtonState extends State<CommentVoteButton> {
//   bool change = false;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//         onTap: () {
//           setState(() {
//             change = !change;
//           });
//           if (widget.type == CommentType.reply) {
//             // commentsRef
//             //       .doc(widget.postId)
//             //       .collection('userComments')
//             //       .doc(widget.commentId)
//             //       .update( widget.vote == Vote.upvote ?{ 'replies.${widget.id}.upvotes':FieldValue.increment(1)}:
//             //       { 'replies.${widget.id}.downvotes':FieldValue.increment(1)}
//             //       );
//           } else {
//             // commentsRef
//             //   .doc(widget.postId)
//             //   .collection('userComments')
//             //   .doc(widget.commentId)
//             //   .update( widget.vote == Vote.upvote ?{ 'upvotes':FieldValue.increment(1)}:
//             //   { 'downvotes':FieldValue.increment(1)}
//             //   );
//           }
//         },
//         child: Container(
//             child: widget.vote == CommentVote.upvote
//                 ? Padding(
//                     padding: EdgeInsets.only(left: 10),
//                     child: Icon(
//                       FluentIcons.keyboard_shift_16_filled,
//                       size: 24,
//                       color: change ? Colors.blue : Colors.grey,
//                     ))
//                 : Padding(
//                     padding: EdgeInsets.only(right: 10),
//                     child: Transform.rotate(
//                         angle: math.pi,
//                         child: Icon(
//                           FluentIcons.keyboard_shift_16_filled,
//                           size: 24,
//                           color: change ? Colors.blue : Colors.grey,
//                         )),
//                   )));
//   }
// }
