import 'package:blue/screens/about_screen.dart';
import 'package:blue/screens/all_saved_posts_screen.dart';
import 'package:blue/screens/chat_messages_screen.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blue/main.dart';
import '../widgets/post.dart';
import '../models/user.dart';
import '../widgets/progress.dart';
import './home.dart';
import './edit_profile_screen.dart';
import './settings_screen.dart';

import 'package:cached_network_image/cached_network_image.dart';


class ProfileScreen extends StatefulWidget {
  final String profileId;
//  final PostInteractions postInteractions;
  ProfileScreen({this.profileId, 
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
  User _profileUser;
final controller = ScrollController();
String profileName = '';
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
  List<Post> posts;
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
    getFollowers();
    getFollowing();
    checkIfFollowing();
    controller.addListener(onScroll);
  }
  @override
void dispose() {
  controller.removeListener(onScroll);
  super.dispose();
}
    double screenHeight;
  double barOpacity;
  onScroll() {
    setState(() {
     barOpacity = controller.offset/ (0.5*screenHeight);
     if(barOpacity > 1) barOpacity = 1;                    
       if(barOpacity <0 ) barOpacity = 0;
    });
  }

  checkIfFollowing() async {//TODO offline
    if (currentUserId != widget.profileId) {
        var  snap = await followersRef
          .doc(widget.profileId)
          .collection('userFollowers')
          .where('followers,',arrayContains: currentUserId).
          get();
      setState(() {
        isFollowing = snap.docs.length !=0;
      });
    }
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
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
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('order', descending: false)
        .get();
    List _postList = [];
    if(_postGroup.docs.length == 0){
      return Container();
    }
    for (int l = 0; l < _postGroup.docs.length; l++) {
      _postList.add(_postGroup.docs.elementAt(l).data()['posts']);
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
        postFutures.add(postsRef.doc(_postFullList[k]).get());
      }
    } else {
      for (int k = 0; k < _postFullList.length; k++) {
        postFutures.add(postsRef.doc(_postFullList[k]).get());
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
    posts = [];
    setState(() {
      postsAreLoading = false;
      postCount = postDocSnapshots.length;
      print(postDocSnapshots);
      posts = posts +
          postDocSnapshots.map((doc) => Post.fromDocument(doc.data())).toList();
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
      margin: EdgeInsets.only(top: 10,left: 15,right: 15,bottom: 0),
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
                Border.all(color:  Colors.blue),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton(User user) {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
          text: 'Edit Profile',
          function: editProfile,
          icon: FlutterIcons.edit_ant);
    } else if (isFollowing) {
      return buildButton(
          text: 'Message',
          function: (){
             Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatMessagesScreen(peerUser: user,),
          ),
        );
          },
          icon: FlutterIcons.message1_ant);
    } else if (!isFollowing) {
      return buildButton(
          text: 'Follow',
          function: handleFollowUser,
          icon: FlutterIcons.adduser_ant);
    }
  }

  handleUnfollowUser()async {// TODO batch writes and prefer server side
      usersRef.doc(widget.profileId).update({'followers': FieldValue.increment(-1) },);
      usersRef.doc(currentUser.id).update({'following': FieldValue.increment(-1) },);
      
     QuerySnapshot _followersDocs =  await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .where('followers',arrayContains: currentUser.id).get();
         _followersDocs.docs.forEach((doc) {
           doc.reference.update({'followers': FieldValue.arrayRemove([currentUser.id])});
          });
      
     QuerySnapshot _followingDocs =  await followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .where('following',arrayContains: widget.profileId).get();
         _followingDocs.docs.forEach((doc) {
           doc.reference.update({'following': FieldValue.arrayRemove([widget.profileId])});
          });

     setState(() {
      isFollowing = false;
    });
  }

  handleFollowUser() async{//TODO Batch writes and prefer server side
    usersRef.doc(widget.profileId).update({'followers': FieldValue.increment(1) },);
     usersRef.doc(currentUser.id).update({'following': FieldValue.increment(1) },);

   QuerySnapshot _followersDoc =  await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .orderBy('order').limit(1).get();
        if(_followersDoc.docs.length == 0){
           followersRef
        .doc(widget.profileId)
        .collection('userFollowers').doc().set({'order':1,'followers':[currentUser.id]});
        }else if((_followersDoc.docs.length == 1) && (_followersDoc.docs.first.data()['followers'].length>9999 )  ){
                          followersRef
        .doc(widget.profileId)
        .collection('userFollowers').doc().set({'order':_followersDoc.docs.first.data()['order']+1,'followers':[currentUser.id]}); 
        }else{
             followersRef
        .doc(widget.profileId)
        .collection('userFollowers').doc(_followersDoc.docs.first.id).update({'followers':FieldValue.arrayUnion([currentUser.id])}); 
        }
       QuerySnapshot  _followingDoc =  await followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .orderBy('order').limit(1).get();
         if(_followingDoc.docs.length == 0){
           followingRef
        .doc(widget.profileId)
        .collection('userFollowing').doc().set({'order':1,'following':[widget.profileId]});
        }else if((_followingDoc.docs.length == 1) && (_followingDoc.docs.first.data()['following'].length>9999 )  ){
                          followingRef
        .doc(widget.profileId)
        .collection('userFollowing').doc().set({'order':_followingDoc.docs.first.data()['order']+1,'following':[widget.profileId]}); 
        }else{
             followingRef
        .doc(widget.profileId)
        .collection('userFollowing').doc(_followingDoc.docs.first.id).update({'following':FieldValue.arrayUnion([widget.profileId])}); 
        }
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': currentUser.username,
      'userId': currentUser.photoUrl,
      'userProfileImg': currentUser.photoUrl,
      'timestamp': timestamp,
    });
     setState(() {
      isFollowing = true;
    });
  }

  Widget buildProfileIconButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return IconButton(
          icon: Icon(
            FluentIcons.bookmark_24_regular,
            size: 24,
          ),
          onPressed: () {
            Navigator.pushNamed(context, AllSavedPostsScreen.routeName);
          });
    } else {
      if(isFollowing)
      return Container();

      return IconButton(
          icon: Icon(
            FluentIcons.chat_24_regular,
            size: 24,
          ),
          onPressed: () {
           
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatMessagesScreen(peerUser: _profileUser,),
          ),
        );
          });
    }
  }

  buildProfileHeaderTemp() {
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument( snapshot.data.data());
    _profileUser = user;
        profileName = user.displayName;
        return Container(color: Theme.of(context).backgroundColor,
          child: Column(
            children: <Widget>[
              Container(color: Theme.of(context).backgroundColor,
                child:user.headerUrl == null?Container(height: 130,width: double.infinity,color: Theme.of(context).cardColor,): CachedNetworkImage(
                  imageUrl: user.headerUrl,
                  fit: BoxFit.cover,
                  height: 130,
                ),
                height: 130,
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
              buildProfileButton(user),
             
            ],
          ),
        );
      },
    );
  }

  String compactString(int value) {   //TODO
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
    if(posts == null)
    return circularProgress();
    if(posts == [] )
    return emptyState(context,  "Can't find any posts", 'Bad Gateway');
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 100),
      scrollDirection: Axis.vertical,
      itemBuilder: (_, i) {
        return posts[i];
      },
      itemCount: posts.length,
    );
  }

 

  


  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(backgroundColor: Colors.transparent,extendBodyBehindAppBar: false
      // Persistent AppBar that never scrolls
     , appBar: PreferredSize(
        preferredSize: Size.fromHeight(42),
        child: AnimatedBuilder(animation:  controller,
        builder: (BuildContext context, Widget child){
    barOpacity =controller.offset/ (0.2*screenHeight);
     if(barOpacity > 1) barOpacity = 1;
       if(barOpacity <0 ) barOpacity = 0;
        return AppBar(automaticallyImplyLeading: false,
                flexibleSpace: Container(   
     ), 
     backgroundColor: Theme.of(context).backgroundColor,
                centerTitle: false,
                elevation: 0,
                title: Text(
                    profileName,
                ),
                actions: <Widget>[
                    buildProfileIconButton(),
                    widget.profileId == currentUser.id?
                    IconButton(
                        icon: Icon(
                          FluentIcons.settings_24_regular,
                          size: 24,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, SettingsScreen.routeName);
                        }): 
                         PopupMenuButton(
                      padding: EdgeInsets.zero,
                      
                      color: Theme.of(context).canvasColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      itemBuilder: (_) => [
                       if(isFollowing) PopupMenuItem(           
                            child: Text('Unfollow $profileName'),
                            value:  'Unfollow'),
                       PopupMenuItem(
                            child: Text('Report $profileName'),
                            value:  'Report'),
                             PopupMenuItem(
                            child: Text('Block $profileName'),
                            value:  'Block'),
                                 PopupMenuItem(
                            child: Text('Mute $profileName'),
                            value:  'Mute'),
                      ],
                      icon: Icon(FluentIcons.more_vertical_24_regular,),
                      onSelected: (selectedValue)async {   //TODO
                        if(selectedValue ==  'Unfollow'){
                             await   handleUnfollowUser();
                        }else if(selectedValue ==  'Report'){

                        }else if(selectedValue ==  'Block'){

                        } if(selectedValue ==  'Mute'){

                        }
                       
                      },
                    )
                        
                      
                ],
                  );}
        ),
        
      ),
      body: Container(
        child: NestedScrollView(controller: controller,
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
               color: Theme.of(context).backgroundColor,
                  height: 45,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            sortDropDown = !sortDropDown;
                          });
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 2),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: <Widget>[
                                
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: Theme.of(context).cardColor),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [ sortDropDown
                                    ? Icon(FluentIcons.caret_up_24_filled,size: 18,)
                                    : Icon(FluentIcons.caret_down_24_filled,size: 18,),Text(sortBy,style: TextStyle(fontSize: 16),)],)                               ),
                             
                              ],
                            ),),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            compactPosts = !compactPosts;
                          });
                        },
                        child:Container( 
                      
                           decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: Theme.of(context).cardColor),
                             padding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),margin: EdgeInsets.only(right: 15),
                          child: Icon(
                            !compactPosts ? Icons.view_agenda : Icons.view_day,
                            size: 20,
                          ),
                        ),
                      )
                    ],
                  )),
              Divider(
                height: 0.3,
                thickness: 0.3,
                color: Colors.grey,
              ),
              if (sortDropDown)
                Material(
                  color: Theme.of(context).backgroundColor,
                  elevation: 1,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              sortBy = 'Recent';
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: Center(
                              child: Text(
                                'Recent',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: sortBy == 'Recent'
                                        ? Colors.blue
                                        : Theme.of(context).iconTheme.color),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              sortBy = 'Old';
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: Center(
                              child: Text(
                                'Old',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: sortBy == 'Old'
                                        ? Colors.blue
                                        : Theme.of(context).iconTheme.color),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              sortBy = 'Popular';
                            });
                          },
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              child: Center(
                                  child: Text('Popular',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: sortBy == 'Popular'
                                              ? Colors.blue
                                              : Theme.of(context)
                                                  .iconTheme
                                                  .color)))),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(child: Container(color: Theme.of(context).canvasColor,child:  buildProfilePosts(),)),
            
            ],
          ),
        ),
      ),
    );
  }
}
