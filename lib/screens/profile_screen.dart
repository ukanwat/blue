import 'package:blue/screens/all_saved_posts_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blue/main.dart';

import '../widgets/post.dart';
import '../models/user.dart';
import '../widgets/header.dart';
import '../widgets/progress.dart';
import './home.dart';
import './edit_profile_screen.dart';
import './settings_screen.dart';

import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  final String profileId;
  final String profileUsername;
  final String profileName;
//  final PostInteractions postInteractions;
  ProfileScreen({this.profileId, this.profileUsername, this.profileName
      // this.postInteractions
      });

  @override
  _ProfileScreenState createState() => _ProfileScreenState(
      // postInteractions
      );
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
  // final PostInteractions postInteractions;
  // _ProfileScreenState(this.postInteractions);
  String username = '';
  bool isFollowing = false;
  final String currentUserId = currentUser?.id;
  bool postsAreLoading = false;
  bool repostsAreLoading = false;
  int postCount = 0;
  int repostCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];
  List<Post> reposts = [];
  bool headerLoading = true;
  bool hasMorePosts = true; // flag for more products available or not
  bool hasMoreReposts = true; // flag for more products available or not
  int documentLimit = 10; // documents to be fetched per request
  List<dynamic> postDocSnapshots = [];
  List<dynamic> repostDocSnapshots = [];
  DocumentSnapshot lastPostDocument;
  DocumentSnapshot lastRepostDocument;

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getProfileReposts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    if (currentUserId != widget.profileId) {
      DocumentSnapshot doc = await followersRef
          .document(widget.profileId)
          .collection('userFollowers')
          .document(currentUserId)
          .get();
      setState(() {
        isFollowing = doc.exists;
      });
    }
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  getProfilePosts() async {
    if (!hasMorePosts) {
      print('No More posts');
      return;
    }
    if (postsAreLoading) {
      return;
    }
    setState(() {
      postsAreLoading = true;
    });
    var _postGroup = await userPostsRef
        .document(currentUser.id)
        .collection('userPosts')
        .orderBy('order', descending: false)
        .getDocuments();
    List _postList = [];
    for (int l = 0; l < _postGroup.documents.length; l++) {
      _postList.add(_postGroup.documents.elementAt(l).data['posts']);
    }
    List _postFullList = [];
    for (int i = 0; i < _postList.length; i++) {
      for (int x = 0; x < _postList[i].length; x++) {
        _postFullList.add(_postList[i][x]);
      }
    }
    List<Future> postFutures = [];
    if (lastPostDocument == null) {
      for (int k = 0; k < _postFullList.length; k++) {
        postFutures.add(postsRef.document(_postFullList[k]).get());
      }
    } else {
      for (int k = 0; k < _postFullList.length; k++) {
        postFutures.add(postsRef.document(_postFullList[k]).get());
      }
    }
    postDocSnapshots = await Future.wait(postFutures);
    print(postDocSnapshots.first);
    print('${postDocSnapshots.length}j');
    if (postDocSnapshots.length < documentLimit) {
      hasMorePosts = false;
    }
    if (postDocSnapshots.length == 0) {
      return;
    }
    lastPostDocument = postDocSnapshots[postDocSnapshots.length - 1];
    setState(() {
      postsAreLoading = false;
      postCount = postDocSnapshots.length;
      print(postDocSnapshots);
      posts = posts +
          postDocSnapshots.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  getProfileReposts() async {
    if (!hasMoreReposts) {
      print('No More posts');
      return;
    }
    if (repostsAreLoading) {
      return;
    }
    setState(() {
      repostsAreLoading = true;
    });
    var _repostGroup = await repostsRef
        .document(currentUser.id)
        .collection('userReposts')
        .orderBy('order', descending: false)
        .getDocuments();
    List _repostList = [];
    for (int l = 0; l < _repostGroup.documents.length; l++) {
      _repostList.add(_repostGroup.documents.elementAt(l).data['posts']);
    }
    List _repostFullList = [];
    for (int i = 0; i < _repostList.length; i++) {
      for (int x = 0; x < _repostList[i].length; x++) {
        _repostFullList.add(_repostList[i][x]);
      }
    }
    List<Future> repostFutures = [];
    if (lastPostDocument == null) {
      for (int k = 0; k < _repostFullList.length; k++) {
        repostFutures.add(postsRef.document(_repostFullList[k]).get());
      }
    } else {
      for (int k = 0; k < _repostFullList.length; k++) {
        repostFutures.add(postsRef.document(_repostFullList[k]).get());
      }
    }
    repostDocSnapshots = await Future.wait(repostFutures);

    if (repostDocSnapshots.length < documentLimit) {
      hasMorePosts = false;
    }
    if (repostDocSnapshots.length == 0) {
      return;
    }
    lastRepostDocument = repostDocSnapshots[repostDocSnapshots.length - 1];
    setState(() {
      repostsAreLoading = false;
      repostCount = repostDocSnapshots.length;
      reposts = reposts +
          repostDocSnapshots.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  editProfile() {
    Navigator.pushNamed(context, EditProfileScreen.routeName,
        );
  }

  Expanded buildCountColumn(IconData label, int count) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            child: Text(
              compactString(count),        // TODO improve formatting
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Icon(
              label,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  buildButton({String text, Function function}) {
    return Expanded(
      child: Container(
        height: 25,
        child: FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: function,
          child: Container(
            width: double.infinity,
            height: 33,
            child: Text(
              text,
              style: TextStyle(
                  color: isFollowing ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFollowing ? Colors.white : Colors.blue,
              border:
                  Border.all(color: isFollowing ? Colors.black54 : Colors.blue),
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ),
      ),
    );
  }

  buildButtonCircular({Icon icon, Function function}) {
    return Container(
      height: 25,
      width: 25,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.blue,
          border: Border.all(color: Colors.blue)),
      child: Transform.scale(
        scale: 2.5,
        child: IconButton(
          icon: icon,
          onPressed: function,
          color: Colors.white,
          iconSize: 18,
          alignment: Alignment.topLeft,
        ),
      ),
    );
  }

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(text: 'Edit Profile', function: editProfile);
    } else if (isFollowing) {
      return buildButton(text: 'Unfollow', function: handleUnfollowUser);
    } else if (!isFollowing) {
      return buildButton(text: 'Follow', function: handleFollowUser);
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({});
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': currentUser.username,
      'userId': currentUser.photoUrl,
      'userProfileImg': currentUser.photoUrl,
      'timestamp': timestamp,
    });
  }

  buildProfileIconButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButtonCircular(
          icon: Icon(
            FlutterIcons.bookmark_mco,
            size: 7,
          ),
          function: () {
            Navigator.pushNamed(context, AllSavedPostsScreen.routeName);
          });
    } else {
      return buildButtonCircular(
          icon: Icon(
            Icons.chat_bubble,
            size: 7,
          ),
          function: () {
            print('adddddd');
          });
    }
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding:
                    EdgeInsets.only(top: 5, left: 15.0, right: 15.0, bottom: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 55.0,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoUrl),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 110,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '@${user.username}',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).canvasColor,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  // buildCountColumn(
                                  //     FlutterIcons.post_outline_mco, postCount),
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(2),
                                  //     color: Colors.grey,
                                  //   ),
                                  //   height: 52,
                                  //   width: 1,
                                  // ),
                                  buildCountColumn(
                                      FlutterIcons.people_sli, followerCount),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: Colors.grey,
                                    ),
                                    height: 20,
                                    width: 1,
                                  ),
                                  buildCountColumn(
                                      FlutterIcons.user_following_sli,
                                      followingCount),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                buildProfileButton(),
                                SizedBox(width: 5),
                                buildProfileIconButton(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 15, top: 8, right: 15, bottom: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (user.website != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Linkify(
                          text: user.website,
                          linkStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                            decoration: TextDecoration.none,
                          ),
                          onOpen: (link) {
                            launchWebsite(user.website);
                          },
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Icon(Icons.link),
                        ),
                      ],
                    ),
                  Text(
                    user.bio,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: <Widget>[
            //     Text(
            //       postCount.toString(),
            //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            //     ),
            //     Container(
            //       margin: EdgeInsets.all(5),
            //       decoration: BoxDecoration(
            //         shape: BoxShape.circle,
            //         color: Theme.of(context).iconTheme.color,
            //       ),
            //       height: 6,
            //       width: 6,
            //     ),
            //     Text(
            //       repostCount.toString(),
            //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            //     )
            //   ],
            // )
          ],
        );
      },
    );
  }
String compactString(int value) {
  const units = <int, String>{
    1000000000: 'B',
    1000000: 'M',
    1000: 'K',
  };
  return units.entries
      .map((e) => '${value ~/ e.key}${e.value}')
      .firstWhere((e) => !e.startsWith('0'), orElse: () => '$value');
}
  launchWebsite(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceWebView: true,
        enableJavaScript: true,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  buildProfilePosts() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: ScrollPhysics(),
      itemBuilder: (_, i) {
        return posts[i];
      },
      itemCount: posts.length,
    );
  }

  buildProfileReposts() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: ScrollPhysics(),
      itemBuilder: (ctx, i) {
        return reposts[i];
      },
      itemCount: reposts.length,
    );
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      // Persistent AppBar that never scrolls
      appBar: header(
        context,
        centerTitle: false,
        elevation: 0,
        title: Text(
          widget.profileName,
        ),
        actionButton: IconButton(
            icon: Icon(
              FlutterIcons.settings_fea,
              size: 20,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              Navigator.pushNamed(context, SettingsScreen.routeName);
            }),
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          // allows you to build a list of elements that would be scrolled away till the body reached the top
          headerSliverBuilder: (context, _) {
            return [
              SliverToBoxAdapter(
                // delegate: SliverChildListDelegate(
                child: buildProfileHeader(),
                //),
              ),
            ];
          },
          // You tab view goes here
          body: Column(
            children: <Widget>[
              TabBar(
                indicatorColor: Theme.of(context).iconTheme.color,
                labelColor: Theme.of(context).iconTheme.color,
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Shares'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    buildProfilePosts(),
                    buildProfileReposts(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
