import 'package:blue/screens/about_screen.dart';
import 'package:blue/screens/all_saved_posts_screen.dart';
import 'package:blue/widgets/custom_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
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
  bool compactPosts = true;
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
  String sortBy = 'Recent';
  bool sortDropDown = false;
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
    Navigator.pushNamed(
      context,
      EditProfileScreen.routeName,
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
              compactString(count), // TODO improve formatting
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

  buildButton({String text, Function function, IconData icon}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      height: 40,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        onPressed: function,
        child: Container(
          width: double.infinity,
          height: 33,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 17,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                text,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border:
                Border.all(color: isFollowing ? Colors.black54 : Colors.blue),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
          text: 'Edit Profile',
          function: editProfile,
          icon: FlutterIcons.edit_ant);
    } else if (isFollowing) {
      return buildButton(
          text: 'Message',
          function: handleUnfollowUser,
          icon: FlutterIcons.message1_ant);
    } else if (!isFollowing) {
      return buildButton(
          text: 'Follow',
          function: handleFollowUser,
          icon: FlutterIcons.adduser_ant);
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
      return IconButton(
          icon: Icon(
            FlutterIcons.bookmark_mco,
            size: 24,
          ),
          onPressed: () {
            Navigator.pushNamed(context, AllSavedPostsScreen.routeName);
          });
    } else {
      return IconButton(
          icon: Icon(
            Icons.chat_bubble,
            size: 4,
          ),
          onPressed: () {
            print('adddddd');
          });
    }
  }

  buildProfileHeaderTemp() {
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
              child: CachedNetworkImage(
                imageUrl: user.headerUrl,
                fit: BoxFit.cover,
                height: 160,
              ),
              height: 160,
              width: double.infinity,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 20,
                ),
                Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    Container(
                      height: 50,
                      width: 130,
                    ),
                    Positioned(
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 65.0,
                        backgroundColor: Theme.of(context).backgroundColor,
                        backgroundImage:
                            CachedNetworkImageProvider(user.photoUrl),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              '${user.username}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 18),
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  AboutScreen.routeName,
                                  arguments: user);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 8),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 0),
                        child: Text(
                          '$followerCount Followers',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .iconTheme
                                  .color
                                  .withOpacity(0.6)),
                        ), //TODO fix follower count
                      )
                    ],
                  ),
                )
              ],
            ),
            buildProfileButton(),
            Divider(
              color: Colors.grey,
              height: 0.3,
              thickness: 0.3,
            ),
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
      appBar: PreferredSize(preferredSize: Size.fromHeight(50),
              child: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: false,
            elevation: 0,
            title: Text(
              widget.profileName,
            ),
            actions: <Widget>[
              buildProfileIconButton(),
              IconButton(
                  icon: Icon(
                    FlutterIcons.settings_fea,
                    size: 20,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, SettingsScreen.routeName);
                  }),
            ]),
      ),
      body: Container(
        child: NestedScrollView(
          // allows you to build a list of elements that would be scrolled away till the body reached the top
          headerSliverBuilder: (context, _) {
            return [
              SliverToBoxAdapter(
                // delegate: SliverChildListDelegate(
                child: buildProfileHeaderTemp(),
                //),
              ),
            ];
          },
          // You tab view goes here
          body: Column(
            children: <Widget>[
              Container(
                  color: Theme.of(context).canvasColor,
                  height: 45,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(  onTap: () {
                          setState(() {
                            sortDropDown = !sortDropDown;
                          });
                        },
                                              child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: <Widget>[
                               sortDropDown? Icon(Icons.arrow_drop_up):Icon(Icons.arrow_drop_down),
                                Icon(Icons.sort),
                              ],
                            )),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            compactPosts = !compactPosts;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            !compactPosts ? Icons.view_agenda : Icons.view_day,
                            size: 20,
                          ),
                        ),
                      )
                    ],
                  )),
             Divider(height: 0.3,thickness: 0.3,color: Colors.grey,),
              if(sortDropDown)Material(
                color: Theme.of(context).backgroundColor,
                elevation: 1,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container( width: double.infinity,
                      child: InkWell(
                        onTap: (){
setState(() {
  sortBy = 'Recent';
});
                        },
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          child: Center(
                            child: Text(
                              'Recent',
                              style: TextStyle(fontSize: 18,color: sortBy == 'Recent'? Colors.blue:Theme.of(context).iconTheme.color),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(  width: double.infinity,
                      child: InkWell(
                           onTap: (){
setState(() {
  sortBy = 'Old';
});
                        },
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                     
                          child: Center(
                            child: Text(
                              'Old',
                              style: TextStyle(fontSize: 18,color: sortBy == 'Old'? Colors.blue:Theme.of(context).iconTheme.color),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(    width: double.infinity,
                      child: InkWell(   onTap: (){
setState(() {
  sortBy = 'Popular';
});
                        },
                        child: Padding(
                          
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                        
                            child:
                                Center(child: Text('Popular', style: TextStyle(fontSize: 18,color: sortBy == 'Popular'? Colors.blue:Theme.of(context).iconTheme.color)))),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: Container()
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
