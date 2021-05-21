// Flutter imports:
import 'package:blue/services/hasura.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

// Package imports:
//
//
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:math' as math;

// Project imports:
import 'package:blue/providers/comment.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/comment_reply.dart';
import 'package:blue/widgets/comment_vote_button.dart';

enum CommentVote { upvote, downvote }

class Comment extends StatefulWidget {
  final int id;
  final String username;
  final int userId;
  final String avatarUrl;
  final String comment;
  final DateTime timestamp;
  final int upvotes;
  final int downvotes;
  final int postId;
  final List replies;
  final bool showReplies;
  final int replyCount;
  final bool vote;
  Comment(
      {this.id,
      this.username,
      this.userId,
      this.avatarUrl,
      this.comment,
      this.timestamp,
      this.upvotes,
      this.downvotes,
      this.postId,
      this.replies,
      this.showReplies,
      this.replyCount,
      this.vote});

  factory Comment.fromDocument(Map doc, int postId, int docId) {
    return Comment(
      id: docId,
      username: doc['user']['username'],
      userId: doc['user_id'],
      comment: doc['data'],
      timestamp: DateTime.parse(doc['created_at']),
      avatarUrl: doc['user']['avatar_url'],
      upvotes: doc['upvotes'],
      downvotes: doc['downvotes'],
      postId: postId,
      replies: doc['comment_replies'],
      showReplies: true,
      replyCount: doc['reply_count'],
      vote: doc['user_vote'],
    );
  }

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  List<Widget> replyWidgets = [];
  bool repliesLoaded = false;
  int maxLines = 8;
  bool canExceedChanged = false;
  bool canExceed = false;
  insertVote(bool _vote, bool upinc, bool downinc) async {
    await Hasura.insertCommentVote(false, widget.id, _vote, upinc, downinc,
        postId: widget.postId, time: widget.timestamp.toString());
  }

  deleteVote(bool upinc, bool downinc) async {
    await Hasura.deleteCommentVote(false, widget.id, upinc, downinc,
        postId: widget.postId, time: widget.timestamp.toString());
  }

  toggleReplies() {
    setState(() {
      if (repliesLoaded == false) {
        if (widget.replies != null) {
          widget.replies.forEach((value) {
            replyWidgets.add(CommentReply(
              id: value['reply_id'],
              avatarUrl: value['user']['avatar_url'],
              comment: value['data'],
              commentId: widget.id,
              username: value['user']['username'],
              downvotes: value['downvotes'],
              postId: widget.postId,
              upvotes: value['upvotes'],
              userId: value['user_id'],
              timestamp: DateTime.parse(
                value['created_at'],
              ),
              vote: value['user_vote'],
            ));
          });
        }
        repliesLoaded = true;
      } else {
        replyWidgets = [];
        repliesLoaded = false;
      }
    });
  }

  CommentVote vote;
  @override
  void initState() {
    if (widget.showReplies == true) {
      toggleReplies();
    }
    if (widget.vote == true) {
      vote = CommentVote.upvote;
    }
    if (widget.vote == false) {
      vote = CommentVote.downvote;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int votes = widget.upvotes - widget.downvotes;
    return Consumer<CommentNotifier>(
        builder: (context, notifier, child) => Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 14,
                    ),
                    CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(widget
                              .avatarUrl ??
                          "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
                      maxRadius: 13,
                      minRadius: 13,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      widget.username,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      height: 3,
                      width: 3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${timeago.format(widget.timestamp)}',
                      style: TextStyle(fontSize: 13),
                    ),
                    Expanded(child: Container()),
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Transform.rotate(
                        angle: math.pi / 2.0,
                        child: PopupMenuButton(
                          padding: EdgeInsets.zero,
                          tooltip: 'Report Comment',
                          elevation: 2,
                          color: Theme.of(context).backgroundColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                  width: 0,
                                  color: Theme.of(context).canvasColor)),
                          itemBuilder: (_) => [
                            PopupMenuItem(
                                child: Text('Report'), value: 'Report'),
                          ],
                          icon: Icon(
                            Icons.more_vert,
                            size: 22,
                            color: Colors.grey,
                          ),
                          onSelected: (selectedValue) {
                            if (selectedValue == 'Report') {
                              notifier.focusNode.unfocus();
                              Hasura.insertCommentReport(widget.id, false);
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: LayoutBuilder(builder: (context, size) {
                          var span = TextSpan(
                            text: '${widget.comment}',
                            style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).iconTheme.color // TODO
                                ),
                          );
                          var tp = TextPainter(
                            maxLines: maxLines,
                            textAlign: TextAlign.left,
                            textDirection: TextDirection.ltr,
                            text: span,
                          );
                          tp.layout(maxWidth: size.maxWidth);
                          var exceeded = tp.didExceedMaxLines;
                          if (exceeded == true && canExceedChanged == false) {
                            canExceedChanged = true;
                            canExceed = true;
                          }
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text.rich(
                                  span,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: maxLines,
                                ),
                                if (canExceed)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (maxLines == 8) {
                                          maxLines = 100;
                                        } else {
                                          maxLines = 8;
                                        }
                                      });
                                      print(maxLines);
                                    },
                                    child: Text(
                                      exceeded ? 'See more' : 'See less',
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                    ),
                                  ),
                              ]);
                        }),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: <Widget>[
                          if (widget.replyCount > 0)
                            InkWell(
                              onTap: () {
                                toggleReplies();
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      repliesLoaded == true
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: Colors.blue,
                                      size: 18,
                                    ),
                                    Text(
                                      repliesLoaded == true
                                          ? 'Hide Replies'
                                          : '${widget.replyCount} Replies',
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          Expanded(child: Container()),
                          InkWell(
                            onTap: () {
                              notifier.changeCommentType({
                                'type': 'reply',
                                'ownerId': widget.userId,
                                'commentId': widget.id,
                                'referName': widget.username,
                                'commenterId': widget.userId,
                                'createdAt': widget.timestamp.toString(),
                              }, focus: true);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    FluentIcons.arrow_reply_16_filled,
                                    color: Colors.blue,
                                    size: 26,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          Text(
                            votes.toString(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 8),
                          Material(
                            child: InkWell(
                              onTap: () {
                                if (vote == CommentVote.downvote) {
                                  setState(() {
                                    vote = null;
                                  });
                                  deleteVote(null, false);
                                } else if (vote == CommentVote.upvote) {
                                  setState(() {
                                    vote = CommentVote.downvote;
                                  });

                                  insertVote(false, false, true);
                                } else {
                                  setState(() {
                                    vote = CommentVote.downvote;
                                  });
                                  insertVote(false, null, true);
                                }
                              },
                              child: Container(
                                  child: Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Transform.rotate(
                                    angle: math.pi,
                                    child: Icon(
                                      FluentIcons.keyboard_shift_16_filled,
                                      size: 24,
                                      color: vote == CommentVote.downvote
                                          ? Colors.blue
                                          : Colors.grey,
                                    )),
                              )),
                            ),
                          ),
                          SizedBox(width: 8),
                          Material(
                            child: InkWell(
                              onTap: () {
                                if (vote == CommentVote.upvote) {
                                  setState(() {
                                    vote = null;
                                  });

                                  deleteVote(false, null);
                                } else if (vote == CommentVote.downvote) {
                                  setState(() {
                                    vote = CommentVote.upvote;
                                  });

                                  insertVote(true, true, false);
                                } else {
                                  setState(() {
                                    vote = CommentVote.upvote;
                                  });
                                  insertVote(true, true, null);
                                }
                              },
                              child: Container(
                                  child: Padding(
                                padding: EdgeInsets.only(right: 0, left: 10),
                                child: Icon(
                                  FluentIcons.keyboard_shift_16_filled,
                                  size: 24,
                                  color: vote == CommentVote.upvote
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (repliesLoaded)
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                        ),
                        color: Theme.of(context).canvasColor,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).iconTheme.color ==
                                    Colors.white
                                ? Colors.black
                                : Colors.grey[400],
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 2,
                          ),
                        ],
                      ),

                      margin: EdgeInsets.only(left: 14, top: 3),
                      child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Column(children: [
                            if (notifier.userCommentReplies != null)
                              ...notifier.userCommentReplies[widget.id] ??
                                  [Container()],
                            ...replyWidgets
                          ])),
                      // decoration: BoxDecoration(
                      //   border: Border(
                      //       left: BorderSide(
                      //           color: Theme.of(context).cardColor, width: 3)),
                      // ),
                    ),
                  ),
                Container(
                  width: double.infinity,
                  color: Theme.of(context).cardColor,
                  height: 1,
                ),
              ],
            ));
  }
}
