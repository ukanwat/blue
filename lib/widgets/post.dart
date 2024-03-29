// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';

// Flutter imports:
import 'package:flutter/rendering.dart';
import 'package:blue/widgets/progress.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:timeago/timeago.dart';
import 'package:blue/constants/app_colors.dart';
// Package imports:
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:show_overlay/show_overlay.dart' as ov;
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// Project imports:
import 'package:blue/constants/strings.dart';
import 'package:blue/main.dart';
import '../services/video.dart';
import 'package:blue/state_management/posts_tracker.dart';
import 'package:blue/screens/profile_screen.dart';
import 'package:blue/screens/tag_screen.dart';
import 'package:blue/services/dynamic_links.dart';
import 'package:blue/services/link_preview.dart';
import 'package:blue/services/post_functions.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/services/video_controls.dart';
import 'package:blue/widgets/dialogs/report_dialog.dart';
import 'package:blue/widgets/dialogs/repost_dialog.dart';
import 'package:blue/widgets/dialogs/save_dialog.dart';
import 'package:blue/widgets/dialogs/show_dialog.dart';
import 'package:video_viewer/video_viewer.dart';
import '../screens/comments_screen.dart';
import '../services/boxes.dart';
import '../services/functions.dart';
import '../services/functions.dart';
import '../services/go_to.dart';
import '../services/hasura.dart';
import './custom_image.dart';
import 'package:linkfo/linkfo.dart';

// import 'package:flick_video_player/flick_video_player.dart';
List<int> expandedPosts = [];
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
  final String subtitle;
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
  final String thumbUrl;
  final bool notInterested;
  final bool postActionExists;
  final Color color;
  final double radius;
  final bool moreCompact;
  // final PostInteractions postInteractions;

  Post(
      {Key key,
      this.postId,
      this.ownerId,
      this.username,
      this.photoUrl,
      this.title,
      this.subtitle,
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
      this.upvoted,
      this.notInterested,
      this.thumbUrl,
      this.postActionExists,
      this.color,
      this.moreCompact,
      this.radius})
      : super(key: key);

  factory Post.fromDocument(Map doc,
      {bool isCompact,
      bool commentsShown,
      Color color,
      double radius,
      bool moreCompact}) {
    if (isCompact == null) isCompact = false;
    if (commentsShown == null) commentsShown = false;
    Map data = {};
    List _tags = [];
    var list = doc['contents'];
    if (list.runtimeType == String) {
      list = json.decode(list);
    }

    int i = 0;
    list.forEach((element) {
      data['$i'] = element['data'];
      i++;
    });
    print(data);
    var tagDataList = doc['post_tags'];
    if (tagDataList != null) {
      tagDataList.forEach((element) {
        _tags.add(element['tg']['tag']);
      });
    }
    if (doc['actions_by_user'] == null) {
      doc['actions_by_user'] = {};
    } else {
      doc['actions_by_user'] = doc['actions_by_user'][0];
    }

    return Post(
      key: ValueKey("post_${doc['post_id']}"),
      upvoted: doc['actions_by_user']['up'],
      postId: doc['post_id'],
      subtitle: doc['subtitle'],
      ownerId: doc['owner_id'],
      username: doc['user']['username'] ?? '',
      photoUrl: doc['user']['avatar_url'] ?? Strings.emptyAvatarUrl,
      title: doc['title'] ?? '',
      topicName: null,
      topicId: null,
      thumbUrl: doc['thumbnail'],
      contents: data,
      contentsInfo: list,
      upvotes: doc['upvote_count'],
      downvotes: doc['downvote_count'],
      votes: 0,
      tags: _tags,
      time: doc['created_at'], //TODO
      isCompact: isCompact == true,
      commentsShown: commentsShown,
      commentCount: doc['comment_count'],
      comments: doc['comments'],
      saves: doc['save_count'],
      shares: doc['share_count'],
      postActionExists: doc['actions_by_user']['time'] != null,
      color: color,
      radius: radius, moreCompact: moreCompact,
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
      thumbUrl: this.thumbUrl,
      tags: this.tags,
      commentCount: this.commentCount,
      subtitle: this.subtitle);
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
  FlickManager flickManager;
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
  String thumbUrl;
  final String subtitle;
  bool containsLink;
  String thumbUrlLink;
  _PostState(
      {this.postId,
      this.ownerId,
      this.username,
      this.photoUrl,
      this.subtitle,
      this.title,
      this.topicName,
      this.topicId,
      this.contents,
      this.contentsInfo,
      this.upvotes,
      this.tags,
      this.votes,
      this.downvotes,
      this.commentCount,
      this.thumbUrl});
  //
  Vote vote = Vote.none;
  bool isOwner = false;
  double screenWidth;
  bool tagBarVisible = false;
  bool notInterested = false;
  CompactPostThumbnailType thumbnailType;
  OverlayEntry overlayOptions;
  bool isFollowing = false;
  GlobalKey _contentsKey = GlobalKey();
  double contentsHeight;
  String compactPostText;

  showOptions(BuildContext context) {
    createOverlayOptions(context);
    // Overlay.of(context).insert(overlayOptions);
  }

  Function createOverlayOptions(BuildContext context) {
    RenderBox getBox = context.findRenderObject();
    Offset position = getBox.localToGlobal(Offset.zero);

    return ov.showOverlay(
        context: context,
        // animationDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        builder: (_, __, close) {
          return Stack(
            children: <Widget>[
              Positioned.fill(
                  child: GestureDetector(
                onDoubleTap: close,
                onTap: close,
                child: Container(
                  color: Colors.transparent,
                ),
              )),
              Positioned(
                left: widget.isCompact == true ? null : position.dx + 10,
                top: widget.isCompact == true ? null : position.dy + 10,
                bottom: widget.isCompact == true
                    ? MediaQuery.of(context).size.height -
                        position.dy -
                        MediaQuery.of(context).padding.vertical -
                        getBox.size.height +
                        10
                    : null,
                right: widget.isCompact == true ? 10 : null,
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
                            close();
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
                            close();
                            setState(() {
                              notInterested = true;
                            });
                            Future.delayed(Duration(seconds: 3))
                                .then((value) async {
                              if (actionExists) {
                                await Hasura.updatePostAction(
                                    postId, 'not_interested:true');
                              } else {
                                await Hasura.insertPostAction(
                                    postId, 'not_interested:true');
                              }
                              actionExists = true;
                            });
                          },
                        ),
                        if (ownerId != currentUser.userId)
                          DownvoteTile(vote, postId, () {
                            close();
                            if (vote == Vote.down) {
                              setState(() {
                                vote = Vote.none;
                              });
                              unvote();
                            } else
                              setState(() {
                                vote = Vote.down;
                              });
                          }, actionExists),
                        if (isFollowing)
                          ListTile(
                            dense: true,
                            leading: Icon(
                              FluentIcons.person_delete_24_regular,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            onTap: () async {
                              close();
                              Functions().handleUnfollowUser(
                                  widget.ownerId); //TODO wait for future
                              setState(() {
                                isFollowing = false;
                              });
                            },
                            title: Text('Unfollow'),
                          ),
                        if (Boxes.currentUserBox.get('user_id') == ownerId ||
                            !kReleaseMode)
                          ListTile(
                            dense: true,
                            leading: Icon(
                              FluentIcons.delete_24_regular,
                              color: Colors.red,
                            ),
                            onTap: () async {
                              close();
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
          );
        });
  }

  buildPostHeader() {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: <Widget>[
          Container(
            color: Theme.of(context).backgroundColor,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(
                left: widget.commentsShown ? 50 : 10,
                top: 8,
                right: 10,
                bottom: 0),
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
                        style:
                            PreferencesUpdate().getBool('serif', def: false) ==
                                    true
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
                                    fontFamily: 'Stark Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                    wordSpacing: 0,
                                    height: 1.25,
                                  ),
                        maxLines: 6,
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
                      padding: const EdgeInsets.only(bottom: 0, top: 0),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                '${widget.username}'
                                // · ${_date(DateTime.parse(widget.time).toLocal())}'
                                ,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).iconTheme.color,
                                )),
                            SizedBox(
                              width: 3,
                            ),
                            Text('•'),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              format(DateTime.parse(widget.time), locale: 'en'),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                if (!isFollowing &&
                    !(widget.ownerId == Boxes.currentUserBox.get('user_id')))
                  Container(
                      height: 16,
                      child: GestureDetector(
                        onTap: () async {
                          Functions().handleFollowUser(
                              widget.ownerId); // TODO wait for future
                          setState(() {
                            isFollowing = true;
                          });
                        },
                        child: Text(
                          'Follow',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blue),
                        ),
                      )),
                SizedBox(
                  width: 12,
                )
                // tagBarVisible
                //     ? GestureDetector(
                //         onTap: () {
                //           setState(() {
                //             tagBarVisible = false;
                //           });
                //         },
                //         child: Container(
                //           height: 38,
                //           padding: const EdgeInsets.only(
                //             left: 15,
                //             right: 15,
                //           ),
                //           child: Icon(
                //             FluentIcons.chevron_up_16_filled,
                //             size: 22,
                //           ),
                //         ),
                //       )
                //     : GestureDetector(
                //         onTap: () async {
                //           setState(() {
                //             tagBarVisible = true;
                //           });
                //         },
                //         child: Container(
                //           height: 38,
                //           padding: const EdgeInsets.only(
                //             left: 15,
                //             right: 15,
                //           ),
                //           child: Icon(
                //             FluentIcons.chevron_down_16_filled,
                //             size: 22,
                //           ),
                //         ),
                //       ),
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
    return Container(
      child: Stack(children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        EdgeInsets.only(left: 12, top: 8, right: 5, bottom: 3),
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily:
                            PreferencesUpdate().getBool('serif', def: false) ==
                                    true
                                ? 'Georgia'
                                : 'Stark Sans',
                        fontWeight:
                            PreferencesUpdate().getBool('serif', def: false) ==
                                    true
                                ? FontWeight.w400
                                : FontWeight.w600,
                      ),
                      maxLines: widget.moreCompact == true ? 3 : 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 12, top: 0, right: 5, bottom: 3),
                    child: Text(
                      subtitle ?? compactPostText ?? '',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            Theme.of(context).iconTheme.color.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: widget.moreCompact == true ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (thumbUrl != null)
              Container(
                margin: const EdgeInsets.all(5.0),
                height: 120,
                width: 120,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      child: cachedNetworkImage(context, thumbUrl),
                      height:
                          min(MediaQuery.of(context).size.width * 0.20, 200),
                      width: min(MediaQuery.of(context).size.width * 0.20, 200),
                    )),
              )
            else
              Container(
                margin: const EdgeInsets.all(8.0),
                height: MediaQuery.of(context).size.width * 0.20,
              )
          ],
        ),
      ]),
    );
  }

  deletePost() async {
    showDialog(
        context: context,
        builder: (context) => ShowDialog(
              title: 'Delete Post',
              description: 'Are you sure you want to delete this Post?',
              middleButtonText: 'Cancel',
              topButtonText: 'Delete',
              middleButtonFunction: () {
                Navigator.pop(context);
              },
              topButtonFunction: () async {
                Hasura.deletePost(postId);
                Navigator.of(context).pop();
                setState(() {
                  deleted = true;
                });
              },
            ));
  }

  unvote() async {}

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
                  return InkWell(
                    onTap: () async {
                      Navigator.of(context)
                          .pushNamed(TagScreen.routeName, arguments: tags[i]);
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
    for (int i = 0; i < contents.length; i++) {
      if (contentsInfo[i]['type'] == 'image') {
        if (thumbnailType != CompactPostThumbnailType.video) {
          thumbnailType = CompactPostThumbnailType.image;
        }
        contentsViewList.add(imageContentContainer(contents['$i'],
            contentsInfo[i]['aspectRatio'], contentsInfo[i]['blurHash']));
      } else if (contentsInfo[i]['type'] == 'video') {
        thumbnailType = CompactPostThumbnailType.video;
        // VideoPlayerController vC = VideoPlayerController.network(
        //   contents['$i'],
        // );
        // flickManager = FlickManager(
        //   autoPlay: PreferencesUpdate().getBool('autoplay_videos') ?? true,
        //   videoPlayerController: vC,
        // );

        contentsViewList.add(Video(contents['$i'],
            contentsInfo[i]['aspectRatio'], contentsInfo[i]['thumbUrl']));
      } else if (contentsInfo[i]['type'] == 'text') {
        contentsViewList.add(textContentContainer(contents['$i']));
        if (compactPostText == null) {
          compactPostText = contents['$i'];
          compactPostText = compactPostText.substring(
              0, contents['$i'].length > 200 ? 200 : contents['$i'].length);
        }
      } else if (contentsInfo[i]['type'] == 'link') {
        if (containsLink != true) {
          containsLink = true;
          thumbUrlLink = contents['$i'];
        }
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
    if (thumbUrlLink != null && thumbUrl == null) {
      getThumbFromLink();
    }
    tags.forEach((element) {
      hashtags.add(Container(
        child: InkWell(
          onTap: () async {
            Navigator.of(context)
                .pushNamed(TagScreen.routeName, arguments: element);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: Text(
              '#$element',
              style: TextStyle(fontSize: 15, color: AppColors.blue),
            ),
          ),
        ),
      ));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => getContentSize);
    super.didChangeDependencies();
  }

  List<Widget> hashtags = [];

  getThumbFromLink() async {
    Client client = Client();
    final response = await client.get(Uri.parse(thumbUrlLink));
    var scrape = TwitterCardsScraper(body: response.body, url: thumbUrlLink);
    final info = scrape.scrape();
    print(info.image);
    setState(() {
      thumbUrl = info.image ??
          'https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/link-line-outline-icon-for-website-and-mobile-app-on-grey-background-free-vector.jpg?alt=media&token=3b5d5b34-2828-42c4-969c-86a73c752419';
    });
  }

  Widget imageContentContainer(
      String url, double aspectRatio, String blurHash) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        FullScreenWidget(
          child: Center(
            child: Hero(
                tag: '${Uuid().v4()}',
                child: PostImage(url, aspectRatio, blurHash)),
          ),
        ),
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
          dotIncreasedColor: Colors.white,
          dotColor: Colors.grey.withOpacity(0.5),
          showIndicator: true,
          dotPosition: DotPosition.bottomCenter,
          dotSpacing: 15,
          boxFit: BoxFit.fitWidth,
          dotBgColor: Colors.transparent,
          autoplay: false,
          overlayShadow: false,
          moveIndicatorFromBottom: 20,
          images: List.generate(urls.length, (i) {
            return FullScreenWidget(
                child: Center(
              child: Hero(
                  tag: '${Uuid().v4()}',
                  child: PostImage(urls[i], aspectRatio, blurHashes[i])
                  // cachedNetworkImage(context, urls[i],
                  //     aspectRatio: aspectRatio, blurHash: blurHashes[i])
                  ),
            ));
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
          fontFamily: 'Stark Sans',
          fontSize: 16,
          letterSpacing: 0,
          wordSpacing: 0,
          height: 1.25,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  Functions().launchURL(link, context);
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

  bool increment;

  Widget saveBar() {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 6),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors.blue.withOpacity(0.15)),
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
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ))
            ],
          ),
        ));
  }

  buildPostFooter() {
    return GetBuilder<PostGet>(
        init: PostGet(),
        id: postId,
        builder: (value) {
          return Container(
            padding: EdgeInsets.only(top: 0),
            child: Column(
              children: <Widget>[
                if (showSaveBar && widget.isCompact != true) saveBar(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    if (widget.isCompact)
                      SizedBox(
                        width: 6,
                      ),
                    isSaved
                        ? FooterButton(
                            FluentIcons.bookmark_24_filled,
                            () async {
                              value.setSaved(false, postId);
                              setState(() {
                                isSaved = false;
                                showSaveBar = false;
                              });
                              Boxes.saveBox.delete(postId);
                              await Hasura.deleteSavedPost(postId);
                            },
                            count: widget.saves,
                          )
                        : FooterButton(
                            FluentIcons.bookmark_24_regular,
                            () async {
                              value.setSaved(true, postId);
                              setState(() {
                                isSaved = true;
                              });

                              await Hasura.insertSavedPost(postId);
                              Boxes.saveBox.put(postId, true);

                              setState(() {
                                showSaveBar = true;
                              });
                              Future.delayed(const Duration(milliseconds: 4000),
                                  () {
                                setState(() {
                                  showSaveBar = false;
                                });
                              });
                            },
                            count: value.getSaved(postId) == null
                                ? widget.saves
                                : value.getSaved(postId)
                                    ? widget.saves + 1
                                    : widget.saves - 1,
                          ),
                    FooterButton(FluentIcons.share_24_regular, () async {
                      String _link =
                          await DynamicLinksService.createDynamicLink(
                              'post?id=$postId');
                      Share.share(_link, subject: 'Sharing this Post');

                      await Hasura.postShareAction(postId, actionExists);
                      actionExists = true;
                    }, count: widget.shares),
                    if (!(widget.commentsShown || widget.isCompact))
                      FooterButton(FluentIcons.comment_24_regular, () {
                        showComments(context,
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
                              notInterested: widget.notInterested,
                              postActionExists: widget.postActionExists,
                              thumbUrl: widget.thumbUrl,
                              upvoted: widget.upvoted,
                            ),
                            index: 1);
                      }, count: widget.commentCount),
                    Padding(
                      padding: EdgeInsets.only(
                          right: widget.isCompact == true ? 0 : 5),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            if (isOwner) {
                              return;
                            }
                            if (vote == null) {
                              return;
                            }
                            await PostFunctions()
                                .handleUpvoteButton(postId, vote, actionExists);
                            actionExists = true;
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
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 6, left: 6, right: 6, top: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                    vote == Vote.up
                                        ? FluentIcons.star_24_filled
                                        : FluentIcons.star_24_regular,
                                    // vote == Vote.up
                                    //     ? FluentIcons.keyboard_shift_24_filled
                                    //     : FluentIcons.keyboard_shift_24_regular,
                                    size: 25.0,
                                    color: isOwner
                                        ? AppColors.blue.withOpacity(0.7)
                                        : AppColors.blue),
                                SizedBox(
                                  width: 5,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    increment == null
                                        ? '${Functions.abbreviateNumber(upvotes, hideLess: true)}'
                                        : increment
                                            ? '${Functions.abbreviateNumber(upvotes + 1, hideLess: true)}'
                                            : '${Functions.abbreviateNumber(upvotes - 1, hideLess: true)}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        height: 1,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Stark Sans'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 2),
                ),
              ],
            ),
          );
        });
  }

  @override
  void dispose() async {
    // _controller?.dispose();

    super.dispose();
  }

  bool alreadyUpvoted = false;
  bool actionExists;
  @override
  void initState() {
    actionExists = widget.postActionExists;
    isOwner = Boxes.currentUserBox.get('user_id') == widget.ownerId;

    if (Boxes.followingBox.containsKey(ownerId)) {
      isFollowing = true;
    }
    voteSet();
    if (expandedPosts.contains(widget.postId)) {
      showExpand = false;
    }

    expanded = false || expandedPosts.contains(widget.postId);
    super.initState();
  }

  voteSet() {
    if (widget.upvoted == true) {
      vote = Vote.up;
    } else if (widget.upvoted == false) {
      vote = Vote.down;
    } else {
      vote = Vote.none;
    }
  }

  getContentSize() {
    // RenderBox _contentsBox = _contentsKey.currentContext.findRenderObject();
    // setState(() {
    //   contentsHeight = _contentsBox.size.height;
    //   if (contentsHeight > MediaQuery.of(context).size.height) {
    //     expanded = false;
    //   }
    // });
  }
  bool showExpand = false;
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    deleted = widget.notInterested == true || deleted;
    return (deleted == true || widget.notInterested == true)
        ? Container()
        : notInterested == true //can do some other stuff
            ? Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    border: Border.fromBorderSide(BorderSide(
                        color: Colors.grey.withOpacity(0.4), width: 1))),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "You won't see this post again",
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          notInterested = false;
                        });
                        try {
                          Boxes.notInterestedBox.delete(postId);
                        } catch (e) {}
                      },
                      child: Text(
                        'Undo',
                        style: TextStyle(
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Material(
                    borderRadius: BorderRadius.circular(widget.radius ?? 0),
                    color: widget.color == null
                        ? Theme.of(context).backgroundColor
                        : widget.color,
                    child: InkWell(
                      onLongPress: widget.isCompact
                          ? () {
                              showOptions(context);
                            }
                          : null,
                      borderRadius: BorderRadius.circular(widget.radius ?? 0),
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
                                  notInterested: widget.notInterested,
                                  postActionExists: actionExists,
                                  thumbUrl: widget.thumbUrl,
                                  upvoted: widget.upvoted,
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
                            LayoutBuilder(builder: (BuildContext context,
                                BoxConstraints constraints) {
                              return Stack(
                                children: [
                                  MeasureSize(
                                    onChange: (size) {
                                      setState(() {
                                        if (size.height ==
                                                MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.8 &&
                                            !showExpand) {
                                          setState(() {
                                            showExpand = true;
                                          });
                                        }
                                      });
                                    },
                                    child: ConstrainedBox(
                                        constraints: expanded
                                            ? BoxConstraints()
                                            : BoxConstraints(
                                                maxHeight:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.8),
                                        child: ListView.builder(
                                          key: _contentsKey,
                                          padding: EdgeInsets.all(0),
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (_, i) {
                                            return contentsViewList[i];
                                          },
                                          itemCount: contents.length,
                                        )),
                                  ),
                                  if (showExpand)
                                    Positioned(
                                      bottom: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          expandedPosts.add(postId);
                                          setState(() {
                                            expanded = true;
                                            showExpand = false;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                Theme.of(context)
                                                    .backgroundColor
                                                    .withOpacity(0.7),
                                                Theme.of(context)
                                                    .backgroundColor,
                                              ],
                                                  stops: [
                                                0,
                                                1,
                                              ])),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 30,
                                          child: Center(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Expand',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                                Icon(
                                                  FluentIcons
                                                      .chevron_down_12_filled,
                                                  size: 20,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              );
                            }),
                          if (widget.isCompact != true && hashtags.length > 0)
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Wrap(
                                spacing: 1.0, // gap between adjacent chips
                                runSpacing: 1.0, // gap between lines
                                children: hashtags,
                              ),
                            ),
                          if (widget.isCompact)
                            if (tagBarVisible) tagBar(),
                          (widget.isCompact != true)
                              ? buildPostFooter()
                              : Column(
                                  children: [
                                    if (showSaveBar) saveBar(),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            SizedBox(
                                              width: 10,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                GoTo().profileScreen(
                                                    context, widget.ownerId);
                                              },
                                              child: Container(
                                                constraints: BoxConstraints(
                                                    maxWidth: 500, minWidth: 0),
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 14,
                                                      backgroundImage:
                                                          CachedNetworkImageProvider(
                                                              photoUrl ??
                                                                  "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
                                                      backgroundColor:
                                                          Colors.grey,
                                                    ),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Container(
                                                      height: 32,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            username,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          Container(
                                                            height: 14,
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  format(
                                                                      DateTime.parse(
                                                                          widget
                                                                              .time),
                                                                      locale:
                                                                          'en_short'),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                                SizedBox(
                                                                  width: 3,
                                                                ),
                                                                if (!isFollowing &&
                                                                    !(widget.ownerId ==
                                                                        Boxes
                                                                            .currentUserBox
                                                                            .get('user_id')))
                                                                  Text(
                                                                    '•',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                if (!isFollowing &&
                                                                    !(widget.ownerId ==
                                                                        Boxes
                                                                            .currentUserBox
                                                                            .get('user_id')))
                                                                  SizedBox(
                                                                    width: 3,
                                                                  ),
                                                                if (!isFollowing &&
                                                                    !(widget.ownerId ==
                                                                        Boxes
                                                                            .currentUserBox
                                                                            .get(
                                                                                'user_id')))
                                                                  Container(
                                                                      height:
                                                                          14,
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          Functions()
                                                                              .handleFollowUser(widget.ownerId); // TODO wait for future
                                                                          setState(
                                                                              () {
                                                                            isFollowing =
                                                                                true;
                                                                          });
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          'Follow',
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style: TextStyle(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: AppColors.blue),
                                                                        ),
                                                                      )),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                ),
                                              ),
                                            ),
                                            // if (widget.isCompact)
                                            //   tagBarVisible
                                            //       ? FooterButton(
                                            //           FluentIcons
                                            //               .chevron_up_24_filled,
                                            //           () {
                                            //           setState(() {
                                            //             tagBarVisible = false;
                                            //           });
                                            //         })
                                            //       : FooterButton(
                                            //           FluentIcons
                                            //               .chevron_down_24_filled,
                                            //           () async {
                                            //           setState(() {
                                            //             tagBarVisible = true;
                                            //           });
                                            //         }),

                                            Expanded(
                                              child: Container(),
                                            ),
                                            Padding(
                                              child: buildPostFooter(),
                                              padding: EdgeInsets.only(
                                                  top: 4, right: 0),
                                            ),
                                            // Padding(
                                            //   padding: const EdgeInsets.only(
                                            //       right: 0, left: 0),
                                            //   child: Material(
                                            //     color: Colors.transparent,
                                            //     child: InkWell(
                                            //       customBorder: new CircleBorder(),
                                            //       onTap: () {
                                            //         showOptions(context);
                                            //       },
                                            //       child: Padding(
                                            //         padding: const EdgeInsets.only(
                                            //             top: 6, right: 2, left: 3),
                                            //         child: Column(
                                            //           children: [
                                            //             Icon(
                                            //               FluentIcons
                                            //                   .more_vertical_24_filled,
                                            //               size: 22,
                                            //             ),
                                            //             Text(
                                            //               '',
                                            //               maxLines: 1,
                                            //               style: TextStyle(
                                            //                   fontSize: 11,
                                            //                   height: 1,
                                            //                   fontWeight:
                                            //                       FontWeight.w800,
                                            //                   fontFamily:
                                            //                       'Stark Sans'),
                                            //             )
                                            //           ],
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ),
                                            //   // if (widget.count != null)
                                            // ),
                                          ]),
                                    ),
                                  ],
                                ),
                          SizedBox(
                            height: 5,
                          )
                        ],
                      ),
                    ),
                  ),
                  if (widget.radius == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Divider(
                        thickness: widget.isCompact ? 2 : 8,
                        indent: 0,
                        endIndent: 0,
                        color: Colors.grey.withOpacity(0.2),
                        height: widget.isCompact ? 2 : 8,
                      ),
                    ),
                ],
              );
  }
}

showComments(BuildContext context, {Post post, int index}) {
  Navigator.pushNamed(context, CommentsScreen.routeName,
      arguments: {'post': post, 'index': index ?? 0});
}

class DownvoteTile extends StatefulWidget {
  final Vote vote;
  final int postId;
  final Function callback;
  final bool postActionExists;
  DownvoteTile(this.vote, this.postId, this.callback, this.postActionExists);
  @override
  DownvoteTileState createState() => DownvoteTileState();
}

class DownvoteTileState extends State<DownvoteTile> {
  Vote vote;
  @override
  void initState() {
    vote = widget.vote;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading:
          //  Transform.rotate(
          //   angle: 59.7,
          // child:
          Icon(
              vote == Vote.down
                  ? FluentIcons.star_off_24_filled
                  : FluentIcons.star_off_24_regular,
              // vote == Vote.down
              //     ? FluentIcons.keyboard_shift_24_filled
              //     : FluentIcons.keyboard_shift_24_regular,
              size: 24.0,
              color: vote == Vote.down
                  ? Colors.red
                  : Theme.of(context).iconTheme.color),
      // ),
      title: Text('Unstar'),
      onTap: () {
        PostFunctions()
            .handleDownvoteButton(widget.postId, vote, widget.postActionExists);
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

class FooterButton extends StatefulWidget {
  final Function function;
  final IconData iconData;
  final int count;
  final Color color;

  const FooterButton(this.iconData, this.function, {this.count, this.color});

  @override
  _FooterButtonState createState() => _FooterButtonState();
}

class _FooterButtonState extends State<FooterButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0, left: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            customBorder: new RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
            onTap: widget.function,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(),
                    child: Icon(
                      widget.iconData,
                      size: 25,
                      color: widget.color ?? Theme.of(context).iconTheme.color,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      Functions.abbreviateNumber(widget.count ?? 0,
                          hideLess: true),
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 18,
                          height: 1,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Stark Sans'),
                    ),
                  )
                ],
              ),
            )),
      ),
      // if (widget.count != null)
    );
  }
}

typedef void OnWidgetSizeChange(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size oldSize;
  final OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key key,
    @required this.onChange,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }
}
