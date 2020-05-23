import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/post.dart';
import '../models/user.dart';
import '../widgets/header.dart';
import '../widgets/progress.dart';
import './home.dart';
import './edit_profile_screen.dart';
import './settings_screen.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileScreen extends StatefulWidget {
  final String profileId;
  ProfileScreen({this.profileId});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  bool isFollowing = false;
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];
  ScrollController _scrollController = ScrollController();
bool hasMore = true; // flag for more products available or not  
int documentLimit = 10; // documents to be fetched per request  
  
DocumentSnapshot lastDocument;

  @override
  void initState() {
    super.initState();
     getProfilePosts();  
    _scrollController = ScrollController()..addListener(() {  
     double maxScroll = _scrollController.position.maxScrollExtent;  
     double currentScroll = _scrollController.position.pixels;  
     double delta = MediaQuery.of(context).size.height * 0.2;  
     WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) { print(delta);});
     if (maxScroll - currentScroll <= delta) {  

       setState(() {
       getProfilePosts();  
         
       });
     }  
   }); 
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
    if (!hasMore) {  
     print('No More posts');  
     return;  
   }  
    if (isLoading) {  
     return;  
   }  
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot;
    if (lastDocument == null) { 
      snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timeStamp', descending: true)
        .limit(documentLimit) 
        .getDocuments();
    }  else {
     snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timeStamp', descending: true)
        .startAfterDocument(lastDocument) 
        .limit(documentLimit) 
        .getDocuments();
    }
     if (snapshot.documents.length < documentLimit) {            // TODO: check if length and limit is exactly equal (0 length next time)
     hasMore = false;  
   }  
          lastDocument = snapshot.documents[snapshot.documents.length - 1];
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = posts + snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }
  
  editProfile() {
    Navigator.pushNamed(context, EditProfileScreen.routeName,
        arguments: {'currentUserId': currentUserId});
  }

  Row buildCountColumn(String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            count.toString(),
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 1.5,
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  buildButton({String text, Function function}) {
    return Container(
      height: 35,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        onPressed: function,
        child: Container(
          width: 100,
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
    );
  }

  buildButtonCircular({Icon icon, Function function}) {
    return Container(
      height: 33,
      width: 33,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.blue,
          border: Border.all(color: Colors.blue)),
      child: IconButton(
        icon: icon,
        onPressed: function,
        color: Colors.white,
        iconSize: 18,
        alignment: Alignment.topLeft,
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
          icon: Icon(Icons.more_horiz),
          function: () {
            print('adddddd');
          });
    } else {
      return buildButtonCircular(
          icon: Icon(Icons.more_horiz),
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
        username = user.username;
        return Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.only(
                    top: 20.0, left: 26.0, right: 26.0, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[      
                    CircleAvatar(
                      radius: 45.0,
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
                        height: 104,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  username,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 32,width: 35,
                                                                  child: IconButton(
                                      icon: Icon(
                                        Icons.settings,
                                        color: Theme.of(context).primaryColor,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, SettingsScreen.routeName);
                                      }),
                                ),
                              ],
                            ),
                            Text(
                              user.displayName,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Expanded(
                              child: Text(
                                user.bio,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 26,
                  ),
                  buildProfileButton(),
                  SizedBox(width: 16),
                  buildProfileIconButton()
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 5, right: 15, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Column(children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          buildCountColumn("post", postCount),
                          SizedBox(width: 4),
                          Container(
                            height: 6,
                            width: 6,
                            child: SvgPicture.asset(
                                'assets/icons/seperation_dot_icon.svg'),
                          ),
                          SizedBox(width: 4),
                          buildCountColumn("followers", followerCount),
                          SizedBox(width: 5),
                          Container(
                              height: 6,
                              width: 6,
                              child: SvgPicture.asset(
                                  'assets/icons/seperation_dot_icon.svg')), // make svg visible
                          SizedBox(width: 4),
                          buildCountColumn("following", followingCount),
                        ],
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  buildProfilePosts() {
    if (posts.length == 0) {
      return Container();
    }
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      itemBuilder: (ctx,i){
                  return posts[i];
      },
     itemCount: posts.length,
    );
  }

  PreferredSize profileBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(50.0),
      child: AppBar(
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: null),
        backgroundColor: Colors.white,
        elevation: 1,
        title: FlatButton(
          onPressed: null,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Text(
            username,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                Navigator.pushNamed(context, SettingsScreen.routeName);
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            buildProfileHeader(),
            Divider(),
            buildProfilePosts(),
           Container(
             padding: EdgeInsets.symmetric(vertical: 5),
             child: isLoading?circularProgress(): Container(),)
          ],
        ),
      ),
    );
  }
}
