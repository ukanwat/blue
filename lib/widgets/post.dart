// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

// Flutter imports:
import 'package:blue/services/dynamic_links.dart';
import 'package:blue/services/post_functions.dart';
import 'package:blue/widgets/show_dialog.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flick_video_player/flick_video_player.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:hive/hive.dart';
import 'package:kidd_video_player/kidd_video_player.dart';
import 'package:kidd_video_player/models/layout_configs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/explore_posts_screen.dart';
import 'package:blue/screens/profile_screen.dart';
import 'package:blue/screens/tag_screen.dart';
import 'package:blue/services/link_preview.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/services/video_controls.dart';
import 'package:blue/widgets/report_dialog.dart';
import 'package:blue/widgets/repost_dialog.dart';
import 'package:blue/widgets/save_dialog.dart';
import 'package:yoyo_player/yoyo_player.dart';
import '../screens/comments_screen.dart';
import '../screens/home.dart';
import '../services/functions.dart';
import '../services/go_to.dart';
import '../services/boxes.dart';
import './custom_image.dart';
import '../services/hasura.dart';

enum CompactPostThumbnailType {
  video,
  image,
  link,
}
enum Vote { down, up, none }

class Post extends StatefulWidget {
  final int postId;
  final dynamic ownerId;
  final String username;
  final String photoUrl;
  final String title;
  final String topicName;
  final String topicId;
  final dynamic contents;
  final dynamic contentsInfo;
  final int upvotes;
  final int downvotes;
  final int votes;
  final List<dynamic> tags;
  final bool isCompact;
  final bool commentsShown;
  final dynamic time;
  final int comments;
  final int saves;
  final int shares;
  final int commentCount;
  final bool upvoted;
  // final PostInteractions postInteractions;

  Post(
      {this.postId,
      this.ownerId,
      this.username,
      this.photoUrl,
      this.title,
      this.topicName,
      this.topicId,
      this.contents,
      this.contentsInfo,
      this.upvotes,
      this.votes,
      this.downvotes,
      this.tags,
      this.isCompact,
      this.commentsShown,
      this.time,
      this.comments,
      this.saves,
      this.shares,
      this.commentCount,
      this.upvoted});

  factory Post.fromDocument(
    Map doc, {
    bool isCompact,
    bool commentsShown,
  }) {
    print('doc:');
    print(doc);
    if (isCompact == null) isCompact = false;
    if (commentsShown == null) commentsShown = false;
    Map data = {};
    List _tags = [];
    var list = doc['contents'];
    int i = 0;
    list.forEach((element) {
      data['$i'] = element['data'];
      i++;
    });
    var tagDataList = doc['post_tags'];
    if (tagDataList != null) {
      tagDataList.forEach((element) {
        _tags.add(element['tag']['tag']);
      });
    }
    print(doc['upvoted_by_user']);
    List<dynamic> stats = doc['post_stats'];
    return Post(
      upvoted: doc['upvoted_by_user'],
      postId: doc['post_id'],
      ownerId: doc['owner_id'],
      username: doc['user']['username'],
      photoUrl: doc['user']['avatar_url'],
      title: doc['title'],
      topicName: null,
      topicId: null,
      contents: data,
      contentsInfo: doc['contents'],
      upvotes: (stats == null
          ? 0
          : stats.length == 0
              ? 0
              : stats[0]['upvotes']),
      downvotes: (stats == null
          ? 0
          : stats.length == 0
              ? 0
              : stats[0]['downvotes']),
      votes: 0,
      tags: _tags,
      time: doc['created_at'], //TODO
      isCompact: isCompact ?? false,
      commentsShown: commentsShown,
      commentCount: doc['comment_count'],
      comments: stats == null
          ? 0
          : stats.length == 0
              ? 0
              : stats[0]['comments'],
      saves: stats == null
          ? 0
          : stats.length == 0
              ? 0
              : stats[0]['saves'],
      shares: stats == null
          ? 0
          : stats.length == 0
              ? 0
              : stats[0]['shares'],
    );
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      username: this.username,
      photoUrl: this.photoUrl,
      title: this.title,
      topicName: this.topicName,
      topicId: this.topicId,
      contents: this.contents,
      contentsInfo: this.contentsInfo,
      upvotes: this.upvotes,
      votes: this.votes,
      downvotes: this.downvotes,
      tags: this.tags,
      commentCount: this.commentCount);
}

Vote vote;

class _PostState extends State<Post> {
  bool deleted = false;
  double topEdgeHeight;
  double bottomEdgeHeight;
  bool showSaveBar = false;
  Widget playbackButton = Container();
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  bool isSaved = false;
  List<Widget> contentsViewList = [];
  final dynamic currentUserId = currentUser?.id;
  final int postId;
  final dynamic ownerId;
  final String username;
  final String photoUrl;
  final String title;
  final String topicName;
  final String topicId;
  final dynamic contents;
  final dynamic contentsInfo;
  final List<dynamic> tags;
  final int votes;
  final int upvotes;
  final int downvotes;
  final int commentCount;
  _PostState(
      {this.postId,
      this.ownerId,
      this.username,
      this.photoUrl,
      this.title,
      this.topicName,
      this.topicId,
      this.contents,
      this.contentsInfo,
      this.upvotes,
      this.tags,
      this.votes,
      this.downvotes,
      this.commentCount});
  //
  Vote vote = Vote.none;
  bool isOwner = false;
  double screenWidth;
  bool tagBarVisible = false;
  bool notInterested = false;
  var compactPostThumbnailData;
  CompactPostThumbnailType thumbnailType;
  OverlayEntry overlayOptions;
  bool isFollowing = false;
  GlobalKey _contentsKey = GlobalKey();
  double contentsHeight;
  bool constraintContent = true;

  showOptions(BuildContext context) {
    overlayOptions = createOverlayOptions(context);
    Overlay.of(context).insert(overlayOptions);
  }

  OverlayEntry createOverlayOptions(BuildContext context) {
    RenderBox getBox = context.findRenderObject();
    Offset position = getBox.localToGlobal(Offset.zero);
    return OverlayEntry(
        builder: (context) => Stack(
              children: <Widget>[
                Positioned.fill(
                    child: GestureDetector(
                  onTap: overlayOptions?.remove,
                  onLongPress: overlayOptions?.remove,
                  onHorizontalDragStart: (_) {
                    overlayOptions?.remove();
                  },
                  onVerticalDragStart: (_) {
                    overlayOptions?.remove();
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                )),
                Positioned(
                  left: position.dx + 10,
                  top: position.dy + 10,
                  width: 220,
                  child: Material(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).canvasColor,
                    elevation: 1.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            onTap: () {
                              setState(() {
                                overlayOptions?.remove();
                              });
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ReportDialog(
                                        widget.postId, widget.title);
                                  });
                            },
                            dense: true,
                            leading: Icon(
                              FluentIcons.flag_24_regular,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            title: Text('Report'),
                          ),
                          ListTile(
                            dense: true,
                            leading: Icon(
                              FluentIcons.block_24_regular,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            title: Text('Not Interested'),
                            onTap: () {
                              setState(() {
                                overlayOptions?.remove();
                                notInterested = true;
                              });
                            },
                          ),
                          if (ownerId != currentUser.id)
                            DownvoteTile(vote, postId, () {
                              if (vote == Vote.down) {
                                setState(() {
                                  vote = Vote.none;
                                });
                                unvote();
                              } else
                                setState(() {
                                  vote = Vote.down;
                                });
                            }),
                          if (isFollowing)
                            ListTile(
                              dense: true,
                              leading: Icon(
                                FluentIcons.person_delete_24_regular,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              onTap: () async {
                                Functions().handleUnfollowUser(
                                    widget.ownerId); //TODO wait for future
                                setState(() {
                                  isFollowing = false;
                                  overlayOptions?.remove();
                                });
                              },
                              title: Text('Unfollow'),
                            ),
                          if (Boxes.currentUserBox.get('user_id') == ownerId)
                            ListTile(
                              dense: true,
                              leading: Icon(
                                FluentIcons.delete_24_regular,
                                color: Colors.red,
                              ),
                              onTap: () async {
                                overlayOptions?.remove();
                                deletePost();
                              },
                              title: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ));
  }

  buildPostHeader() {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: <Widget>[
          Container(
            color: Theme.of(context).backgroundColor,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    GoTo().profileScreen(context, widget.ownerId);
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: CachedNetworkImageProvider(photoUrl ??
                        "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
                    backgroundColor: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(widget.title,
                        style: PreferencesUpdate().getBool('serif', def: false)
                            ? TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0,
                                wordSpacing: 0,
                                height: 1.25,
                                color: Theme.of(context)
                                    .textSelectionTheme
                                    .selectionColor)
                            : TextStyle(
                                fontFamily: 'Lexend Deca',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                                wordSpacing: 0,
                                height: 1.25,
                              ),
                        maxLines: tagBarVisible ? 5 : 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).backgroundColor,
            child: Row(
              children: [
                GestureDetector(
                    child: Container(
                      height: 38,
                      width: 55,
                      padding: const EdgeInsets.only(bottom: 3, top: 6),
                      child: Icon(
                        Icons.more_horiz,
                      ),
                    ),
                    onTap: () {
                      showOptions(context);
                    }),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(widget.username,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .iconTheme
                                  .color
                                  .withOpacity(0.95),
                            )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      if (!isFollowing &&
                          !(widget.ownerId ==
                              Boxes.currentUserBox.get('user_id')))
                        Container(
                          height: 22,
                          child: GestureDetector(
                            onTap: () async {
                              Functions().handleFollowUser(
                                  widget.ownerId); // TODO wait for future
                              setState(() {
                                isFollowing = true;
                              });
                            },
                            child: Container(
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.blue,
                                ),
                                child: Icon(
                                  FluentIcons.add_16_filled,
                                  color: Colors.white,
                                  size: 18,
                                )),
                          ),
                        ),
                    ],
                  ),
                ),
                tagBarVisible
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            tagBarVisible = false;
                          });
                        },
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.only(
                              bottom: 6, left: 15, right: 15, top: 3),
                          child: Icon(
                            FluentIcons.chevron_up_16_filled,
                            size: 22,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () async {
                          setState(() {
                            tagBarVisible = true;
                          });
                        },
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.only(
                              bottom: 6, left: 15, right: 15, top: 3),
                          child: Icon(
                            FluentIcons.chevron_down_16_filled,
                            size: 22,
                          ),
                        ),
                      ),
              ],
            ),
          ),
          if (tagBarVisible) tagBar(),
          if (tagBarVisible)
            Container(
              width: double.infinity,
              height: 5,
            ),
        ],
      ),
    );
  }

  buildCompactPostHeader() {
    return Stack(children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.only(left: 10, top: 5, bottom: 8, right: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          GoTo().profileScreen(context, widget.ownerId);
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 11.5,
                              backgroundImage: CachedNetworkImageProvider(
                                  photoUrl ??
                                      "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
                              backgroundColor: Colors.grey,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Container(
                              height: 24,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                username,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          mainAxisSize: MainAxisSize.min,
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      if (!isFollowing &&
                          !(widget.ownerId ==
                              Boxes.currentUserBox.get('user_id')))
                        GestureDetector(
                          onTap: () {
                            Functions().handleFollowUser(
                                widget.ownerId); // TODO wait for future
                            setState(() {
                              isFollowing = true;
                            });
                          },
                          child: Container(
                            height: 24,
                            child: FittedBox(
                              fit: BoxFit.none,
                              alignment: Alignment.centerRight,
                              child: Container(
                                  height: 18,
                                  width: 18,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.blue,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 16,
                                  )),
                            ),
                          ),
                        ),
                      GestureDetector(
                          child: Container(
                            height: 24,
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Icon(Icons.more_horiz),
                          ),
                          onTap: () {
                            showOptions(context);
                          }),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: 10, top: 0, right: 5, bottom: 3),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (thumbnailType == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: Colors.blue,
                    height: MediaQuery.of(context).size.width * 0.20,
                    width: MediaQuery.of(context).size.width * 0.20,
                  )),
            ),
          if (thumbnailType == CompactPostThumbnailType.image)
            Container(
              margin: const EdgeInsets.all(8.0),
              height: MediaQuery.of(context).size.width * 0.20,
              width: MediaQuery.of(context).size.width * 0.20,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    child:
                        cachedNetworkImage(context, compactPostThumbnailData),
                    height: MediaQuery.of(context).size.width * 0.20,
                    width: MediaQuery.of(context).size.width * 0.20,
                  )),
            ),
          if (thumbnailType == CompactPostThumbnailType.video)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: compactPostThumbnailData == null
                      ? Container(
                          color: Colors.blue,
                          height: MediaQuery.of(context).size.width * 0.20,
                          width: MediaQuery.of(context).size.width * 0.20,
                        )
                      : Stack(
                          alignment: Alignment.bottomLeft,
                          children: <Widget>[
                            Container(
                              child: Image.file(
                                File(compactPostThumbnailData),
                                fit: BoxFit.cover,
                              ),
                              height: MediaQuery.of(context).size.width * 0.20,
                              width: MediaQuery.of(context).size.width * 0.20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Icon(
                                FlutterIcons.play_fou,
                                size: 26,
                                color: Colors.white,
                              ),
                            )
                          ],
                        )),
            )
        ],
      ),
    ]);
  }

  deletePost() async {
    showDialog(
        context: context,
        builder: (context) => ShowDialog(
              title: 'Delete Post',
              description: 'Are you sure you want to delete this Post?',
              leftButtonText: 'Cancel',
              rightButtonText: 'delete',
              leftButtonFunction: () {
                Navigator.pop(context);
              },
              rightButtonFunction: () async {
                if (widget.ownerId != Boxes.currentUserBox.get('user_id'))
                  return;
                // delete post itself

                // delete uploaded image for thep ost
                // storageRef.child("post_$postId.jpg").delete();  // TODO: delete stored media
                // then delete all activity feed notifications
                Hasura.deletePost(postId);
                Navigator.of(context).pop();
                setState(() {
                  deleted = true;
                });
                // then delete all comments
              },
            ));
  }

  unvote() async {
    //TODO
  }

  getVideoThumbnail(String url) async {
    if (thumbnailType != CompactPostThumbnailType.video) {
      setState(() {
        thumbnailType = CompactPostThumbnailType.video;
      });

      var dir = await getTemporaryDirectory();

      var _thumbnail = await VideoThumbnail.thumbnailFile(
          video: url,
          thumbnailPath: dir.path,
          imageFormat: ImageFormat.WEBP,
          maxHeight: 200,
          quality: 75,
          timeMs: 1000);
      setState(() {
        compactPostThumbnailData = _thumbnail;
      });
    }
  }

  Container tagBar() {
    return Container(
      margin: EdgeInsets.only(top: 0, bottom: 0),
      height: 28,
      child: Row(
        children: <Widget>[
          Container(
            width: 28,
            color: Theme.of(context).backgroundColor,
            child: Center(
              child: Text(
                '#',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 28,
              color: Theme.of(context).canvasColor,
              child: ListView.builder(
                itemCount: tags.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  print(
                    tags[i],
                  );
                  return InkWell(
                    onTap: () async {
                      Navigator.of(context)
                          .pushNamed(TagScreen.routeName, arguments: tags[i]);
                      String tagOpenInfo =
                          PreferencesUpdate().getString('tags_open_info');
                      if (tagOpenInfo == null) {
                        PreferencesUpdate()
                            .updateString('tags_open_info', json.encode({}));
                        tagOpenInfo = json.encode({});
                      }
                      DateTime nowTime = DateTime.now();
                      String _nowMonth = nowTime.month < 10
                          ? '0${nowTime.month}'
                          : '${nowTime.month}';
                      String _nowDay = nowTime.day < 10
                          ? '0${nowTime.day}'
                          : '${nowTime.day}';
                      String todayTime =
                          DateTime.parse("${nowTime.year}-$_nowMonth-$_nowDay")
                              .toString();
                      Map tagOpenMap = json.decode(tagOpenInfo);
                      if (tagOpenMap.containsKey(todayTime)) {
                        if (tagOpenMap[todayTime].containsKey(tags[i]))
                          tagOpenMap[todayTime][tags[i]] =
                              tagOpenMap[todayTime][tags[i]] + 1;
                        else
                          tagOpenMap[todayTime][tags[i]] = 1;
                      } else {
                        tagOpenMap[todayTime] = {tags[i]: 1};
                      }
                      print(tagOpenMap);
                      PreferencesUpdate().updateString(
                          'tags_open_info', json.encode(tagOpenMap));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      margin: EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                      decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.circular(100)),
                      child: Center(
                        child: Text(
                          tags[i],
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  bool persistentCallbackAdded = false;
  Timer timer;
  @override
  void didChangeDependencies() {
    isSaved = Boxes.saveBox.containsKey(postId);
    if (this.mounted && persistentCallbackAdded == false) {
      persistentCallbackAdded = true;
    }
    print(contents);
    print(title);
    for (int i = 0; i < contents.length; i++) {
      if (contentsInfo[i]['type'] == 'image') {
        if (thumbnailType != CompactPostThumbnailType.video) {
          thumbnailType = CompactPostThumbnailType.image;
          compactPostThumbnailData = contents['$i'];
        }
        contentsViewList.add(imageContentContainer(contents['$i'],
            contentsInfo[i]['aspectRatio'], contentsInfo[i]['blurHash']));
      } else if (contentsInfo[i]['type'] == 'video') {
        compactPostThumbnailData = contentsInfo[i]['thumbUrl'];
        print(contents['$i']);
        thumbnailType = CompactPostThumbnailType.video;

        contentsViewList.add(Container(
          height: MediaQuery.of(context).size.width /
              contentsInfo[i]['aspectRatio'],
          child: KiddVideoPlayer(
            fromUrl: true,
            videoUrl: contents['$i'],
            layoutConfigs: KiddLayoutConfigs(
              backgroundColor: Colors.black,
              backgroundSliderColor: Colors.grey.withOpacity(0.5),
              iconsColor: Colors.white,
              inLoop: false,
              loaderColor: Theme.of(context).accentColor,
              pauseIcon: Icons.pause_circle_outline,
              playIcon: Icons.play_circle_outline,
              showFullScreenButton: true,
              showVideoControl: true,
              showVolumeControl: false,
              sliderColor: Colors.white,
            ),
          ),
        ));
      } else if (contentsInfo[i]['type'] == 'text') {
        contentsViewList.add(textContentContainer(contents['$i']));
      } else if (contentsInfo[i]['type'] == 'link') {
        contentsViewList.add(linkContentContainer(contents['$i']));
      } else {
        contentsViewList.add(carouselContentContainer(contents['$i'],
            contentsInfo[i]['aspectRatio'], contentsInfo[i]['blurHashes']));
      }
    }
    if (!widget.isCompact)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (this.mounted) getContentSize();
      });
    if (widget.upvoted == true) {
      vote = Vote.up;
    }
    super.didChangeDependencies();
  }

  Widget imageContentContainer(
      String url, double aspectRatio, String blurHash) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        (cachedNetworkImage(context, url,
            aspectRatio: aspectRatio, blurHash: blurHash)),
      ],
    );
  }

  Widget carouselContentContainer(
      List<dynamic> urls, double aspectRatio, List blurHashes) {
    return Container(
        height: MediaQuery.of(context).size.width / aspectRatio,
        key: UniqueKey(),
        child: Carousel(
          dotVerticalPadding: 0,
          dotSize: 6,
          dotIncreaseSize: 1.2,
          dotIncreasedColor: Colors.blue.withOpacity(0.7),
          dotColor: Colors.white,
          showIndicator: true,
          dotPosition: DotPosition.bottomCenter,
          dotSpacing: 15,
          boxFit: BoxFit.fitWidth,
          dotBgColor: Colors.transparent,
          autoplay: false,
          overlayShadow: false,
          moveIndicatorFromBottom: 20,
          images: List.generate(urls.length, (i) {
            return cachedNetworkImage(context, urls[i],
                aspectRatio: aspectRatio, blurHash: blurHashes[i]);
          }),
        ));
  }

  Widget textContentContainer(String text) {
    if (PreferencesUpdate().getBool('serif') == null) {
      PreferencesUpdate().updateBool('serif', false);
    }
    return Container(
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Yahoo Sans',
          fontSize: 16,
          letterSpacing: 0,
          wordSpacing: 0,
          height: 1.25,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    );
  }

  Container linkContentContainer(String link) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Theme.of(context).canvasColor),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Material(
              child: InkWell(
                onTap: () {
                  Functions().launchURL(link);
                },
                child: LinkPreview(
                  url: link,
                  bodyStyle: TextStyle(fontSize: 13),
                  titleStyle: TextStyle(fontWeight: FontWeight.w500),
                  showMultimedia: true,
                ),
              ),
            )));
  }

  Widget footerButton(IconData iconData, Color color, Function function) {
    return Padding(
      padding: const EdgeInsets.only(right: 0, left: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: new CircleBorder(),
          onTap: function,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              iconData,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }

  bool increment;
  buildPostFooter() {
    print("increment:$increment");
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Column(
        children: <Widget>[
          if (showSaveBar)
            Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 6),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blue.withOpacity(0.15)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        'Saved!',
                        style: TextStyle(fontSize: 18),
                      ),
                      FlatButton(
                          onPressed: () {
                            setState(() {
                              showSaveBar = false;
                            });
                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  SaveDialog(this.widget),
                            );
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            'Save to Collection',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          ))
                    ],
                  ),
                )),
          if (widget.isCompact)
            if (tagBarVisible) tagBar(),
          Row(
            mainAxisAlignment: widget.isCompact
                ? MainAxisAlignment.spaceAround
                : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              if (widget.isCompact)
                tagBarVisible
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              tagBarVisible = false;
                            });
                          },
                          child: Icon(
                            FlutterIcons.ios_arrow_up_ion,
                            size: 22,
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 24,
                        width: 24,
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              tagBarVisible = true;
                            });
                          },
                          child: Icon(
                            FlutterIcons.ios_arrow_down_ion,
                            size: 22,
                          ),
                        ),
                      ),
              isSaved
                  ? Container(
                      width: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          footerButton(
                              FluentIcons.bookmark_24_filled, Colors.blue,
                              () async {
                            print(Boxes.saveBox.keys);
                            setState(() {
                              isSaved = false;
                              showSaveBar = false;
                            });
                            Boxes.saveBox.delete(postId);
                            await Hasura.deleteSavedPost(postId);
                          }),
                          Padding(
                            padding: const EdgeInsets.only(right: 0, left: 0),
                            child: Text(
                              '${Functions.abbreviateNumber(widget.saves, hideZero: true)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 19),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      width: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          footerButton(
                              FluentIcons.bookmark_24_regular, Colors.blue,
                              () async {
                            setState(() {
                              isSaved = true;
                            });

                            await Hasura.insertSavedPost(postId);
                            Boxes.saveBox.put(postId, null);

                            setState(() {
                              showSaveBar = true;
                            });
                            Future.delayed(const Duration(milliseconds: 4000),
                                () {
                              setState(() {
                                showSaveBar = false;
                              });
                            });
                          }),
                          Padding(
                            padding: const EdgeInsets.only(right: 0, left: 0),
                            child: Text(
                              '${Functions.abbreviateNumber(widget.saves, hideZero: true)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 19),
                            ),
                          ),
                        ],
                      ),
                    ),
              Container(
                width: 60,
                child: Row(
                  children: [
                    footerButton(
                        FluentIcons.share_24_regular, Colors.orange[900],
                        () async {
                      String _link =
                          await DynamicLinksService.createDynamicLink(
                              'post?id=$postId');
                      Share.share(_link, subject: 'Sharing this Post');
                    }),
                    Text(
                      '${Functions.abbreviateNumber(widget.shares, hideZero: true)}',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
                    ),
                  ],
                ),
              ),
              if (!(widget.commentsShown || widget.isCompact))
                Container(
                  width: 40,
                  child: footerButton(FluentIcons.comment_24_regular,
                      Theme.of(context).accentColor, () {
                    showComments(
                      context,
                      post: Post(
                        commentsShown: true,
                        contents: this.widget.contents,
                        contentsInfo: this.widget.contentsInfo,
                        isCompact: false,
                        ownerId: this.widget.ownerId,
                        photoUrl: this.widget.photoUrl,
                        postId: this.widget.postId,
                        tags: this.widget.tags,
                        title: this.widget.title,
                        topicId: this.widget.topicId,
                        topicName: this.widget.topicName,
                        upvotes: this.widget.upvotes,
                        username: this.widget.username,
                        comments: this.widget.comments,
                        downvotes: this.widget.downvotes,
                        saves: this.widget.saves,
                        shares: this.widget.shares,
                        commentCount: this.commentCount,
                        time: widget.time,
                        votes: widget.votes,
                      ),
                    );
                  }),
                ),
              if (!(widget.commentsShown || widget.isCompact))
                Container(
                  width: 20,
                  child: Text(
                    '${Functions.abbreviateNumber(widget.comments, hideZero: true)}',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
                  ),
                ),
              if (!widget.isCompact)
                Expanded(
                    child: (contentsHeight != null) &&
                            (contentsHeight ==
                                    MediaQuery.of(context).size.height * 0.8 ||
                                contentsHeight >
                                    MediaQuery.of(context).size.height * 0.8)
                        ? Center(
                            child: SizedBox(
                              height: 28,
                              width: 30,
                              child: GestureDetector(
                                onTap: () {
                                  if (!constraintContent) {
                                    setState(() {
                                      constraintContent = true;
                                      getContentSize();
                                    });
                                  } else {
                                    setState(() {
                                      constraintContent = false;
                                      getContentSize();
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(left: 0),
                                  child: CustomPaint(
                                    //                       <-- CustomPaint widget
                                    size: Size(30, 30),
                                    painter: ExpandIconPainter(
                                        constraintContent ? false : true,
                                        context),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container()),
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      PostFunctions().handleUpvoteButton(postId, vote);
                      if (vote == Vote.up) {
                        setState(() {
                          vote = Vote.none;
                        });
                        if (increment == null) {
                          setState(() {
                            increment = false;
                          });
                        } else {
                          setState(() {
                            increment = false;
                          });
                        }
                      } else if (vote == Vote.none) {
                        setState(() {
                          vote = Vote.up;
                        });
                        if (increment == null) {
                          setState(() {
                            increment = true;
                          });
                        } else {
                          setState(() {
                            increment = null;
                          });
                        }
                      }
                    },
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 3, left: 6),
                            child: Text(
                              increment == null
                                  ? '${Functions.abbreviateNumber(upvotes, hideZero: true)}'
                                  : increment
                                      ? '${Functions.abbreviateNumber(upvotes + 1, hideZero: true)}'
                                      : '${Functions.abbreviateNumber(upvotes - 1, hideZero: true)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 19),
                            ),
                          ),
                          Icon(
                              vote == Vote.up
                                  ? FluentIcons.keyboard_shift_24_filled
                                  : FluentIcons.keyboard_shift_24_regular,
                              size: 24.0,
                              color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 7),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    // flickManager?.dispose();
    super.dispose();
  }

  bool alreadyUpvoted = false;

  @override
  void initState() {
    isOwner = Boxes.currentUserBox.get('user_id') == widget.ownerId;

    if (Boxes.followingBox.containsKey(ownerId)) {
      isFollowing = true;
    }

    super.initState();
  }

  getContentSize() {
    RenderBox _contentsBox = _contentsKey.currentContext.findRenderObject();
    print(_contentsBox);
    setState(() {
      contentsHeight = _contentsBox.size.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    print(contentsInfo);
    return deleted
        ? Container()
        : notInterested //can do some other stuff
            ? Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    border: Border.fromBorderSide(
                        BorderSide(color: Colors.grey, width: 1))),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "You won't see this post again",
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          notInterested = false;
                        });
                      },
                      child: Text(
                        'Undo',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Material(
                    color: Theme.of(context).backgroundColor,
                    child: InkWell(
                      onTap: widget.isCompact
                          ? () {
                              showComments(
                                context,
                                post: Post(
                                  commentsShown: true,
                                  contents: this.widget.contents,
                                  contentsInfo: this.widget.contentsInfo,
                                  isCompact: false,
                                  ownerId: this.widget.ownerId,
                                  photoUrl: this.widget.photoUrl,
                                  postId: this.widget.postId,
                                  tags: this.widget.tags,
                                  title: this.widget.title,
                                  topicId: this.widget.topicId,
                                  topicName: this.widget.topicName,
                                  upvotes: this.widget.upvotes,
                                  username: this.widget.username,
                                  comments: this.widget.comments,
                                  downvotes: this.widget.downvotes,
                                  saves: this.widget.saves,
                                  shares: this.widget.shares,
                                  commentCount: this.commentCount,
                                  time: widget.time,
                                  votes: widget.votes,
                                ),
                              );
                              // Navigator.of(context).pushNamed(
                              //     ExplorePostsScreen.routeName,
                              //     arguments: this.widget);
                            }
                          : null,
                      child: Column(
                        children: <Widget>[
                          widget.isCompact
                              ? buildCompactPostHeader()
                              : buildPostHeader(),
                          if (!widget.isCompact)
                            ConstrainedBox(
                              constraints: constraintContent
                                  ? BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.8)
                                  : BoxConstraints(),
                              child: Stack(
                                clipBehavior: Clip.antiAlias,
                                alignment: AlignmentDirectional.topStart,
                                children: [
                                  ListView.builder(
                                    key: _contentsKey,
                                    padding: EdgeInsets.all(0),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (_, i) {
                                      return contentsViewList[i];
                                    },
                                    itemCount: contents.length,
                                  ),
                                ],
                              ),
                            ),
                          buildPostFooter(),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 1.5,
                    color: Theme.of(context).cardColor,
                    height: 1.5,
                  ),
                ],
              );
  }
}

showComments(
  BuildContext context, {
  Post post,
}) {
  Navigator.pushNamed(context, CommentsScreen.routeName, arguments: post);
}

// class VideoContentContainer extends StatefulWidget {
//   final Future<dynamic> initializeVideoPlayerFuture;
//   final VideoPlayerController controller;
//   final double aspectRatio;
//   VideoContentContainer(
//       {this.initializeVideoPlayerFuture, this.controller, this.aspectRatio});
//   @override
//   _VideoContentContainerState createState() => _VideoContentContainerState(
//       initializeVideoPlayerFuture: this.initializeVideoPlayerFuture,
//       controller: this.controller,
//       aspectRatio: this.aspectRatio);
// }

// class _VideoContentContainerState extends State<VideoContentContainer> {
//   final Future<dynamic> initializeVideoPlayerFuture;
//   final VideoPlayerController controller;
//   final double aspectRatio;
//   _VideoContentContainerState(
//       {this.initializeVideoPlayerFuture, this.controller, this.aspectRatio});
//   Widget playbackButton = Container();
//   playOrPauseVideo() {
//     if (controller.value.isPlaying) {
//       setState(() {
//         playbackButton = Icon(Icons.play_arrow);
//         controller.pause();
//       });
//     } else
//       setState(() {
//         controller.play();
//       });
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool videoMuted = false;
//     return FutureBuilder(
//       future: initializeVideoPlayerFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           controller.play();
//           return Stack(
//             children: <Widget>[
//               GestureDetector(
//                 onTap: playOrPauseVideo,
//                 child: AspectRatio(
//                   aspectRatio: controller.value.aspectRatio,
//                   child: VideoPlayer(controller),
//                 ),
//               ),
//               Container(
//                 child: Row(
//                   children: <Widget>[
//                     playbackButton,
//                     Expanded(
//                       child: Container(),
//                     ),
//                     IconButton(
//                       icon: videoMuted
//                           ? Icon(Icons.surround_sound)
//                           : Icon(Icons.volume_mute),
//                       onPressed: () {
//                         setState(() {
//                           if (videoMuted) {
//                             controller.setVolume(1);
//                           } else {
//                             controller.setVolume(0);
//                           }
//                           videoMuted = !videoMuted;
//                         });
//                       },
//                     )
//                   ],
//                 ),
//               )
//             ],
//           );
//         } else {
//           return Container(
//             color: Colors.grey,
//             height: MediaQuery.of(context).size.width / aspectRatio,
//           );
//         }
//       },
//     );
//   }
// }

class DownvoteTile extends StatefulWidget {
  final Vote vote;
  final int postId;
  final Function callback;
  DownvoteTile(this.vote, this.postId, this.callback);
  @override
  DownvoteTileState createState() => DownvoteTileState();
}

class DownvoteTileState extends State<DownvoteTile> {
  Vote vote;
  @override
  void initState() {
    vote = widget.vote;
    print(vote);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(vote);
    return ListTile(
      dense: true,
      leading: Transform.rotate(
        angle: 59.7,
        child: Icon(
            vote == Vote.down
                ? FluentIcons.keyboard_shift_24_filled
                : FluentIcons.keyboard_shift_24_regular,
            size: 24.0,
            color: vote == Vote.down
                ? Colors.red
                : Theme.of(context).iconTheme.color),
      ),
      title: Text('Downvote'),
      onTap: () {
        print('postid : ${widget.postId}');
        PostFunctions().handleDownvoteButton(widget.postId, vote);
        if (vote == Vote.down) {
          setState(() {
            vote = Vote.none;
          });
        } else
          setState(() {
            vote = Vote.down;
          });
        widget.callback();
      },
    );
  }
}

class ExpandIconPainter extends CustomPainter {
  //         <-- CustomPainter class
  bool up;
  BuildContext context;
  ExpandIconPainter(this.up, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Theme.of(context).iconTheme.color.withOpacity(0.6)
      ..strokeWidth = 3;
    if (up) {
      canvas.drawLine(Offset(0, 16), Offset(12, 8), paint);
      canvas.drawLine(Offset(12, 8), Offset(24, 16), paint);
    } else {
      canvas.drawLine(Offset(0, 8), Offset(12, 16), paint);
      canvas.drawLine(Offset(12, 16), Offset(24, 8), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) {
    return false;
  }
}

//video player old
// _controller = VideoPlayerController.network(
//   contents['$i'],
// );
// _initializeVideoPlayerFuture = _controller.initialize().then((_) {
//     if (PreferencesUpdate().getBool('autoplay_videos') == null) {
//       PreferencesUpdate().updateBool('autoplay_videos', false);
//     }
//     bool _autoplay = PreferencesUpdate().getBool('autoplay_videos');
//     flickManager = FlickManager(
//       videoPlayerController: _controller,
//     );
// print(  contents['$i'],);
// print('video url');
