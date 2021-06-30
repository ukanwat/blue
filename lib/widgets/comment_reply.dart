// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

// Project imports:
import 'package:blue/providers/comment.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/services/functions.dart';
import 'package:blue/services/go_to.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/comment.dart';
import 'package:blue/widgets/progress.dart';
import 'comment_vote_button.dart';

int maxLines = 8;
bool canExceedChanged = false;
bool canExceed = false;

class CommentReply extends StatefulWidget {
  final int id;
  final String username;
  final int userId;
  final String avatarUrl;
  final String comment;
  final int commentId;
  final int upvotes;
  final int downvotes;
  final int postId;
  final DateTime timestamp;
  final bool vote;
  CommentReply(
      {this.id,
      this.username,
      this.userId,
      this.avatarUrl,
      this.comment,
      this.commentId,
      this.upvotes,
      this.downvotes,
      this.postId,
      this.timestamp,
      this.vote});

  @override
  _CommentReplyState createState() => _CommentReplyState();
}

class _CommentReplyState extends State<CommentReply> {
  CommentVote vote;

  commentVoteButton(bool up, bool change) {
    return Container(
        child: up
            ? Padding(
                padding: EdgeInsets.only(left: 10),
                child: Icon(
                  FluentIcons.keyboard_shift_16_filled,
                  size: 24,
                  color: change ? Colors.blue : Colors.grey,
                ))
            : Padding(
                padding: EdgeInsets.only(right: 10),
                child: Transform.rotate(
                    angle: math.pi,
                    child: Icon(
                      FluentIcons.keyboard_shift_16_filled,
                      size: 24,
                      color: change ? Colors.blue : Colors.grey,
                    )),
              ));
  }

  insertVote(bool _vote, bool upinc, bool downinc) async {
    await Hasura.insertCommentVote(
      true,
      widget.id,
      _vote,
    );
  }

  deleteVote(bool upinc, bool downinc) async {
    await Hasura.deleteCommentVote(true, widget.id, upinc, downinc,
        replyId: widget.id);
  }

  updateVote(bool newVote) async {
    await Hasura.updateCommentVote(true, widget.id, newVote);
  }

  @override
  void initState() {
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
    return Column(children: <Widget>[
      SizedBox(
        height: 10,
      ),
      Row(
        children: [
          SizedBox(
            width: 14,
          ),
          GestureDetector(
            onTap: () {
              GoTo().profileScreen(context, widget.userId);
            },
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.avatarUrl ??
                  "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
              maxRadius: 13,
              minRadius: 13,
            ),
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
                        width: 0, color: Theme.of(context).canvasColor)),
                itemBuilder: (_) => [
                  PopupMenuItem(child: Text('Report'), value: 'Report'),
                ],
                icon: Icon(
                  Icons.more_vert,
                  size: 22,
                  color: Colors.grey,
                ),
                onSelected: (selectedValue) async {
                  if (selectedValue == 'Report') {
                    await Hasura.insertCommentReport(widget.id, true);
                    snackbar('Comment Reported', context);
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LayoutBuilder(builder: (context, size) {
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
                            // setState(() {
                            //   if (maxLines == 8) {
                            //     maxLines = 100;
                            //   } else {
                            //     maxLines = 8;
                            //   }
                            // });
                          },
                          child: Text(
                            exceeded ? 'See more' : 'See less',
                            maxLines: 1,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                    ]);
              }),
              SizedBox(
                height: 5,
              ),
              Row(
                children: <Widget>[
                  Expanded(child: Container()),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    Functions.abbreviateNumber(votes, hideLess: true),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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

                          updateVote(
                            false,
                          );
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
                              vote == CommentVote.downvote
                                  ? FluentIcons.keyboard_shift_16_filled
                                  : FluentIcons.keyboard_shift_20_regular,
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

                          updateVote(true);
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
                          vote == CommentVote.upvote
                              ? FluentIcons.keyboard_shift_16_filled
                              : FluentIcons.keyboard_shift_20_regular,
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
          ))
    ]);
  }
}
