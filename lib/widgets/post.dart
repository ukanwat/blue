import 'dart:async';
import 'dart:io';
import 'package:blue/models/post_interaction.dart';
import 'package:blue/screens/explore_posts_screen.dart';
import 'package:blue/screens/profile_screen.dart';
import 'package:blue/services/link_preview.dart';
import 'package:blue/services/video_controls.dart';
import 'package:blue/services/video_thumbnail_generator.dart';
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

import './custom_image.dart';
import '../screens/home.dart';
import '../screens/comments_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

enum CompactPostThumbnailType {
  video,
  image,
  link,
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
  final dynamic upvotes;
  final List<dynamic> tags;
  final bool isCompact;
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
      this.tags,
      this.isCompact
      // this.postInteractions
      });

  factory Post.fromDocument(DocumentSnapshot doc, {bool isCompact}) {
    if (isCompact == null) isCompact = false;
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
      tags: doc['tags'],
      isCompact: isCompact,
    );
  }
  int getUpVoteCount(upvotes) {
    if (upvotes == null) {
      return 0;
    }
    int count = 0;
    upvotes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
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
      upvoteCount: getUpVoteCount(this.upvotes),
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
    this.upvoteCount,
    this.tags,
  });
  //
  int upvoteCount;
  Map upvotes;
  bool isUpvoted;
  double screenWidth;
  bool tagBarVisible = false;
  bool notInterested = false;
  var compactPostThumbnailData;
  CompactPostThumbnailType thumbnailType;
  OverlayEntry overlayOptions;
  bool isFollowing = false;
  bool isDownvoted = false;
  FlickManager flickManager;
  showOptions() {
    overlayOptions = createOverlayOptions();
    Overlay.of(context).insert(overlayOptions);
  }

  OverlayEntry createOverlayOptions() {

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
                  left: 0,
                  top: 85,
                  width: 250,
                  child: Material(
                    color: Colors.transparent,
                    elevation: 0.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.0,
                              spreadRadius: 0.0,
                              offset: Offset(
                                  2, 2), // shadow direction: bottom right
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              onTap: (){
                                setState(() {
                                  overlayOptions?.remove();
                                });
                                showDialog(
        context: context,
        builder: (context) {
          return ReportDialog(widget.postId, widget.title);
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
                                  FluentIcons.keyboard_shift_24_regular,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
                              title: Text('Downvote'),
                            ),
                             if(isFollowing)
                             ListTile(
                              dense: true,
                              leading: Icon(
                                  FluentIcons.channel_unfollow_24_regular,
                                  color: Theme.of(context).iconTheme.color,
                                
                              ),onTap: ()async{
                             QuerySnapshot followersDoc = await followersRef.document(widget.ownerId).collection('userFollowers').where('followers',arrayContains: currentUserId).getDocuments(); 
                             followersDoc.documents.forEach((doc) {
                              followersRef.document(widget.ownerId).collection('userFollowers').document(doc.documentID).updateData({'followers': FieldValue.arrayRemove([currentUserId])}); 
                             });
                             QuerySnapshot followingDoc = await followingRef.document(currentUserId).collection('userFollowing').where('following',arrayContains: widget.ownerId).getDocuments();
                              followingDoc.documents.forEach((doc) {
                              followingRef.document(currentUserId).collection('userFollowers').document(doc.documentID).updateData({'followers': FieldValue.arrayRemove([widget.ownerId])}); 
                             });
                              },
                              title: Text('Unfollow'),
                            )
                          ],
                        ),
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
                CircleAvatar(
                  radius: 18,
                  backgroundImage: CachedNetworkImageProvider(photoUrl),
                  backgroundColor: Colors.grey,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                        'Hope you weren’t planning to watchiiiii Wonder Woman 1984 with an HBO Max free trial', ///////******/

                        //  widget.title,
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
                      showOptions();
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
                      if(!isFollowing && !(widget.ownerId == currentUserId))
                      Container(
                        height: 22,
                        child: GestureDetector(
                          onTap: () async {
                            var lastFollowingDoc = await followingRef
                                .document(currentUser?.id)
                                .collection('userFollowing')
                                .orderBy('order', descending: true)
                                .limit(1)
                                .getDocuments();
                            if (lastFollowingDoc.documents.length == 0) {
                              followingRef
                                  .document(currentUser?.id)
                                  .collection('userFollowing')
                                  .document()
                                  .setData({
                                'order': 1,
                                'following': [
                                  widget.ownerId,
                                ],
                              }, merge: true);
                            } else if (lastFollowingDoc.documents.length == 1 &&
                                lastFollowingDoc.documents.first
                                        .data['following'].length <
                                    10000) {
                              followingRef
                                  .document(currentUser?.id)
                                  .collection('userFollowing')
                                  .document(lastFollowingDoc
                                      .documents.first.documentID)
                                  .updateData({
                                'following':
                                    FieldValue.arrayUnion([widget.ownerId])
                              });
                            } else if (lastFollowingDoc.documents.length == 1 &&
                                lastFollowingDoc.documents.first.data['following'].length > 10000) {
                              followingRef
                                  .document(currentUser?.id)
                                  .collection('userFollowing')
                                  .document().setData({
                                'following':[widget.ownerId],
                                'order': lastFollowingDoc.documents.first.data['order']+ 1,
                              });
                            }

                             var lastFollowersDoc = await followersRef
                                .document(widget.ownerId)
                                .collection('userFollowers')
                                .orderBy('order', descending: true)
                                .limit(1)
                                .getDocuments();
                            if (lastFollowersDoc.documents.length == 0) {
                              followersRef
                                  .document(widget.ownerId)
                                  .collection('userFollowers')
                                  .document()
                                  .setData({
                                'order': 1,
                                'followers': [
                                  currentUserId,
                                ],
                              }, merge: true);
                            } else if (lastFollowersDoc.documents.length == 1 &&
                                lastFollowersDoc.documents.first
                                        .data['following'].length <
                                    10000) {
                              followersRef
                                  .document(widget.ownerId)
                                  .collection('userFollowers')
                                  .document(lastFollowersDoc
                                      .documents.first.documentID)
                                  .updateData({
                                'followers':
                                    FieldValue.arrayUnion([currentUserId])
                              });
                            } else if (lastFollowersDoc.documents.length == 1 &&
                                lastFollowersDoc.documents.first.data['followers'].length > 10000) {
                              followersRef
                                  .document(currentUser?.id)
                                  .collection('userFollowers')
                                  .document().setData({
                                'followers':[widget.ownerId],
                                'order': lastFollowersDoc.documents.first.data['order']+ 1,
                              });
                            }
                            List<String> followingList = preferences.getStringList('following');
                            if(!followingList.contains(widget.ownerId))
                            followingList.add(widget.ownerId);
                            preferences.setStringList('following',followingList);

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
          if (tagBarVisible)
            Container(
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
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  TagScreen.routeName,
                                  arguments: tags[i]);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 3),
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
            ),
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
    bool isPostOwner = currentUserId == ownerId;
    return Stack(children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.only(left: 10, top: 5, bottom: 0, right: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 11.5,
                        backgroundImage: CachedNetworkImageProvider(photoUrl),
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
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          height: 24,
                          child: FittedBox(
                            fit: BoxFit.none,
                            alignment: Alignment.centerLeft,
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
                      tagBarVisible
                          ? SizedBox(
                              height: 30,
                              width: 30,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    tagBarVisible = false;
                                  });
                                },
                                child: Icon(
                                  Icons.keyboard_arrow_up,
                                  size: 28,
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 30,
                              width: 30,
                              child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    tagBarVisible = true;
                                  });
                                },
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 28,
                                ),
                              ),
                            ),
                      isSaved
                          ? SizedBox(
                              height: 40,
                              width: 40,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSaved = false;
                                    showSaveBar = false;
                                    savedPostsRef // TODO
                                        .document(currentUser?.id)
                                        .collection('All')
                                        .document(postId)
                                        .delete();
                                  });
                                },
                                child: Icon(
                                  Icons.bookmark,
                                  size: 21,
                                  color: Colors.blue,
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 30,
                              width: 30,
                              child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    isSaved = true;
                                  });
                                  var lastDoc = await savedPostsRef
                                      .document(currentUser?.id)
                                      .collection('all')
                                      .orderBy('order', descending: true)
                                      .limit(1)
                                      .getDocuments();
                                  if (lastDoc.documents.length == 0) {
                                    savedPostsRef
                                        .document(currentUser?.id)
                                        .collection('all')
                                        .document()
                                        .setData({
                                      'order': 1,
                                      'posts': [
                                        postId,
                                      ],
                                    }, merge: true);
                                  } else if (lastDoc.documents.length == 1 &&
                                      lastDoc.documents.first.data['posts']
                                              .length <
                                          2) {
                                    List<dynamic> _postIdList =
                                        lastDoc.documents.first.data['posts'];
                                    _postIdList.add(postId);
                                    savedPostsRef
                                        .document(currentUser?.id)
                                        .collection('all')
                                        .document(
                                            lastDoc.documents.first.documentID)
                                        .setData({
                                      'posts': _postIdList,
                                    }, merge: true);
                                  } else if (lastDoc.documents.length == 1 &&
                                      lastDoc.documents.first.data['posts']
                                              .length >
                                          1) {
                                    savedPostsRef
                                        .document(currentUser?.id)
                                        .collection('all')
                                        .document()
                                        .setData({
                                      'order': lastDoc
                                              .documents.first.data['order'] +
                                          1,
                                      'posts': [
                                        postId,
                                      ],
                                    }, merge: true);
                                  }
                                  setState(() {
                                    showSaveBar = true;
                                  });
                                  Future.delayed(
                                      const Duration(milliseconds: 4000), () {
                                    setState(() {
                                      showSaveBar = false;
                                    });
                                  });
                                },
                                child: Icon(
                                  Icons.bookmark_border,
                                  size: 21,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: 10, top: 0, right: 5, bottom: 3),
                  child: Text(
                    widget.title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
    // delete post itself
    postsRef
        .document(ownerId)
        .collection('userPosts')
        .document(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete uploaded image for thep ost
    // storageRef.child("post_$postId.jpg").delete();  // TODO: delete stored media
    // then delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .document(ownerId)
        .collection("feedItems")
        .where('postId', isEqualTo: postId)
        .getDocuments();
    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // then delete all comments
    QuerySnapshot commentsSnapshot = await commentsRef
        .document(postId)
        .collection('comments')
        .getDocuments();
    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }
    handleDownvoteButton()async {
    if (!isDownvoted) {
      setState(() {
        isDownvoted = true;
      });
         var lastVotedDoc = await postsVotersRef
                                .document(widget.postId)
                                .collection('userDownvoters')
                                .orderBy('order', descending: true)
                                .limit(1)
                                .getDocuments();
                            if (lastVotedDoc.documents.length == 0) {
                            postsVotersRef
                                  .document(widget.postId)
                                  .collection('DownUpvoters')
                                  .document()
                                  .setData({
                                'order': 1,
                                'Downvoters': [
                                 currentUserId,
                                ],
                              }, merge: true);
                            } else if (lastVotedDoc.documents.length == 1 &&
                              lastVotedDoc.documents.first
                                        .data['Downvoters'].length <
                                    10000) {
                             postsVotersRef
                                  .document(widget.postId)
                                  .collection('userUpvotes')
                                  .document(lastVotedDoc
                                      .documents.first.documentID)
                                  .updateData({
                                'upvotes':
                                    FieldValue.arrayUnion([widget.ownerId])
                              });
                            } else if (lastVotedDoc.documents.length == 1 &&
                                lastVotedDoc.documents.first.data['upvoters'].length > 10000) {
                              followingRef
                                  .document(currentUser?.id)
                                  .collection('voters')
                                  .document().setData({
                                'upvoters':[currentUserId],
                                'order': lastVotedDoc.documents.first.data['order']+ 1,
                              });
                            }

     } else if (isDownvoted) {
     QuerySnapshot _doc= await postsVotersRef .document(widget.postId)
                                .collection('userDownvotes').where('Downvoters',arrayContains: currentUserId).limit(1).getDocuments();
   bool _isDownvoted = _doc.documents.length == 1; 
     
  postsVotersRef  .document(widget.postId)
                                .collection('userDownvotes').document(_doc.documents.first.documentID).updateData({'downvoters': [currentUserId]});

    }
  }
  handleUpvoteButton()async {
    if(isUpvoted){
   QuerySnapshot _doc= await postsVotersRef .document(widget.postId)
                                .collection('userDownvotes').where('Downvoters',arrayContains: currentUserId).limit(1).getDocuments();
   bool _isUpvoted = _doc.documents.length == 1; 
     
  postsVotersRef  .document(widget.postId)
                                .collection('userDownvotes').document(_doc.documents.first.documentID).updateData({'downvoters': [currentUserId]});

    }  else if (!isUpvoted) {
     var lastVotedDoc = await postsVotersRef 
                                .document(widget.postId)
                                .collection('userUpvotes')
                                .orderBy('order', descending: true)
                                .limit(1)
                                .getDocuments();
                            if (lastVotedDoc.documents.length == 0) {
                            postsVotersRef 
                                  .document(widget.postId)
                                  .collection('userUpvotes')
                                  .document()
                                  .setData({
                                'order': 1,
                                'upvoters': [
                                 currentUserId,
                                ],
                              }, merge: true);
                            } else if (lastVotedDoc.documents.length == 1 &&
                              lastVotedDoc.documents.first
                                        .data['upvoters'].length <
                                    10000) {
                           postsVotersRef 
                                  .document(widget.postId)
                                  .collection('userUpvotes')
                                  .document(lastVotedDoc
                                      .documents.first.documentID)
                                  .updateData({
                                'upvotes':
                                    FieldValue.arrayUnion([widget.ownerId])
                              });
                            } else if (lastVotedDoc.documents.length == 1 &&
                                lastVotedDoc.documents.first.data['upvoters'].length > 10000) {
                              followingRef
                                  .document(currentUser?.id)
                                  .collection('voters')
                                  .document().setData({
                                'upvoters':[currentUserId],
                                'order': lastVotedDoc.documents.first.data['order']+ 1,
                              });
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

  buildPostFooter() {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Column(
        children: <Widget>[
          if (showSaveBar)
            Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
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
                )),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 13.0),
              ),
              SizedBox(
                height: 28,
                width: 30,
                child: GestureDetector(
                  onTap: () {},
                  child: Icon(
                    FlutterIcons.ios_arrow_down_ion,
                    size: 28,
                  ),
                ),
              ),
              Expanded(
                child: Container(),
              ),
              isSaved
                  ? Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isSaved = false;
                              showSaveBar = false;
                              savedPostsRef // TODO
                                  .document(currentUser?.id)
                                  .collection('All')
                                  .document(postId)
                                  .delete();
                            });
                          },
                          child: Icon(
                            FluentIcons.bookmark_24_filled,
                            size: 22,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              isSaved = true;
                            });
                            var lastDoc = await savedPostsRef
                                .document(currentUser?.id)
                                .collection('all')
                                .orderBy('order', descending: true)
                                .limit(1)
                                .getDocuments();
                            if (lastDoc.documents.length == 0) {
                              savedPostsRef
                                  .document(currentUser?.id)
                                  .collection('all')
                                  .document()
                                  .setData({
                                'order': 1,
                                'posts': [
                                  postId,
                                ],
                              }, merge: true);
                            } else if (lastDoc.documents.length == 1 &&
                                lastDoc.documents.first.data['posts'].length <
                                    2) {
                              List<dynamic> _postIdList =
                                  lastDoc.documents.first.data['posts'];
                              _postIdList.add(postId);
                              savedPostsRef
                                  .document(currentUser?.id)
                                  .collection('all')
                                  .document(lastDoc.documents.first.documentID)
                                  .setData({
                                'posts': _postIdList,
                              }, merge: true);
                            } else if (lastDoc.documents.length == 1 &&
                                lastDoc.documents.first.data['posts'].length >
                                    1) {
                              savedPostsRef
                                  .document(currentUser?.id)
                                  .collection('all')
                                  .document()
                                  .setData({
                                'order':
                                    lastDoc.documents.first.data['order'] + 1,
                                'posts': [
                                  postId,
                                ],
                              }, merge: true);
                            }
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
                          child: Icon(
                            FluentIcons.bookmark_24_regular,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          RepostDialog(this.widget),
                    );
                  },
                  child: Icon(FluentIcons.share_24_regular,
                      size: 26.0, color: Colors.blueAccent),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () => showComments(
                    context,
                    post: this.widget,
                  ),
                  child: Icon(
                    FluentIcons.comment_24_regular,
                    size: 24.0,
                    color: Colors.cyan,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => handleUpvoteButton(),
                child: Icon(
                  isUpvoted == true
                      ? FluentIcons.keyboard_shift_24_filled
                      : FluentIcons.keyboard_shift_24_regular,
                  size: 24.0,
                ),
              ),
              Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Text(
                    '$upvoteCount',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  )),
              SizedBox(width: 13),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 13),
          ),
          Divider(
            thickness: 3,
            color: Theme.of(context).canvasColor,
            height: 3,
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
@override
  void initState() {
    List<String> followingList = preferences.getStringList('following');
    if( followingList == null){
       followingList = [];
       preferences.setStringList('following', followingList );
    }
   
    if(followingList.contains(widget.ownerId))
    setState(() {
      isFollowing = true;
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    isUpvoted = false;
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
        : Material(
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
                    ListView.builder(
                      padding: EdgeInsets.all(0),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (_, i) {
                        return contentsViewList[i];
                      },
                      itemCount: contents.length,
                    ),
                  buildPostFooter(),
                ],
              ),
            ));
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
