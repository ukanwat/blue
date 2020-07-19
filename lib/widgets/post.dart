import 'dart:async';
import 'package:blue/models/post_interaction.dart';
import 'package:blue/screens/profile_screen.dart';
import 'package:blue/widgets/repost_dialog.dart';
import 'package:blue/widgets/save_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:video_player/video_player.dart';
import 'package:blue/screens/tag_screen.dart';
import 'package:blue/main.dart';

import './custom_image.dart';
import '../screens/home.dart';
import '../screens/comments_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

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
     if(isCompact == null)
     isCompact = false;
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
  OverlayEntry overlayOptions;
  showOptions() {
    overlayOptions = createOverlayOptions();
    Overlay.of(context).insert(overlayOptions);
  }

  OverlayEntry createOverlayOptions() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

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
                  top: offset.dy + size.height - 170,
                  width: MediaQuery.of(context).size.width * 0.55,
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
                              dense: true,
                              leading: Icon(FlutterIcons.flag_fea,
                              color: Theme.of(context).iconTheme.color,
                              ),
                              title: Text('Report'),
                            ),
                            ListTile(     dense: true,
                              leading: Icon(FlutterIcons.block_mdi,  color: Theme.of(context).iconTheme.color,),
                              title: Text('Not Interested'),
                              onTap: () {
                                setState(() {
                                  overlayOptions?.remove();
                                  notInterested = true;
                                });
                              },
                            ),
                            ListTile(     dense: true,
                              leading: Icon(
                                  FlutterIcons.arrow_down_bold_outline_mco,  color: Theme.of(context).iconTheme.color,),
                              title: Text('Downvote'),
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
    bool isPostOwner = currentUserId == ownerId;
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: <Widget>[
          Container(
            color: Theme.of(context).backgroundColor,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 13, top: 8, right: 13, bottom: 3),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                          
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                              Navigator.of(context).pushNamed(TagScreen.routeName,
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
          Container(
                      color: Theme.of(context).backgroundColor,
                      margin: EdgeInsets.zero,
            padding: EdgeInsets.only(left: 13, top: 0, bottom: 0, right: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 15,
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
                        height: 20,
                        width: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue,
                        ),
                        child: RawMaterialButton(
                          child: Text(
                            'Follow',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                tagBarVisible
                    ? SizedBox(
                        height: 40,
                        width: 40,
                        child: IconButton(
                          iconSize: 28,
                          onPressed: () {
                            setState(() {
                              tagBarVisible = false;
                            });
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_up,
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 40,
                        width: 40,
                        child: IconButton(
                          iconSize: 28,
                          onPressed: () async {
                            setState(() {
                              tagBarVisible = true;
                            });
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                          ),
                        ),
                      ),
                isSaved
                    ? SizedBox(
                        height: 40,
                        width: 40,
                        child: IconButton(
                          iconSize: 22,
                          onPressed: () {
                            setState(() {
                              isSaved = false;
                              showSaveBar = false;
                              savedPostsRef              // TODO
                                  .document(currentUser?.id)
                                  .collection('All')
                                  .document(postId)
                                  .delete();
                            });
                          },
                          icon: Icon(
                            Icons.bookmark,
                            color: Colors.blue,

                          ),
                        ),
                      )
                    : SizedBox(
                        height: 40,
                        width: 40,
                        child: IconButton(
                          iconSize: 22,
                          onPressed: () async {
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
                          icon: Icon(
                            Icons.bookmark_border,
                          ),
                        ),
                      ),
              ],
            ),
          ),
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
                ))
        ],
      ),
    );
  }
  buildCompactPostHeader(){
     bool isPostOwner = currentUserId == ownerId;
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Row(
        children: <Widget>[
          Expanded(
                      child: Column(mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                  Container(
                        color: Theme.of(context).backgroundColor,
                        margin: EdgeInsets.zero,
              padding: EdgeInsets.only(left: 13, top: 0, bottom: 0, right: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 15,
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
                          height: 20,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue,
                          ),
                          child: RawMaterialButton(
                            child: Text(
                              'Follow',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed: null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  tagBarVisible
                      ? SizedBox(
                          height: 40,
                          width: 40,
                          child: IconButton(
                            iconSize: 28,
                            onPressed: () {
                              setState(() {
                                tagBarVisible = false;
                              });
                            },
                            icon: Icon(
                              Icons.keyboard_arrow_up,
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 40,
                          width: 40,
                          child: IconButton(
                            iconSize: 28,
                            onPressed: () async {
                              setState(() {
                                tagBarVisible = true;
                              });
                            },
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                            ),
                          ),
                        ),
                  isSaved
                      ? SizedBox(
                          height: 40,
                          width: 40,
                          child: IconButton(
                            iconSize: 22,
                            onPressed: () {
                              setState(() {
                                isSaved = false;
                                showSaveBar = false;
                                savedPostsRef              // TODO
                                    .document(currentUser?.id)
                                    .collection('All')
                                    .document(postId)
                                    .delete();
                              });
                            },
                            icon: Icon(
                              Icons.bookmark,
                              color: Colors.blue,

                            ),
                          ),
                        )
                      : SizedBox(
                          height: 40,
                          width: 40,
                          child: IconButton(
                            iconSize: 22,
                            onPressed: () async {
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
                            icon: Icon(
                              Icons.bookmark_border,
                            ),
                          ),
                        ),
                ],
              ),
            ),
                Container(
                  color: Theme.of(context).backgroundColor,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(left: 13, top: 8, right: 13, bottom: 3),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                                
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),

              child: Container(
                color: Colors.blue,
                height: MediaQuery.of(context).size.width*0.24,width: MediaQuery.of(context).size.width*0.24,)),
          )
          // if (tagBarVisible)
          //   Container(
              
          //     margin: EdgeInsets.only(top: 0, bottom: 0),
          //     height: 28,
          //     child: Row(
          //       children: <Widget>[
          //         Container(
          //           width: 28,
          //           color: Theme.of(context).backgroundColor,
          //           child: Center(
          //             child: Text(
          //               '#',
          //               style: TextStyle(fontSize: 22),
          //             ),
          //           ),
          //         ),
          //         Expanded(
          //           child: Container(
          //             height: 28,
          //             color: Theme.of(context).canvasColor,
          //             child: ListView.builder(
          //               itemCount: tags.length,
          //               scrollDirection: Axis.horizontal,
          //               itemBuilder: (_, i) {
          //                 print(
          //                   tags[i],
          //                 );
          //                 return InkWell(
          //                   onTap: () {
          //                     Navigator.of(context).pushNamed(TagScreen.routeName,
          //                         arguments: tags[i]);
          //                   },
          //                   child: Container(
          //                     padding: EdgeInsets.symmetric(horizontal: 8),
          //                     margin: EdgeInsets.symmetric(
          //                         horizontal: 2, vertical: 3),
          //                     decoration: BoxDecoration(
          //                         color: Theme.of(context).backgroundColor,
          //                         borderRadius: BorderRadius.circular(100)),
          //                     child: Center(
          //                       child: Text(
          //                         tags[i],
          //                         style: TextStyle(fontSize: 14),
          //                       ),
          //                     ),
          //                   ),
          //                 );
          //               },
          //             ),
          //           ),
          //         )
          //       ],
          //     ),
          //   ),
         
          // if (showSaveBar)
          //   Container(
          //       width: double.infinity,
          //       padding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: <Widget>[
          //           Text(
          //             'Saved!',
          //             style: TextStyle(fontSize: 18),
          //           ),
          //           FlatButton(
          //               onPressed: () {
          //                 setState(() {
          //                   showSaveBar = false;
          //                 });
          //                 showDialog(
          //                   context: context,
          //                   builder: (BuildContext context) =>
          //                       SaveDialog(this.widget),
          //                 );
          //               },
          //               shape: RoundedRectangleBorder(
          //                   borderRadius: BorderRadius.circular(10)),
          //               child: Text(
          //                 'Save to Collection',
          //                 style: TextStyle(
          //                     color: Colors.blue,
          //                     fontWeight: FontWeight.w600,
          //                     fontSize: 18),
          //               ))
          //         ],
          //       ))
        
        ],
      ),
    );
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

  handleVoteButton() {
    bool _isUpvoted = upvotes[currentUserId] == true;
    if (_isUpvoted) {
      topicPostsDatabase.child(postId).child('upvotes').set(0);
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'upvotes.$currentUserId': false});
      removeUpvoteFromActivityFeed();
      setState(() {
        upvoteCount -= 1;
        isUpvoted = false;
        upvotes[currentUserId] = false;
      });
    } else if (!_isUpvoted) {
      topicPostsDatabase.child(postId).child('upvotes').set(1);
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'upvotes.$currentUserId': true});
      addUpvoteToActivityFeed();
      setState(() {
        upvoteCount += 1;
        isUpvoted = true;
        upvotes[currentUserId] = true;
      });
    
    }
  }

  addUpvoteToActivityFeed() {
    bool isNotPostOwner = true; //currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection('feedItems')
          .document(postId)
          .setData({
        'type': 'upvote',
        'username': currentUser.username,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': postId,
        'timestamp': timestamp
      });
    }
  }

  removeUpvoteFromActivityFeed() {
    bool isNotPostOwner = true; //currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection('feedItems')
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
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
        contentsViewList.add(imageContentContainer(
            contents['$i'], contentsInfo['$i']['aspectRatio']));
      } else if (contentsInfo['$i']['type'] == 'video') {
        _controller = VideoPlayerController.network(
          contents['$i'],
        );
        _initializeVideoPlayerFuture = _controller.initialize();
        contentsViewList.add(VideoContentContainer(initializeVideoPlayerFuture:_initializeVideoPlayerFuture,
          //  contents['$i'],
            controller: _controller,
            aspectRatio: contentsInfo['$i']['aspectRatio']));
      } else if (contentsInfo['$i']['type'] == 'text') {
        contentsViewList.add(textContentContainer(contents['$i']));
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
    return Container(
      child: Text(text),
      padding: EdgeInsets.all(8),
    );
  }

  buildPostFooter() {
    return Container(
    
      padding: EdgeInsets.only(
        top: 5
      ),
      color: Theme.of(context).backgroundColor,
          child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 13.0),
              ),
              ownerId == currentUser.id
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: GestureDetector(
                        onTap: () {
                          showOptions();
                        },
                        child: Icon(
                          Icons.more_horiz,
                          size: 22,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 24,
                      width: 24,
                      child: GestureDetector(
                        onTap: () {
                          showOptions();
                        },
                        child: Icon(
                          Icons.more_horiz,
                          size: 22,
                        ),
                      ),
                    ),
              Expanded(
                child: Container(),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => RepostDialog(this.widget),
                  );
                },
                child: Icon(Icons.repeat, size: 24.0, color: Colors.grey),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20.0),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, right: 20.0),
                child: GestureDetector(
                  onTap: () => showComments(
                    context,
                    post: this.widget,

                  ),
                  child: Icon(
                    Icons.comment,
                    size: 24.0,
                    color: Colors.blue[300],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => handleVoteButton(),
                child: Icon(
                    isUpvoted == true
                        ? FlutterIcons.arrow_up_bold_mco
                        : FlutterIcons.arrow_up_bold_outline_mco,
                    size: 26.0,
                    color: Colors.blue),
              ),
              Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Text(
                    '$upvoteCount',
                    style: TextStyle(
                   
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
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
        : Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              children: <Widget>[
                widget.isCompact?buildCompactPostHeader() :buildPostHeader(),
              if(!widget.isCompact)  ListView.builder(
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
          );
  }
}

showComments(BuildContext context,
    {Post post,}) {
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
 _VideoContentContainerState({
      this.initializeVideoPlayerFuture, this.controller, this.aspectRatio});
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
            height: MediaQuery.of(context).size.width/ aspectRatio,
          );
        }
      },
    );
  }
}
