// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:blue/constants/app_colors.dart';
// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/state_management/comment.dart';
import 'package:blue/services/functions.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/comment_reply.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/loadmore_widget.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import '../services/boxes.dart';
import '../services/hasura.dart';
import '../widgets/comment.dart';

enum CommentSort { best, top, oldest, newest }

class CommentsScreen extends StatefulWidget {
  static const routeName = '/comments';
  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen>
    with SingleTickerProviderStateMixin {
  bool showReplies = true;
  Post data;
  TabController _tabController;
  int index = 0;
  @override
  void initState() {
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
    dynamic _index = _map['index'];

    if (_index == 1) {
      index = 1;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0,
      ),
      body: SafeArea(
          child: Stack(children: <Widget>[
        DefaultTabController(
          initialIndex: index,
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, value) {
              return [
                SliverToBoxAdapter(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    data,
                  ],
                )),
                SliverAppBar(
                  toolbarHeight: 44,
                  elevation: 2,
                  backgroundColor: Theme.of(context).canvasColor,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  title: Container(
                    height: 34,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Theme.of(context).accentColor,
                      indicatorWeight: 0,
                      labelPadding: EdgeInsets.only(top: 0),
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Theme.of(context).cardColor),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                            child: Padding(
                          padding: const EdgeInsets.only(
                            left: 5,
                          ),
                          child: Text(
                            'More like this',
                            // 'More From @${data.username}',
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .iconTheme
                                    .color
                                    .withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Stark Sans',
                                fontSize: 15),
                          ),
                        )),
                        Tab(
                          child: Text(
                            '${Functions.abbreviateNumber(data.commentCount)} comments',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .iconTheme
                                    .color
                                    .withOpacity(0.7),
                                fontFamily: 'Stark Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Container(
              color: Theme.of(context).backgroundColor,
              child: TabBarView(
                controller: _tabController,
                children: [
                  SimilarPostsScreen(data.ownerId, data.postId),
                  Comments(data)
                ],
              ),
            ),
          ),
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
      ])),
    );
  }
}

class Comments extends StatefulWidget {
  final Post post;
  Comments(
    this.post,
  );
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments>
    with AutomaticKeepAliveClientMixin<Comments> {
  TextEditingController fakeId = TextEditingController();
  List<Widget> comments = [];
  int count = 0;
  int length = 5;
  bool loaded = false;
  CommentSort sort = CommentSort.best;
  TextEditingController commentsController = TextEditingController();
  Widget commentsWidget = circularProgress();
  List<Comment> commentDocs = [];
  bool commenting = false;
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
  }

  addComments(Post data) async {
    dynamic doc;
    if (fakeId.text == '' || fakeId.text == null) {
      doc = await Hasura.insertComment(
        data.postId,
        commentsController.text,
        data.ownerId,
      );
    } else {
      doc = await Hasura.insertComment(
          data.postId, commentsController.text, data.ownerId,
          fakeId: int.parse(fakeId.text));
    }

    setState(() {
      comments.insert(
          0, Comment.fromDocument(doc, data.postId, doc['comment_id']));

      commentsController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(children: [
      GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          color: Theme.of(context).backgroundColor,
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
                  return Container();
                }
                if (i == 1) {
                  return Column(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              border: Border.symmetric(
                                  horizontal: BorderSide(
                                      color: Theme.of(context).cardColor,
                                      width: 1))),
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(100)),
                                child: PopupMenuButton(
                                  elevation: 2,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          sort.toString().substring(12),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Icon(
                                          FluentIcons.chevron_down_24_filled,
                                          size: 17,
                                        ),
                                      ],
                                    ),
                                  ),
                                  padding: EdgeInsets.zero,
                                  color: Theme.of(context).canvasColor,
                                  // iconSize: 20,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                        child: Text('Best'), value: 'Best'),
                                    PopupMenuItem(
                                        child: Text('Top'), value: 'Top'),
                                    PopupMenuItem(
                                        child: Text('Older'), value: 'Oldest'),
                                    PopupMenuItem(
                                        child: Text('Recent'), value: 'Newest'),
                                  ],
                                  // icon:
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
                              ),
                              Expanded(child: Container()),
                              Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).cardColor),
                                child: GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      FluentIcons.arrow_clockwise_24_regular,
                                      size: 20,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      loaded = false;
                                      comments = [];
                                      count = 0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          )),
                      if (comments.length == 0 && loaded == true)
                        Container(
                            height: 300,
                            child:
                                emptyState(context, 'No Comments', 'Welcome'))
                    ],
                  );
                }

                return comments[i - 2];
              },
              itemCount: comments.length + 2,
            ),
          ),
        ),
      ),
      Positioned(
          bottom: 0,
          child: GetBuilder<CommentGet>(
              // specify type as Controller
              init: CommentGet(), // intialize with the Controller
              id: 'input',
              builder: (value) {
                return Container(
                    constraints: BoxConstraints(minHeight: 60),
                    width: MediaQuery.of(context).size.width,
                    child: Material(
                        child: Container(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                          Column(mainAxisSize: MainAxisSize.min, children: <
                              Widget>[
                            SizedBox(
                              height: 8,
                            ),
                            if (value.commentState['referName'] != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      value.changeCommentType(
                                          {'type': 'comment'});
                                    },
                                    child: Icon(
                                      Icons.clear_outlined,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Replying ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    '@${value.commentState['referName']}',
                                    style: TextStyle(
                                        color: AppColors.blue, fontSize: 16),
                                  ),
                                ],
                              ),
                            if (value.commentState['referName'] != null)
                              SizedBox(
                                height: 4,
                              ),
                            Container(
                              padding:
                                  EdgeInsets.only(top: 2, left: 5, right: 5),
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
                                  if (!kReleaseMode)
                                    Container(
                                        width: 50,
                                        child: TextField(
                                          controller: fakeId,
                                          decoration:
                                              InputDecoration(hintText: 'ID'),
                                        )),
                                  Expanded(
                                    child: TextField(
                                      focusNode: value.focusNode,
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
                                        hintText: value.commentState['type'],
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
                                        child: commenting
                                            ? SizedBox(
                                                height: 28,
                                                width: 28,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Icon(
                                                FluentIcons
                                                    .comment_arrow_right_20_regular,
                                                color: Colors.white,
                                              ),
                                      ),
                                      onTap: () async {
                                        dynamic val;
                                        if (commenting == true) {
                                          return;
                                        }
                                        setState(() {
                                          commenting = true;
                                        });
                                        if (commentsController.text == '' ||
                                            commentsController.text == null) {
                                          setState(() {
                                            commenting = false;
                                          });
                                          return;
                                        }
                                        if (value.commentState['type'] ==
                                            'comment') {
                                          await addComments(widget.post);
                                          setState(() {
                                            commenting = false;
                                          });
                                        } else if (value.commentState['type'] ==
                                            'reply') {
                                          int commenterId =
                                              await Hasura.getUserId();
                                          if (!kReleaseMode) {
                                            if (fakeId.text != '' &&
                                                fakeId.text != null) {
                                              commenterId =
                                                  int.parse(fakeId.text);
                                            }
                                          }
                                          if (value.commentState['referName'] !=
                                              null) {
                                            val =
                                                await Hasura.insertCommentReply(
                                                    widget.post.postId,
                                                    value.commentState[
                                                        'commentId'],
                                                    commentsController.text,
                                                    value.commentState[
                                                        'createdAt'],
                                                    commenterId);
                                          } else {
                                            setState(() {
                                              commenting = false;
                                            });
                                            return;
                                          }

                                          commentsController.clear();

                                          value.addCommentReply(
                                              value.commentState['commentId'],
                                              CommentReply(
                                                id: val['reply_id'],
                                                avatarUrl: val['user']
                                                    ['avatar_url'],
                                                comment: val['data'],
                                                commentId: value
                                                    .commentState['commentId'],
                                                username: val['user']
                                                    ['username'],
                                                downvotes: val['downvotes'],
                                                postId: widget.post.postId,
                                                upvotes: val['upvotes'],
                                                userId: val['user_id'],
                                                timestamp: DateTime.parse(
                                                  val['created_at'],
                                                ),
                                                vote: val['user_vote'],
                                              ));

                                          value.changeCommentType(
                                              {'type': 'comment'});

                                          setState(() {
                                            commenting = false;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                ],
                              ),
                            )
                          ])
                        ]))));
              }))
    ]);
  }
}

class SimilarPostsScreen extends StatefulWidget {
  final int id;
  final int postId;
  SimilarPostsScreen(this.id, this.postId);
  @override
  _SimilarPostsScreenState createState() => _SimilarPostsScreenState();
}

class _SimilarPostsScreenState extends State<SimilarPostsScreen>
    with AutomaticKeepAliveClientMixin<SimilarPostsScreen> {
  List<dynamic> posts = [];
  bool loading = true;
  String _orderBy = "{upvote_count:desc}";
  getSimilarPosts() async {
    String _where = "{owner_id:{_eq:${widget.id}}}";
    dynamic doc = await Hasura.getPosts(10, 0, _orderBy, where: _where);

    setState(() {
      posts = doc
          .map((doc) => doc['post_id'] == widget.postId
              ? Container()
              : Post.fromDocument(
                  doc,
                  isCompact: false,
                  commentsShown: false,
                ))
          .toList();
      loading = false;
    });
  }

  @override
  void initState() {
    getSimilarPosts();
    super.initState();
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return loading
        ? Container(height: 100, child: circularProgress())
        : SingleChildScrollView(
            child: Column(children: [
            ...posts,
            Container(
              height: 100,
            )
          ]));
  }
}
