import 'dart:async';
import 'dart:io';

import 'package:blue/functions/upload_post_interaction.dart';
import 'package:blue/models/post_interaction.dart';
import 'package:blue/providers/post_interactions.dart';
import 'package:blue/screens/profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import './custom_image.dart';
import '../screens/home.dart';
import '../widgets/progress.dart';
import '../models/user.dart';
import '../screens/comments_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String title;
  final String topicName;
  final String topicId;
  final Map contents;
  final Map contentsInfo;
  final dynamic upvotes;
  // final PostInteractions postInteractions;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.title,
    this.topicName,
    this.topicId,
    this.contents,
    this.contentsInfo,
    this.upvotes,
    // this.postInteractions
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      title: doc['title'],
      topicName: doc['topicName'],
      topicId: doc['topicId'],
      contents: doc['contents'],
      contentsInfo: doc['contentsInfo'],
      upvotes: doc['upvotes'],
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
      title: this.title,
      topicName: this.topicName,
      topicId: this.topicId,
      contents: this.contents,
      contentsInfo: this.contentsInfo,
      upvotes: this.upvotes,
      upvoteCount: getUpVoteCount(this.upvotes),
      // postInteractions: this.postInteractions,
      );
}

class _PostState extends State<Post> {
  
  double topEdgeHeight;
  double bottomEdgeHeight;

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
  final String title;
  final String topicName;
  final String topicId;
  final Map contents;
  final Map contentsInfo;
  // final PostInteractions postInteractions;
  int upvoteCount;
  Map upvotes;
  bool isUpvoted;
  double screenWidth;
  _PostState(
      {this.postId,
      this.ownerId,
      this.username,
      this.title,
      this.topicName,
      this.topicId,
      this.contents,
      this.contentsInfo,
      this.upvotes,
      this.upvoteCount,
      // this.postInteractions
      });
  
  buildPostHeader() {
    return FutureBuilder(                                    //TODO can set userdata on post
        future: usersRef.document(ownerId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data);
          bool isPostOwner = currentUserId == ownerId;
          return Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    EdgeInsets.only(left: 13, top: 5, right: 13, bottom: 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 23,
                              fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  padding:
                      EdgeInsets.only(left: 13, top: 2, bottom: 2, right: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 15,
                        backgroundImage:
                            CachedNetworkImageProvider(user.photoUrl),
                        backgroundColor: Colors.grey,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Container(
                        height: 24,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          user.username,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
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
                      ), FlatButton(onPressed: null, child: Text(widget.topicName,style: TextStyle(fontSize: 12,color: Colors.blue),),),
                      isSaved
                          ? SizedBox(
                              height: 40,
                              width: 40,
                              child: IconButton(
                                iconSize: 22,
                                onPressed: () {
                                  setState(() {
                                    isSaved = false;
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
                                onPressed: () {
                                  setState(() {
                                    isSaved = true;
                                  });
                                },
                                icon: Icon(
                                  Icons.bookmark_border,
                                ),
                              ),
                            ),
                      isPostOwner
                          ? IconButton(
                              onPressed: () => handleDeletePost(context),
                              icon: Icon(Icons.more_vert),
                            )
                          : SizedBox(
                              height: 40,
                              width: 40,
                              child: IconButton(
                                iconSize: 22,
                                onPressed: () => handleDeletePost(context),
                                icon: Icon(
                                  Icons.more_vert,
                                ),
                              ),
                            )
                    ],
                  ),),
            ],
          );
        });
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
                  )),
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
       postInteractions[postId] = PostInteraction( ownerId, false, false, false, false);
    } else if (!_isUpvoted) {
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
       postInteractions[postId] = PostInteraction( ownerId, true, false, false, false);
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

     if(this.mounted && persistentCallbackAdded == false){
      //timer =  Timer.periodic(Duration(milliseconds: 100), (Timer t){WidgetsBinding.instance.addPostFrameCallback(_afterLayout);} );
    
    persistentCallbackAdded = true;
    }

    super.didChangeDependencies();
  }

  @override
  void initState() {
    print(contents);
    for (int i = 1; i <= contents.length; i++) {
      print(contents['$i']);
      if (contentsInfo['$i']['type'] == 'image') {
        contentsViewList.add(imageContentContainer(
            contents['$i'], contentsInfo['$i']['aspectRatio']));
      } else if (contentsInfo['$i']['type'] == 'video') {
        _controller = VideoPlayerController.network(
          contents['$i'],
        );
        _initializeVideoPlayerFuture = _controller.initialize();

        contentsViewList.add(videoContentContainer(
            contents['$i'], contentsInfo['$i']['aspectRatio']));
      } else {
        contentsViewList.add(textContentContainer(contents['$i']));
      }
    }
  // postInteractions.postInteractions[postId] = PostInteraction( ownerId, false, false, false, false);
    super.initState();
  }
  Widget imageContentContainer(String url, double aspectRatio) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        (cachedNetworkImage(context,url,aspectRatio : aspectRatio)),
      ],
    );
  }

  playOrPauseVideo() {
    if (_controller.value.isPlaying) {
      setState(() {
        playbackButton = Icon(Icons.play_arrow);
        _controller.pause();
      });
    } else
      setState(() {
        _controller.play();
      });
  }
   
  Widget videoContentContainer(String url, double aspectRatio) {
    bool videoMuted = false;
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _controller.play();
          return Stack(
            children: <Widget>[
              GestureDetector(
                onTap: playOrPauseVideo,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
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
                            _controller.setVolume(1);
                          } else {
                            _controller.setVolume(0);
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
            color: Colors.amber,
            height: screenWidth / aspectRatio,
          );
        }
      },
    );
  }

  Widget textContentContainer(String text) {
    return Container(
      child: Text(text),
      padding: EdgeInsets.all(8),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 13.0),
            ),
            GestureDetector(
              onTap: () => null,
              child: Icon(Icons.repeat, size: 28.0, color: Colors.grey),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: GestureDetector(
                onTap: () => showComments(
                  context,
                  postId: postId,
                  ownerId: ownerId,
                  contents: contents,
                  postInteractions: postInteractions,
                ),
                child: Icon(
                  Icons.comment,
                  size: 28.0,
                  color: Colors.blue[300],
                ),
              ),
            ),
            Expanded(
              child: Container(),
            ),
            GestureDetector(
              onTap: () => handleVoteButton(),
              child: Icon(isUpvoted == true ? Icons.star : Icons.star_border,
                  size: 24.0, color: Colors.blueGrey),
            ),
            Container(
                margin: EdgeInsets.only(left: 20),
                child: Text(
                  '$upvoteCount',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                )),
            SizedBox(width: 13),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 7),
        ),
        Divider(
          thickness: 3,
          color: Colors.grey[200],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    isUpvoted = (upvotes[currentUserId] == true);
    return Column(
      key: trackKey,
      children: <Widget>[
        buildPostHeader(),
        ListView.builder(padding: EdgeInsets.all(0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (_, i) {
            return contentsViewList[i];
          },
          itemCount: contents.length,
        ),
        SizedBox(height: 10,),
        buildPostFooter(),
      ],
    );
  }
}

showComments(BuildContext context,
    {String postId, String ownerId, Map contents,Map<String,PostInteraction> postInteractions}) {
  Navigator.pushNamed(context, CommentsScreen.routeName,
      arguments: {'postId': postId, 'ownerId': ownerId, 'contents': contents,'postIneractions': postInteractions});
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
