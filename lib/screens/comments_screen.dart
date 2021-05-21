// Flutter imports:
import 'package:blue/services/functions.dart';
import 'package:blue/widgets/comment_reply.dart';
import 'package:blue/widgets/loadmore_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/providers/comment.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import '../widgets/comment.dart';
import './home.dart';
import '../services/boxes.dart';
import '../services/hasura.dart';

enum CommentSort { best, top, oldest, newest }

class CommentsScreen extends StatefulWidget {
  static const routeName = '/comments';
  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  TextEditingController commentsController = TextEditingController();
  bool showReplies = true;
  Post data;

  Widget commentsWidget = circularProgress();
  List<Comment> commentDocs = [];
  addComments(Post data) async {
    dynamic doc = await Hasura.insertComment(
        data.postId, commentsController.text, data.ownerId);
    setState(() {
      commentDocs
          .add(Comment.fromDocument(doc, data.postId, doc['comment_id']));
      comments = Comments(data, comments.key, commentDocs);

      commentsController.clear();
    });
  }

  addReply(
      Post data, int commentId, int ownerId, String createdAt, int commenterId,
      {String referName}) async {
    dynamic value;
    if (referName != null) {
      value = await Hasura.insertCommentReply(data.postId, commentId,
          commentsController.text, createdAt, commenterId);
    } else {
      return;
      // commentsRef
      //     .doc(data.postId)
      //     .collection('userComments')
      //     .doc(commentId)
      //     .update(
      //   {
      //     'replies.$timestamp': {
      //       'username': currentUser.username,
      //       'comment': commentsController.text,
      //       'timeStamp': timestamp,
      //       'avatarUrl': currentUser.photoUrl,
      //       'userId': currentUser.id,
      //       'upvotes': 0,
      //       'downvotes': 0,
      //     },
      //     'repliesWordCount':
      //         FieldValue.increment(commentsController.text.length),
      //   },
      // );
    }

    CommentNotifier().changeCommentType({'type': 'comment'});
    commentsController.clear();
    print('commentId');
    print(commentId);
    CommentNotifier().addCommentReply(
        commentId,
        CommentReply(
          id: value['reply_id'],
          avatarUrl: value['user']['avatar_url'],
          comment: value['data'],
          commentId: commentId,
          username: value['user']['username'],
          downvotes: value['downvotes'],
          postId: data.postId,
          upvotes: value['upvotes'],
          userId: value['user_id'],
          timestamp: DateTime.parse(
            value['created_at'],
          ),
          vote: value['user_vote'],
        ));
  }

  @override
  void initState() {
    CommentNotifier().changeCommentType(
      {'type': 'comment'},
    );
    bool _showReplies = PreferencesUpdate().getBool('show_replies');
    if (_showReplies == null) {
      _showReplies = true;
    }
    showReplies = _showReplies;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    Map _map = ModalRoute.of(context).settings.arguments as Map;
    data = _map['post'];
    if (_map['comment'] != null) {
      commentDocs.add(_map['comment']);
    }
    comments = Comments(data, UniqueKey(), commentDocs);

    super.didChangeDependencies();
  }

  Widget comments;
  @override
  Widget build(BuildContext context) {
    print(commentDocs.length);
    print('lengthhhh');
    return ChangeNotifierProvider(
      create: (_) => CommentNotifier(),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              RefreshIndicator(
                  onRefresh: () async {
                    comments = Comments(data, UniqueKey(), commentDocs);
                  },
                  child: comments),
              Column(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Consumer<CommentNotifier>(
                      builder: (context, CommentNotifier notifier, child) {
                    print(notifier.commentState);
                    return Container(
                      color: Colors.transparent,
                      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (notifier.commentState['referName'] != null)
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                        width: 1,
                                        color: Colors.grey.withOpacity(0.4))),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        notifier.changeCommentType(
                                            {'type': 'comment'});
                                      },
                                      child: Icon(
                                        Icons.cancel,
                                        color: Colors.grey[600],
                                        size: 22,
                                      ),
                                    ),
                                    Text(
                                      'Replying ',
                                      style: TextStyle(),
                                    ),
                                    Text(
                                      '@${notifier.commentState['referName']}',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(
                              height: 8,
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).canvasColor,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                      width: 1,
                                      color: Colors.grey.withOpacity(0.4))),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: CircleAvatar(
                                      maxRadius: 19,
                                      minRadius: 19,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        currentUser.avatarUrl ??
                                            "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744",
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      focusNode: notifier.focusNode,
                                      controller: commentsController,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color),
                                      maxLines: 8,
                                      maxLength: 1000,
                                      minLines: 1,
                                      keyboardType: TextInputType.multiline,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(top: 0, left: 10),
                                        hintText: notifier.commentState['type'],
                                        counter: Container(),
                                        hintStyle: TextStyle(
                                            fontSize: 18,
                                            height: 0.7,
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color
                                                .withOpacity(0.8)),
                                        fillColor: Theme.of(context).cardColor,
                                        filled: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          borderSide: BorderSide(
                                            width: 0,
                                            color: Theme.of(context).cardColor,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          borderSide: BorderSide(
                                            width: 0,
                                            color: Theme.of(context).cardColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: GestureDetector(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.deepOrange),
                                        padding: EdgeInsets.all(6),
                                        child: Icon(
                                          FluentIcons
                                              .comment_arrow_right_20_regular,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onTap: () {
                                        print(notifier.commentState['type']);
                                        if (notifier.commentState['type'] ==
                                            'comment') {
                                          addComments(data);
                                        } else if (notifier
                                                .commentState['type'] ==
                                            'reply') {
                                          if (notifier
                                                  .commentState['referName'] !=
                                              null)
                                            addReply(
                                              data,
                                              notifier
                                                  .commentState['commentId'],
                                              notifier.commentState['ownerId'],
                                              notifier
                                                  .commentState['createdAt'],
                                              notifier
                                                  .commentState['commenterId'],
                                              referName: notifier
                                                  .commentState['referName'],
                                            );
                                          else {
                                            addReply(
                                              data,
                                              notifier
                                                  .commentState['commentId'],
                                              notifier.commentState['ownerId'],
                                              notifier
                                                  .commentState['commenterId'],
                                              notifier
                                                  .commentState['createdAt'],
                                            );
                                          }
                                          notifier.changeCommentType(
                                              {'type': 'comment'});
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 6, top: 9),
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).canvasColor.withOpacity(0.8)),
                child: Center(
                  child: InkWell(
                    child: Icon(
                      FluentIcons.chevron_left_24_filled,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Comments extends StatefulWidget {
  final Post post;
  final List<Comment> docs;
  Comments(this.post, Key key, this.docs) : super(key: key);
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  List<Widget> comments;
  int count = 0;
  int length = 5;
  bool loaded = false;
  CommentSort sort = CommentSort.best;
  @override
  void initState() {
    comments = widget.docs;
    super.initState();
  }

  getComments() async {
    dynamic snapshot =
        await Hasura.getComments(widget.post.postId, count, length, sort);
    count = count + snapshot.length;

    snapshot.forEach((doc) {
      comments
          .add(Comment.fromDocument(doc, doc['post_id'], doc['comment_id']));
    });
    setState(() {});

    if (snapshot.length < length) {
      setState(() {
        loaded = true;
      });
    }
    print('loaded:$loaded  ${snapshot.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LoadMore(
        key: ValueKey(sort),
        onLoadMore: () async {
          await getComments();
          return true;
        },
        isFinish: loaded,
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: 90),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    padding: const EdgeInsets.only(left: 50, top: 10),
                    child: Text(
                      'Comments',
                      style: TextStyle(
                          fontFamily: 'Techna Sans Regular', fontSize: 26),
                    ),
                  ),
                  widget.post
                ],
              );
            }
            if (i == 1) {
              return Container(
                  decoration: BoxDecoration(
                      border: Border.symmetric(
                          horizontal: BorderSide(
                              color: Theme.of(context).cardColor, width: 1))),
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "${Functions.abbreviateNumber(widget.post.commentCount)} comments",
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(child: Container()),
                      IconButton(
                        icon: Icon(FluentIcons.arrow_clockwise_24_regular),
                        onPressed: () {
                          setState(() {
                            loaded = false;
                            comments = [];
                            count = 0;
                          });
                        },
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        sort.toString().substring(12),
                        style: TextStyle(fontSize: 20),
                      ),
                      PopupMenuButton(
                        elevation: 2,
                        padding: EdgeInsets.zero,
                        color: Theme.of(context).backgroundColor,
                        iconSize: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (_) => [
                          PopupMenuItem(child: Text('Best'), value: 'Best'),
                          PopupMenuItem(child: Text('Top'), value: 'Top'),
                          PopupMenuItem(child: Text('Older'), value: 'Oldest'),
                          PopupMenuItem(child: Text('Recent'), value: 'Newest'),
                        ],
                        icon: Icon(
                          FluentIcons.chevron_circle_down_24_regular,
                          size: 24,
                        ),
                        onSelected: (selectedValue) async {
                          switch (selectedValue) {
                            case 'Best':
                              sort = CommentSort.best;

                              break;
                            case 'Top':
                              sort = CommentSort.top;

                              break;
                            case 'Oldest':
                              sort = CommentSort.oldest;

                              break;
                            case 'Newest':
                              sort = CommentSort.newest;

                              break;
                          }

                          setState(() {
                            comments = [];
                            loaded = false;
                            count = 0;
                          });
                        },
                      ),
                    ],
                  ));
            }

            return comments[i - 2];
          },
          itemCount: comments.length + 2,
        ),
      ),
    );
  }
}
