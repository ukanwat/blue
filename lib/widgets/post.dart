import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:blue/screens/explore_posts_screen.dart';
import 'package:blue/screens/profile_screen.dart';
import 'package:blue/services/link_preview.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/services/video_controls.dart';
import 'package:blue/widgets/report_dialog.dart';
import 'package:blue/widgets/repost_dialog.dart';
import 'package:blue/widgets/save_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:video_player/video_player.dart';
import 'package:blue/screens/tag_screen.dart';
import 'package:blue/main.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;
import './custom_image.dart';
import '../screens/home.dart';
import '../screens/comments_screen.dart';
import '../services/go_to.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/functions.dart';

enum CompactPostThumbnailType {
  video,
  image,
  link,
}
enum Vote{
  down,
  up,
  none
}
class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String photoUrl;
  final String title;
  final String topicName;
  final String topicId;
  final Map contents;
  final Map contentsInfo;
  final int upvotes;
   final int downvotes;
    final int votes;
  final List<dynamic> tags;
  final bool isCompact;
  final bool commentsShown;
  final Timestamp time;
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
      this.commentsShown, // this.postInteractions
      this.time});

  factory Post.fromDocument(Map doc, {bool isCompact, bool commentsShown}) {
    if (isCompact == null) isCompact = false;
    if (commentsShown == null) commentsShown = false;
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      title: doc['title'],
      topicName: doc['topicName'],
      topicId: doc['topicId'],
      contents: doc['contents'],
      contentsInfo: doc['contentsInfo'],
      upvotes: doc['upvotes'],
      downvotes: doc['downvotes'],
      votes: doc['votes'],
      tags: doc['tags'],
      time: doc['timeStamp'], //TODO
      isCompact: isCompact,
      commentsShown: commentsShown,
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
      tags: this.tags);
}

class _PostState extends State<Post> {
  double topEdgeHeight;
  double bottomEdgeHeight;
  bool showSaveBar = false;
  final GlobalKey trackKey = GlobalKey();
  Widget playbackButton = Container();
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  bool isSaved = false;
  List<Widget> contentsViewList = [];
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String photoUrl;
  final String title;
  final String topicName;
  final String topicId;
  final Map contents;
  final Map contentsInfo;
  final List<dynamic> tags;
  final int votes;
    final int upvotes;
      final int downvotes;
  _PostState({
    this.postId,
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
    this.downvotes
  });
  //
  Vote vote =Vote.none; 
  bool isOwner = false;
  double screenWidth;
  bool tagBarVisible = false;
  bool notInterested = false;
  var compactPostThumbnailData;
  CompactPostThumbnailType thumbnailType;
  OverlayEntry overlayOptions;
  bool isFollowing = false;
  FlickManager flickManager;
  final GlobalKey _contentsKey = GlobalKey();
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
                    elevation: 0.0,
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
                          ListTile(
                            dense: true,
                            leading: Transform.rotate(
                              angle: 59.7,
                              child: Icon(
                                 vote == Vote.down
                                ? FluentIcons.keyboard_shift_24_filled
                                : FluentIcons.keyboard_shift_24_regular,
                            size: 24.0,
                            color:   vote == Vote.down
                                ?Colors.red: Theme.of(context).iconTheme.color
                              ),
                            ),
                            title: Text('Downvote'),
                            onTap: () {
                             
                              handleDownvoteButton();
                            },
                          ),
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
                    backgroundImage: CachedNetworkImageProvider(photoUrl),
                    backgroundColor: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                        // 'Hope you weren’t planning to watchiiiii Wonder Woman 1984 with an HBO Max free trial', ///////******/

                        widget.title,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'OpenSans',
                            fontSize: 16),
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
                      padding: const EdgeInsets.only(
                          bottom: 6, left: 15, right: 16, top: 3),
                      child: Icon(
                        FluentIcons.more_20_filled,
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
                      if (!isFollowing && !(widget.ownerId == currentUserId))
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
                    ? Container(
                        height: 38,
                        padding: const EdgeInsets.only(
                            bottom: 6, left: 15, right: 15, top: 3),
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
                    : Container(
                        height: 38,
                        padding: const EdgeInsets.only(
                            bottom: 6, left: 15, right: 15, top: 3),
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
                              backgroundImage:
                                  CachedNetworkImageProvider(photoUrl),
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
                      if (!isFollowing && !(widget.ownerId == currentUserId))
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
                            child: Icon(
                              FluentIcons.more_20_filled,
                            ),
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

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Remove this post?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel')),
            ],
          );
        });
  }

  deletePost() async {
    if(widget.ownerId != currentUser.id)
    return;
    // delete post itself
    postsRef.doc(ownerId).collection('userPosts').doc(postId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete uploaded image for thep ost
    // storageRef.child("post_$postId.jpg").delete();  // TODO: delete stored media
    // then delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .doc(ownerId)
        .collection("feedItems")
        .where('postId', isEqualTo: postId)
        .get();
    activityFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // then delete all comments
    QuerySnapshot commentsSnapshot =
        await commentsRef.doc(postId).collection('comments').get();
    commentsSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }
  unvote()async{
 if (PreferencesUpdate().getBool('votes_downloaded') == null ||
        PreferencesUpdate().getBool('votes_downloaded') == false) {
      QuerySnapshot query = await postsVotersRef
          .doc(currentUser.id)
          .collection('userVotes')
          .where('ids', arrayContains: widget.postId)
          .limit(1)
          .get();
      List<String> ids = query.docs.first.data()['ids'];
      List<bool> votes = query.docs.first.data()['votes'];
      int index = ids.indexOf(widget.postId);
        votes.removeAt(index);
        await postsVotersRef
            .doc(currentUser.id)
            .collection('userVotes')
            .doc(query.docs.first.id)
            .update({
              'ids':FieldValue.arrayRemove([widget.postId]),
              'votes': votes});
    } else if (PreferencesUpdate().getBool('votes_downloaded')) {
   voteBox.delete(widget.postId);
    }
  }
  handleDownvoteButton() async {
      if(vote == Vote.none){
     postsRef.doc(widget.postId).update({
       'upvotes': FieldValue.increment(-1),
       'votes': FieldValue.increment(-1),
     });
    }else if(vote == Vote.down){
 postsRef.doc(widget.postId).update({
       'upvotes': FieldValue.increment(1),
       'votes': FieldValue.increment(1),
     });
    }else{
       postsRef.doc(widget.postId).update({
       'upvotes': FieldValue.increment(-2),
       'votes': FieldValue.increment(-2),
     });
    }
   if(vote == Vote.down){
 setState(() {
    // DownvoteButtonState().setVote(Vote.none);
      vote = Vote.none;
    });
    unvote();
    
    return;
   
   }
       setState(() {
     vote = Vote.down;
      // DownvoteButtonState().setVote(Vote.down);
    });
    if (PreferencesUpdate().getBool('votes_downloaded') == null ||
        PreferencesUpdate().getBool('votes_downloaded') == false) {
      QuerySnapshot query = await postsVotersRef
          .doc(currentUser.id)
          .collection('userVotes')
          .where('ids', arrayContains: widget.postId)
          .limit(1)
          .get();
      List<String> ids = query.docs.first.data()['ids'];
      List<bool> votes = query.docs.first.data()['votes'];
      int index = ids.indexOf(widget.postId);
      if (votes[index]) {
        votes[index] = false;
        await postsVotersRef
            .doc(currentUser.id)
            .collection('userVotes')
            .doc(query.docs.first.id)
            .set({'votes': votes}, SetOptions(merge: true));
      }
    } else if (PreferencesUpdate().getBool('votes_downloaded')) {
      var _vote = voteBox.get(widget.postId);
      if (_vote == null ? true : _vote) {
        voteBox.put(widget.postId, false);
      }
    }
  }

  handleUpvoteButton() async {
    if(vote == Vote.none){
     postsRef.doc(widget.postId).update({
       'upvotes': FieldValue.increment(1),
       'votes': FieldValue.increment(1),
     });
    }else if(vote == Vote.up){
 postsRef.doc(widget.postId).update({
       'upvotes': FieldValue.increment(-1),
       'votes': FieldValue.increment(-1),
     });
    }else{
       postsRef.doc(widget.postId).update({
       'upvotes': FieldValue.increment(2),
       'votes': FieldValue.increment(2),
     });
    }

   if(vote == Vote.up){
 setState(() {
      vote = Vote.none;
    });
    unvote();
    
    return;
   
   }

  
      setState(() {
     vote = Vote.up;
    });
    
    if (PreferencesUpdate().getBool('votes_downloaded') == null ||
        PreferencesUpdate().getBool('votes_downloaded') == false) {
      QuerySnapshot query = await postsVotersRef
          .doc(currentUser.id)
          .collection('userVotes')
          .where('ids', arrayContains: widget.postId)
          .limit(1)
          .get();
      List<String> ids = query.docs.first.data()['ids'];
      List<bool> votes = query.docs.first.data()['votes'];
      int index = ids.indexOf(widget.postId);
      if (!votes[index]) {
        votes[index] = true;
        await postsVotersRef
            .doc(currentUser.id)
            .collection('userVotes')
            .doc(query.docs.first.id)
            .set({'votes': votes}, SetOptions(merge: true));
      }
    } else if (PreferencesUpdate().getBool('votes_downloaded')) {
       var _vote = voteBox.get(widget.postId);
      if (_vote == null ? true : !_vote) {
        voteBox.put(widget.postId, true);
      }
    }
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
                          preferences.getString('tags_open_info');
                      if (tagOpenInfo == null) {
                        preferences.setString(
                            'tags_open_info', json.encode({}));
                        tagOpenInfo = json.encode({});
                      }
                      DateTime nowTime = DateTime.now();
                      String todayTime = DateTime.parse(
                              "${nowTime.year}-${nowTime.month}-${nowTime.day}")
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
                      preferences.setString(
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
    if (this.mounted && persistentCallbackAdded == false) {
      persistentCallbackAdded = true;
    }
    print(contents);
    for (int i = 0; i < contents.length; i++) {
      print(contents['$i']);
      print(contentsInfo['$i']);
      if (contentsInfo['$i']['type'] == 'image') {
        if (thumbnailType != CompactPostThumbnailType.video) {
          thumbnailType = CompactPostThumbnailType.image;
          compactPostThumbnailData = contents['$i'];
        }
        contentsViewList.add(imageContentContainer(
            contents['$i'], contentsInfo['$i']['aspectRatio']));
      } else if (contentsInfo['$i']['type'] == 'video') {
        compactPostThumbnailData = contentsInfo['$i']['thumbUrl'];
        thumbnailType = CompactPostThumbnailType.video;
        _controller = VideoPlayerController.network(
          contents['$i'],
        );
        _initializeVideoPlayerFuture = _controller.initialize().then((_) {
          if (preferences.getBool('autoplay_videos') == null) {
            preferences.setBool('autoplay_videos', false);
          }
          bool _autoplay = preferences.getBool('autoplay_videos');
          flickManager = FlickManager(
            videoPlayerController: _controller,
          );
          contentsViewList
              .add(Container(child: VideoDisplay(flickManager, _autoplay)));
        });
      } else if (contentsInfo['$i']['type'] == 'text') {
        contentsViewList.add(textContentContainer(contents['$i']));
      } else if (contentsInfo['$i']['type'] == 'link') {
        contentsViewList.add(linkContentContainer(contents['$i']));
      } else {
        contentsViewList.add(carouselContentContainer(
            contents['$i'], contentsInfo['$i']['aspectRatio']));
      }
    }
    if (!widget.isCompact)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (this.mounted) getContentSize();
      });
    super.didChangeDependencies();
  }

  Widget imageContentContainer(String url, double aspectRatio) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        (cachedNetworkImage(context, url, aspectRatio: aspectRatio)),
      ],
    );
  }

  Widget carouselContentContainer(List<dynamic> urls, double aspectRatio) {
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
                aspectRatio: aspectRatio);
          }),
        ));
  }

  Widget textContentContainer(String text) {
    if (preferences.getBool('serif') == null) {
      preferences.setBool('serif', false);
    }
    return Container(
      child: Text(
        text,
        style: preferences.getBool('serif')
            ? TextStyle(
                fontFamily: 'Georgia',
                fontSize: 17,
                letterSpacing: 0,
                wordSpacing: 0,
                height: 1.25,
                color: Theme.of(context).textSelectionColor)
            : TextStyle(
                fontSize: 16,
                letterSpacing: 0,
                wordSpacing: 0,
                height: 1.25,
                color: Theme.of(context).textSelectionColor),
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
            child: LinkPreview(
              url: link,
              bodyStyle: TextStyle(fontSize: 13),
              titleStyle: TextStyle(fontWeight: FontWeight.w500),
              showMultimedia: true,
            )));
  }

  Widget footerButton(IconData iconData, Color color, Function function) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10),
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
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  buildPostFooter() {
    bool n = (vote == Vote.down || vote == Vote.none);
    bool u = vote == Vote.up;
    bool s = alreadyUpvoted && vote != Vote.up;
    bool a = alreadyUpvoted;
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              if (widget.isCompact)
                tagBarVisible
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: SizedBox(
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
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: SizedBox(
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
                      ),
              if (!widget.isCompact)
                if (contentsHeight != null)
                  if (contentsHeight ==
                          MediaQuery.of(context).size.height * 0.8 ||
                      contentsHeight > MediaQuery.of(context).size.height * 0.8)
                    Padding(
                      padding: const EdgeInsets.only(left: 13),
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
                          child: Transform.rotate(
                            angle: 29.8,
                            child: Icon(
                              constraintContent
                                  ? FluentIcons.arrow_previous_24_regular
                                  : FluentIcons.arrow_next_24_regular,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
              if (!widget.isCompact)
                Expanded(
                  child: Container(),
                ),
              isSaved
                  ? footerButton(FluentIcons.bookmark_24_filled, Colors.blue,
                      () {
                      setState(() {
                        isSaved = false;
                        showSaveBar = false;
                        savedPostsRef // TODO
                            .doc(currentUser?.id)
                            .collection('All')
                            .doc(postId)
                            .delete();
                      });
                    })
                  : footerButton(FluentIcons.bookmark_24_regular, Colors.blue,
                      () async {
                      setState(() {
                        isSaved = true;
                      });
                      var lastDoc = await savedPostsRef
                          .doc(currentUser?.id)
                          .collection('all')
                          .orderBy('order', descending: true)
                          .limit(1)
                          .get();
                      if (lastDoc.docs.length == 0) {
                        savedPostsRef
                            .doc(currentUser?.id)
                            .collection('all')
                            .doc()
                            .set({
                          'order': 1,
                          'posts': [
                            postId,
                          ],
                        }, SetOptions(merge: true));
                      } else if (lastDoc.docs.length == 1 &&
                          lastDoc.docs.first.data()['posts'].length < 2) {
                        List<dynamic> _postIdList =
                            lastDoc.docs.first.data()['posts'];
                        _postIdList.add(postId);
                        savedPostsRef
                            .doc(currentUser?.id)
                            .collection('all')
                            .doc(lastDoc.docs.first.id)
                            .set({
                          'posts': _postIdList,
                        }, SetOptions(merge: true));
                      } else if (lastDoc.docs.length == 1 &&
                          lastDoc.docs.first.data()['posts'].length > 1) {
                        savedPostsRef
                            .doc(currentUser?.id)
                            .collection('all')
                            .doc()
                            .set({
                          'order': lastDoc.docs.first.data()['order'] + 1,
                          'posts': [
                            postId,
                          ],
                        }, SetOptions(merge: true));
                      }
                      setState(() {
                        showSaveBar = true;
                      });
                      Future.delayed(const Duration(milliseconds: 4000), () {
                        setState(() {
                          showSaveBar = false;
                        });
                      });
                    }),
              footerButton(FluentIcons.share_24_regular, Colors.blueAccent, () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => RepostDialog(this.widget),
                );
              }),
              if (!widget.commentsShown)
                footerButton(FluentIcons.comment_24_regular, Colors.cyan, () {
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
                    ),
                  );
                }),
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      
                      handleUpvoteButton();
                    },
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            vote == Vote.up
                                ? FluentIcons.keyboard_shift_24_filled
                                : FluentIcons.keyboard_shift_24_regular,
                            size: 24.0,
                            color:   vote == Vote.up
                                ?Colors.blue: Theme.of(context).iconTheme.color
                          ),
                          Padding(
                              padding: const EdgeInsets.only(right: 3, left: 6),
                              child: Text(
                            ((a&&n)||(!a&&u))?'${(upvotes+1)}':'$upvotes',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 24),
                              ),),
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
    flickManager?.dispose();
    super.dispose();
  }
  checkVoteOnline()async{
   var query = await postsVotersRef.doc(currentUser.id).collection('userVotes').where('ids',arrayContains: widget.postId).get();
    if(query.docs.length == 0)
    return;
    List ids =   query.docs.first.data()['ids'];
     List votes =   query.docs.first.data()['votes'];
    if(ids.contains(widget.postId)){
      if(votes[ids.indexOf(widget.postId)] == true){
           vote = Vote.up;
      }else{
 vote = Vote.down;
      }
    }
  }
 bool alreadyUpvoted = false;
  bool alreadyDownvoted = false;
  @override
  void initState() {
    isOwner = currentUser.id == widget.ownerId;
     if(voteBox.containsKey(widget.postId)){
       if( voteBox.get(widget.postId)){

        alreadyUpvoted = true;
        vote = Vote.up;
       }
        else{
             alreadyDownvoted = true;
 vote = Vote.down;
        }
       
    }else
    if(PreferencesUpdate().getBool('votes_downloaded') == null || PreferencesUpdate().getBool('votes_downloaded') == false)
    {
       checkVoteOnline();
    }

    List<String> followingList = preferences.getStringList('following');
    if (followingList == null) {
      followingList = [];
      preferences.setStringList('following', followingList);
    }

    if (followingList.contains(widget.ownerId))
      setState(() {
        isFollowing = true;
      });

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
    return notInterested //can do some other stuff
        ? Container(
            color: Theme.of(context).backgroundColor,
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
                          Navigator.of(context).pushNamed(
                              ExplorePostsScreen.routeName,
                              arguments: this.widget);
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
                                      MediaQuery.of(context).size.height * 0.8)
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
                thickness: 4,
                color: Theme.of(context).cardColor,
                height: 4,
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

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfileScreen(
        profileId: profileId,
      ),
    ),
  );
}

class VideoContentContainer extends StatefulWidget {
  final Future<dynamic> initializeVideoPlayerFuture;
  final VideoPlayerController controller;
  final double aspectRatio;
  VideoContentContainer(
      {this.initializeVideoPlayerFuture, this.controller, this.aspectRatio});
  @override
  _VideoContentContainerState createState() => _VideoContentContainerState(
      initializeVideoPlayerFuture: this.initializeVideoPlayerFuture,
      controller: this.controller,
      aspectRatio: this.aspectRatio);
}

class _VideoContentContainerState extends State<VideoContentContainer> {
  final Future<dynamic> initializeVideoPlayerFuture;
  final VideoPlayerController controller;
  final double aspectRatio;
  _VideoContentContainerState(
      {this.initializeVideoPlayerFuture, this.controller, this.aspectRatio});
  Widget playbackButton = Container();
  playOrPauseVideo() {
    if (controller.value.isPlaying) {
      setState(() {
        playbackButton = Icon(Icons.play_arrow);
        controller.pause();
      });
    } else
      setState(() {
        controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    bool videoMuted = false;
    return FutureBuilder(
      future: initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          controller.play();
          return Stack(
            children: <Widget>[
              GestureDetector(
                onTap: playOrPauseVideo,
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    playbackButton,
                    Expanded(
                      child: Container(),
                    ),
                    IconButton(
                      icon: videoMuted
                          ? Icon(Icons.surround_sound)
                          : Icon(Icons.volume_mute),
                      onPressed: () {
                        setState(() {
                          if (videoMuted) {
                            controller.setVolume(1);
                          } else {
                            controller.setVolume(0);
                          }
                          videoMuted = !videoMuted;
                        });
                      },
                    )
                  ],
                ),
              )
            ],
          );
        } else {
          return Container(
            color: Colors.grey,
            height: MediaQuery.of(context).size.width / aspectRatio,
          );
        }
      },
    );
  }
}

class DownvoteButton extends StatefulWidget {
  @override
  DownvoteButtonState createState() => DownvoteButtonState();
}
   
class DownvoteButtonState extends State<DownvoteButton> {
  Vote vote;
  setVote(Vote v){
    setState(() {
      vote = v;
    });
  }
  @override
  Widget build(BuildContext context) {
    return   Icon(
                                 vote == Vote.down
                                ? FluentIcons.keyboard_shift_24_filled
                                : FluentIcons.keyboard_shift_24_regular,
                            size: 24.0,
                            color:   vote == Vote.down
                                ?Colors.red: Theme.of(context).iconTheme.color
                              );
                            
  }
}