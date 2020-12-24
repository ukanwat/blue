import 'package:blue/providers/comment.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/comment_reply.dart';
import 'package:blue/widgets/comment_vote_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comment extends StatefulWidget {
  final String id;
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;
  final int upvotes;
  final int downvotes;
  final String postId;
  final Map replies;
  final bool showReplies;
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
      this.showReplies});

  factory Comment.fromDocument(
      Map doc, String postId, String docId, bool showReplies) {
    if (showReplies == null) {
      showReplies = false;
    }
    return Comment(
      id: docId,
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timeStamp'], // TODO fix 'S'
      avatarUrl: doc['avatarUrl'],
      upvotes: doc['upvotes'],
      downvotes: doc['downvotes'],
      postId: postId,
      replies: doc['replies'],
      showReplies: showReplies,
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
  toggleReplies() {
    setState(() {
      if (repliesLoaded == false) {
        if (widget.replies != null) {
          widget.replies.forEach((key, value) {
            replyWidgets.add(CommentReply(
              avatarUrl: value['avatarUrl'],
              comment: value['comment'],
              id: key,
              commentId: widget.id,
              username: value['username'],
              downvotes: value['downvotes'],
              postId: widget.postId,
              upvotes: value['upvotes'],
              userId: value['userId'],
              referName: value['referName'],
              timestamp: value['timeStamp'],
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

  @override
  void initState() {
    if (widget.showReplies == true) {
      toggleReplies();
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
                  height: 8,
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Text(
                        'currentUser.username',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
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
                        '${timeago.format(widget.timestamp.toDate())}',
                        style: TextStyle(fontSize: 13),
                      ),
                      Expanded(child: Container()),
                      SizedBox(
                        height: 24,
                        width: 24,
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
                              commentsRef
                                  .doc(widget.postId)
                                  .collection('userComments')
                                  .doc(widget.id)
                                  .update({'reports': FieldValue.increment(1)});
                            }
                          },
                        ),
                      )
                    ],
                  ),
                  subtitle: Column(
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
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: <Widget>[
                          if (widget.replies != null)
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
                                      size: 20,
                                    ),
                                    Text(
                                      repliesLoaded == true
                                          ? 'Hide Replies'
                                          : '${widget.replies.length} Replies',
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
                          SizedBox(
                            width: 30,
                          ),
                          CommentVoteButton(
                            type: CommentType.comment,
                            vote: Vote.upvote,
                            commentId: widget.id,
                            postId: widget.postId,
                          ),
                          SizedBox(width: 8),
                          Text(
                            votes.toString(),
                            style: TextStyle(fontSize: 18, color: Colors.blue),
                          ),
                          SizedBox(width: 8),
                          CommentVoteButton(
                            type: CommentType.comment,
                            vote: Vote.downvote,
                            commentId: widget.id,
                            postId: widget.postId,
                          ),
                        ],
                      ),
                    ],
                  ),

                  leading: CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(widget.avatarUrl),
                    maxRadius: 16,
                    minRadius: 16,
                  ),
                  // subtitle: Text(timestamp.toDate().toString())//timeago.format(timestamp.toDate()))
                ),
                ...replyWidgets,
                Container(
                  width: double.infinity,
                  color: Colors.grey[400],
                  height: 0.4,
                ),
              ],
            ));
  }
}
