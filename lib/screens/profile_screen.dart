import 'package:blue/functions/upload_post_interaction.dart';
import 'package:blue/models/post_interaction.dart';
import 'package:blue/providers/post_interactions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final String profileUsername;
//  final PostInteractions postInteractions;
  ProfileScreen({this.profileId, this.profileUsername
      // this.postInteractions
      });

  @override
  _ProfileScreenState createState() => _ProfileScreenState(
      // postInteractions
      );
}

class _ProfileScreenState extends State<ProfileScreen> {
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
  // ScrollController _scrollController = ScrollController();
  bool hasMorePosts = true; // flag for more products available or not
  bool hasMoreReposts = true; // flag for more products available or not
  int documentLimit = 10; // documents to be fetched per request
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  DocumentSnapshot lastPostDocument;
    DocumentSnapshot lastRepostDocument;
  int view;
  int lastView = -1;
  int top;
  ScrollPhysics profilePostPhysics = ScrollPhysics();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    getProfilePosts();
     getProfileReposts();

    // _scrollController = ScrollController()..addListener(() {
    //  double maxScroll = _scrollController.position.maxScrollExtent;
    //  double currentScroll = _scrollController.position.pixels;
    //  double delta = MediaQuery.of(context).size.height * 0.2;
    //  WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) { print(delta);});
    //    if (maxScroll - currentScroll <= delta) {

    //  setState(() {
    //  getProfilePosts();

    //   });
    // }
    //  });
    getFollowers();
    getFollowing();
    checkIfFollowing();

    //  WidgetsBinding.instance
    //       .addPostFrameCallback((_){
    //          RenderBox box = postKey.currentContext.findRenderObject();
    //  double yPosition = box.localToGlobal(Offset.zero).dy;
    //       });
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
    QuerySnapshot snapshot;
    if (lastPostDocument == null) {
      snapshot = await postsRef
          .document(widget.profileId)
          .collection('userPosts')
          .orderBy('timeStamp', descending: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      snapshot = await postsRef
          .document(widget.profileId)
          .collection('userPosts')
          .orderBy('timeStamp', descending: true)
          .startAfterDocument(lastPostDocument)
          .limit(documentLimit)
          .getDocuments();
    }
    if (snapshot.documents.length < documentLimit) {
      // TODO: check if length and limit is exactly equal (0 length next time)
      hasMorePosts = false;
    }
    lastPostDocument = snapshot.documents[snapshot.documents.length - 1];
    setState(() {
      postsAreLoading = false;
      postCount = snapshot.documents.length;
      posts = posts +
          snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });

    itemPositionsListener.itemPositions.addListener(() {
      if (itemPositionsListener.itemPositions.value.isEmpty == false) {
        // Determine the first visible item by finding the item with the
        // smallest trailing edge that is greater than 0.  i.e. the first
        // item whose trailing edge in visible in the viewport.
        top = itemPositionsListener.itemPositions.value
            .where((ItemPosition position) => position.itemLeadingEdge > 1)
            .reduce((ItemPosition view, ItemPosition position) =>
                position.itemLeadingEdge > view.itemLeadingEdge
                    ? position
                    : view)
            .index;
        if (top == 0) {
          setState(() {
            profilePostPhysics = NeverScrollableScrollPhysics();
          });
        } else {
          profilePostPhysics = AlwaysScrollableScrollPhysics();
        }
        view = itemPositionsListener.itemPositions.value
            .where((ItemPosition position) => position.itemTrailingEdge > 0.7)
            .reduce((ItemPosition view, ItemPosition position) =>
                position.itemTrailingEdge < view.itemTrailingEdge
                    ? position
                    : view)
            .index;
        if (postInteractions.length > 0 && lastView != view) {
          print('${snapshot.documents.length}jhgfghjkjhgf');
          print(lastView);
          print(view);
          if (true) {
            PostInteraction interaction = postInteractions[posts[view].postId];
            print(postInteractions.toString());
            print('asdfghjk');
            uploadPostInteraction(
              posts[view].postId,
              interaction.ownerId,
              true,
              interaction.upvoted,
              interaction.commented,
              interaction.shared,
              interaction.saved,
            );
          }

          lastView = view;
        }
      }
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
    QuerySnapshot snapshot;
    if (lastRepostDocument == null) {
      snapshot = await repostsRef
          .document(widget.profileId)
          .collection('userReposts')
          .orderBy('timeStamp', descending: true)
          .limit(documentLimit)
          .getDocuments();
    } else {
      snapshot = await repostsRef
          .document(widget.profileId)
          .collection('userReposts')
          .orderBy('timeStamp', descending: true)
          .startAfterDocument(lastRepostDocument)
          .limit(documentLimit)
          .getDocuments();
    }
    if (snapshot.documents.length < documentLimit) {
      // TODO: check if length and limit is exactly equal (0 length next time)
      hasMoreReposts = false;
    }
    lastRepostDocument = snapshot.documents[snapshot.documents.length - 1];
    setState(() {
      repostsAreLoading = false;
      repostCount = snapshot.documents.length;
      reposts = reposts + snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });

    // itemPositionsListener.itemPositions.addListener(() {
    //   if (itemPositionsListener.itemPositions.value.isEmpty == false) {
    //     // Determine the first visible item by finding the item with the
    //     // smallest trailing edge that is greater than 0.  i.e. the first
    //     // item whose trailing edge in visible in the viewport.
    //     top = itemPositionsListener.itemPositions.value
    //         .where((ItemPosition position) => position.itemLeadingEdge > 1)
    //         .reduce((ItemPosition view, ItemPosition position) =>
    //             position.itemLeadingEdge > view.itemLeadingEdge
    //                 ? position
    //                 : view)
    //         .index;
    //     if (top == 0) {
    //       setState(() {
    //         profilePostPhysics = NeverScrollableScrollPhysics();
    //       });
    //     } else {
    //       profilePostPhysics = AlwaysScrollableScrollPhysics();
    //     }
    //     view = itemPositionsListener.itemPositions.value
    //         .where((ItemPosition position) => position.itemTrailingEdge > 0.7)
    //         .reduce((ItemPosition view, ItemPosition position) =>
    //             position.itemTrailingEdge < view.itemTrailingEdge
    //                 ? position
    //                 : view)
    //         .index;
    //     if (postInteractions.length > 0 && lastView != view) {
    //       print('${snapshot.documents.length}jhgfghjkjhgf');
    //       print(lastView);
    //       print(view);
    //       if (true) {
    //         PostInteraction interaction = postInteractions[posts[view].postId];
    //         print(postInteractions.toString());
    //         print('asdfghjk');
    //         uploadPostInteraction(
    //           posts[view].postId,
    //           interaction.ownerId,
    //           true,
    //           interaction.upvoted,
    //           interaction.commented,
    //           interaction.shared,
    //           interaction.saved,
    //         );
    //       }

    //       lastView = view;
    //     }
    //   }
    // });
  }

  editProfile() {
    Navigator.pushNamed(context, EditProfileScreen.routeName,
        arguments: {'currentUserId': currentUserId});
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          child: Text(
            count.toString(),
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  buildButton({String text, Function function}) {
    return Container(
      height: 25,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        onPressed: function,
        child: Container(
          width: 130,
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
            FlutterIcons.more_horiz_mdi,
            size: 7,
          ),
          function: () {
            print('adddddd');
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
        username = user.username;
        return Column(
          children: <Widget>[Divider(
            height: 1,
            color: Colors.grey,
          ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.only(
                    top: 10.0, left: 15.0, right: 15.0, bottom: 0),
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
                          children: <Widget>[ Text(
                    user.displayName,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                buildCountColumn("Posts", postCount),
                                SizedBox(width: 14,),
                                buildCountColumn("Followers", followerCount),
                                  SizedBox(width: 10,),
                                buildCountColumn("Following", followingCount),
                              ],
                            ), Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  buildProfileButton(),
                                  SizedBox(width: 16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if(user.website != null)
                  
                      Linkify(text: user.website,
                      
                      linkStyle: TextStyle(
                        fontSize: 15,
                        
                            color: Colors.blue,
                            decoration: TextDecoration.none,
                      ),onOpen: (link){ launchWebsite(user.website);},
                      overflow: TextOverflow.ellipsis,
                      
                      ),
                    
                   Text(
                    user.bio,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
launchWebsite(String url)async {
 if (await canLaunch(url)) {
    await launch(url, forceWebView: true,
    enableJavaScript: true,
    ); 
  } else {
    throw 'Could not launch $url';
  }
}
  buildProfilePosts() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: profilePostPhysics,
      // controller: _scrollController,
      // shrinkWrap: true
      itemBuilder: (ctx, i) {
        return posts[i];
      },
      itemCount: posts.length,
    );
  }
    buildProfileReposts() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: profilePostPhysics,
      // controller: _scrollController,
      // shrinkWrap: true
      itemBuilder: (ctx, i) {
        return reposts[i];
      },
      itemCount: reposts.length,
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

  //  Widget get positionsView => ValueListenableBuilder<Iterable<ItemPosition>>(
  //       valueListenable: itemPositionsListener.itemPositions,
  //       builder: (context, positions, child) {
  //         int view;
  //         if (positions.isNotEmpty) {
  //           // Determine the first visible item by finding the item with the
  //           // smallest trailing edge that is greater than 0.  i.e. the first
  //           // item whose trailing edge in visible in the viewport.
  //           view = positions
  //               .where((ItemPosition position) => position.itemTrailingEdge > 0)
  //               .reduce((ItemPosition view, ItemPosition position) =>
  //                   position.itemTrailingEdge < view.itemTrailingEdge
  //                       ? position
  //                       : view)
  //               .index;

  //         }
  //         return Row(
  //           children: <Widget>[
  //             Expanded(child: Text('First Item: ${min ?? ''}')),
  //             Expanded(child: Text('Last Item: ${max ?? ''}')),
  //             const Text('Reversed: '),
  //             Checkbox(
  //                 value: reversed,
  //                 onChanged: (bool value) => setState(() {
  //                       reversed = value;
  //                     }))
  //           ],
  //         );
  //       },
  //     );

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      // Persistent AppBar that never scrolls
      appBar: header(
        context,centerTitle: false,
        title: widget.profileUsername != null
            ? Text(
                widget.profileUsername,
                style: TextStyle(color: Colors.black),
              )
            : Text(
                currentUser.username,
                style: TextStyle(color: Colors.black),
              ),
        actionButton: IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).primaryColor,
              size: 20,
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
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
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
//     return Scaffold(
//       body:NestedScrollView(
//           headerSliverBuilder: (context, value){
//              return[
//                SliverAppBar(
//                 expandedHeight: 60,
//                 pinned: true,
//                    floating: true,

//               titleSpacing: 0.0,
//                 flexibleSpace: FlexibleSpaceBar(

// collapseMode: CollapseMode.pin,
// centerTitle: true,
//                   title:
//                       Text(
//                       'name',
//                         style: TextStyle(
//                             fontSize: 20,
//                             color: Theme.of(context).primaryColor),
//                       ),

//                 ),
//                 automaticallyImplyLeading: false,
//                 elevation: 0,
//                 backgroundColor: Colors.white,
//               ),
//                buildProfileHeader(),];
//           },
//      // child: isLoading?circularProgress(): Container(),)
//       body: buildProfilePosts(),

//       ),
//     );
  }
}
