// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/user_report_dialog.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/about_screen.dart';
import 'package:blue/screens/all_saved_posts_screen.dart';
import 'package:blue/screens/chat_messages_screen.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/paginated_posts.dart';
import '../models/user.dart';
import '../services/functions.dart';
import '../widgets/post.dart';
import '../widgets/progress.dart';
import './edit_profile_screen.dart';
import './home.dart';
import './settings_screen.dart';
import '../services/boxes.dart';

enum Sort { Recent, Earliest, Best }

class ProfileScreen extends StatefulWidget {
  final String profileId;
//  final PostInteractions postInteractions;
  ProfileScreen({
    this.profileId,
    // this.postInteractions
  });
  // :super(key: UniqueKey());

  @override
  _ProfileScreenState createState() => _ProfileScreenState(
      // postInteractions
      );
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
  PaginatedPosts postsList;
  // final PostInteractions postInteractions;
  // _ProfileScreenState(this.postInteractions);
  User _profileUser;
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
  List<dynamic> posts = [];
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
  ScrollController _controller = ScrollController();
  Sort sort = Sort.Recent;
  bool loaded = false;
  int lastDoc = 0;
  bool empty = false;
  var future;
  @override
  void didChangeDependencies() {
    addPosts(Sort.Recent);
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          empty != true &&
          loaded != true) {
        print(
            'sdfsefsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
        setState(() {
          addPosts(sort, changing: true);
        });
      }
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

   if( Boxes.followingBox.containsKey(widget.profileId)){
     isFollowing = true;
   }
    getFollowers();
    getFollowing();

    // _controller.addListener(onScroll);
  }

  addPosts(Sort sort, {bool changing}) async {
    if (changing == null ? false : changing)
      setState(() {
        loaded = false;
      });
      print('owner-${widget.profileId}');
    int length = 4;
    int _id = 3;
    String  _where = "{owner_id:{_eq:$_id}}";
    String _orderBy;
    if (sort == Sort.Recent){
          _orderBy = "{created_at:desc}";
    }
    else if (sort == Sort.Best){
           _orderBy = "{created_at:desc}";//TODO  voted ordering 
    }
    else{
           _orderBy = "{created_at:asc}";
    }
    
    if (lastDoc == 0) {
      dynamic _snapshot = await Hasura.getPosts(length,0,_orderBy,where: _where); 
  

      setState(() {
    posts = _snapshot
          .map((doc) => Post.fromDocument(doc, isCompact: false,commentsShown: false,hasura: true,))
          .toList();
      });

      if (_snapshot.length == 0) {
        setState(() {
          empty = true;
        });
        return;
      }
      lastDoc = lastDoc + _snapshot.length;
      if (_snapshot.length < length) {
        setState(() {
          loaded = true;
        });
        return;
      }
    } else {
         var _snapshot = await Hasura.getPosts(length,lastDoc,"{created_at:desc}",where: _where);
      _snapshot.forEach((doc) {
        posts.add(Post.fromDocument(doc,isCompact: false,commentsShown: false,hasura: true,));
      });

      if (_snapshot.length < length) {
        setState(() {
          loaded = true;
        });
        return;
      }
      lastDoc = lastDoc + _snapshot.length;
    }
  }
  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    if (this.mounted)
      setState(() {
        followerCount = snapshot.docs.length;
      });
  }
  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    if (this.mounted)
      setState(() {
        followingCount = snapshot.docs.length;
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
      margin: EdgeInsets.only(top: 0, left: 5, right: 5, bottom: 0),
      height: 40,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        onPressed: function,
        child: Container(
          height: 33,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    print(isFollowing);
    if (isProfileOwner) {
      return buildButton(
          text: 'Edit Profile',
          function: editProfile,
          icon: FlutterIcons.edit_ant);
    } else if (isFollowing) {
      return buildButton(
          text: 'Message',
          function: () {
            if (_profileUser != null)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatMessagesScreen(
                    peerUser: _profileUser,
                  ),
                ),
              );
          },
          icon: FlutterIcons.message1_ant);
    } else if (!isFollowing) {
      return buildButton(
          text: 'Follow',
          function: () {
            Functions().handleFollowUser(widget.profileId);
            setState(() {
              isFollowing = true;
            });
          },
          icon: FlutterIcons.adduser_ant);
    }
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
      if (isFollowing) return Container();

      return IconButton(
          icon: Icon(
            FluentIcons.chat_24_regular,
            size: 24,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatMessagesScreen(
                  peerUser: _profileUser,
                ),
              ),
            );
          });
    }
  }

  buildProfileHeaderTemp() {
    print( currentUser.id);
  future =  currentUser.id == widget.profileId? Hasura.getUser():usersRef.doc(widget.profileId).get();
    return FutureBuilder(
      future: Hasura.getUser()
      ,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument( currentUser.id == widget.profileId?snapshot.data['data']['users_by_pk']:snapshot.data.data(),hasura: currentUser.id == widget.profileId );
        _profileUser = user;
        profileName = user.name;
        return Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              children: <Widget>[
                Container(
                  color: Theme.of(context).backgroundColor,
                  child: user.headerUrl == null
                      ? Container(
                          height: 150,
                          width: double.infinity,
                          color: Theme.of(context).cardColor,
                        )
                      : CachedNetworkImage(
                          imageUrl: user.headerUrl,
                          fit: BoxFit.cover,
                          height: 150,
                        ),
                  height: 150,
                  width: double.infinity,
                ),
                ExpansionTile(
                  expandedAlignment: Alignment.topLeft,
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  childrenPadding:
                      EdgeInsets.only(left: 10, bottom: 10, top: 0, right: 10),
                  title: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      '${user.username}',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                    ),
                  ),
                  leading: Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      Container(
                        height: 60,
                        width: 120,
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).backgroundColor),
                          padding: EdgeInsets.all(3),
                          child: CircleAvatar(
                            radius: 57.0,
                            backgroundColor: Theme.of(context).backgroundColor,
                            backgroundImage:
                                CachedNetworkImageProvider(user.avatarUrl??"https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    child: Text(
                      '$followerCount Followers',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              Theme.of(context).iconTheme.color.withOpacity(0.6)),
                    ), //TODO fix follower count
                  ),
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Row(
                          children: [
                            Text('$followingCount',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color
                                        .withOpacity(0.9),
                                    fontWeight: FontWeight.w500)),
                            SizedBox(
                              width: 5,
                            ),
                            Text('following',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400)),
                          ],
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(user.bio,
                          style: TextStyle(
                            fontSize: 16,
                          )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).cardColor),
                              child: Icon(
                                FluentIcons.link_square_24_regular,
                                size: 18,
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Linkify(
                              text: user.website,
                              linkStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.blue,
                                decoration: TextDecoration.none,
                              ),
                              onOpen: (link) {
                                launchWebsite(user.website);
                              },
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ;
      },
    );
  }

  headerButton(Icon icon, Function fn) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child:
      //  Material(elevation: 0,
      //   child: 
        InkWell(
          onTap: fn,
              child:
                // child: new BackdropFilter(
                    // filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                 Container(
                      color:Colors.grey.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                      child: Icon(icon.icon,color: Colors.white,),
                      // ),
                    // ),
              )),
        ),
      
    );
  }

  String compactString(int value) {
    //TODO
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

  sortTab(Sort value) {
    return Expanded(
        child: Material(
            child: InkWell(
                onTap: () {
                  setState(() {
                    sort = value;
                    posts = [];
                    lastDoc = 0;
                    addPosts(value, changing: true);
                  });
                },
                child: Center(
                    child: Text(
                  value.toString().substring(5),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: sort == value
                        ? Colors.blue
                        : Theme.of(context).iconTheme.color,
                  ),
                )))));
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // screenHeight = MediaQuery.of(context).size.height;
    if (_controller == null) {
      _controller = ScrollController();
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: Container(),
      ),
      body: SafeArea(
        child: NestedScrollView(
          controller: _controller,
          headerSliverBuilder: (context, _) {
            return [
              SliverList(
                delegate: SliverChildListDelegate([
                  Material(
                    color: Colors.grey[300],
                    child: StickyHeaderBuilder(
                      overlapHeaders: true,
                      // controller: _controller,
                      builder: (BuildContext context, double stuckAmount) {
                        stuckAmount = 1.0 - stuckAmount.clamp(0.0, 1.0);
                        return Container(
                          height: 50.0,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                Colors.black54.withOpacity(0.7),
                                Colors.transparent
                              ])),
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: <Widget>[
                              if (widget.profileId == currentUser.id)
                                Padding(
                                  padding: EdgeInsets.only(right: 36),
                                ),
                              widget.profileId != currentUser.id
                                  ? headerButton(
                                      Icon(
                                        FluentIcons.arrow_left_24_regular,
                                        size: 26,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ), () {
                                      Navigator.pop(context);
                                    })
                                  : Container(
                                      width: 30,
                                    ),
                              if (!isFollowing && currentUser.id != widget.profileId)
                                Padding(
                                  padding: EdgeInsets.only(right: 36),
                                ),
                              Expanded(
                                  child: Center(
                                child: Text(
                                  profileName,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                      color: Colors.white),
                                ),
                              )),
                              if (!isFollowing && currentUser.id != widget.profileId)
                                Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: headerButton(
                                      Icon(
                                        FluentIcons.chat_24_regular,
                                        size: 26,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ), () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChatMessagesScreen(
                                          peerUser: _profileUser,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              if (widget.profileId == currentUser.id)
                                Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: headerButton(
                                      Icon(
                                        FluentIcons.bookmark_24_regular,
                                        size: 26,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ), () {
                                    Navigator.pushNamed(
                                        context, AllSavedPostsScreen.routeName);
                                  }),
                                ),
                              widget.profileId == currentUser.id
                                  ? headerButton(
                                      Icon(
                                        FluentIcons.settings_24_regular,
                                        size: 26,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ), () {
                                      Navigator.pushNamed(
                                          context, SettingsScreen.routeName);
                                    })
                                  : Transform.scale(
                                      scale: 0.8,
                                      child: Container(
                                        decoration: BoxDecoration(shape: BoxShape.circle,  color: Colors.white.withOpacity(0.25),),
                                      margin:
                                            EdgeInsets.symmetric(horizontal: 8,vertical: 5),child: PopupMenuButton(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        color: Theme.of(context)
                                                            .canvasColor,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        itemBuilder: (_) => [
                                                          if (isFollowing)
                                                            PopupMenuItem(
                                                                child: Text(
                                                                    'Unfollow $profileName'),
                                                                value:
                                                                    'Unfollow'),
                                                          PopupMenuItem(
                                                              child: Text(
                                                                  'Report $profileName'),
                                                              value: 'Report'),
                                                          PopupMenuItem(
                                                              child: Text(
                                                                  '${PreferencesUpdate().containsInStringList('blocked_accounts', _profileUser.id) ? "Unblock" : "Block"} $profileName'),
                                                              value: PreferencesUpdate().containsInStringList(
                                                                      'blocked_accounts',
                                                                      _profileUser
                                                                          .id)
                                                                  ? "Unblock"
                                                                  : "Block"),
                                                          PopupMenuItem(
                                                              child: Text(
                                                                  '${PreferencesUpdate().containsInStringList('muted_messages', _profileUser.id) ? "Unmute" : "Mute"} $profileName'),
                                                              value: PreferencesUpdate().containsInStringList(
                                                                      'muted_messages',
                                                                      _profileUser
                                                                          .id)
                                                                  ? "Unmute"
                                                                  : "Mute"),
                                                        ],
                                                        icon: Icon(
                                                          FluentIcons
                                                              .more_24_filled,
                                                          size: 24,
                                                          color: Colors.white,
                                                        ),
                                                        onSelected:
                                                            (selectedValue) async {
                                                          Map peer = {
                                                            'peerId':
                                                                _profileUser.id,
                                                            'peerUsername':
                                                                _profileUser
                                                                    .username,
                                                            'peerImageUrl':
                                                                _profileUser
                                                                    .photoUrl,
                                                            'peerName':
                                                                _profileUser
                                                                    .name
                                                          };
                                                          print(
                                                              '$selectedValue user');
                                                          switch (
                                                              selectedValue) {
                                                            case 'Unfollow':
                                                              Functions()
                                                                  .handleUnfollowUser(
                                                                      widget
                                                                          .profileId);
                                                              setState(() {
                                                                isFollowing =
                                                                    false;
                                                              });
                                                              break;
                                                            case 'Report':
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return UserReportDialog(
                                                                    peer: peer
                                                                  );
                                                                },
                                                              );
                                                              break;
                                                            case 'Block':
                                                              Functions()
                                                                  .blockUser(
                                                                      peer);
                                                              break;
                                                            case 'Unblock':
                                                              Functions()
                                                                  .unblockUser(
                                                                      peer);
                                                              break;
                                                            case 'Mute':
                                                              Functions()
                                                                  .muteUser(
                                                                      peer);
                                                              break;
                                                            case 'Unmute':
                                                              Functions()
                                                                  .unmuteUser(
                                                                      peer);
                                                              break;
                                                          }
                                                        },
                                                      ),
                                                    )),
                                     
                            ],
                          ),
                        );
                      },
                      content: buildProfileHeaderTemp(),
                    ),
                  ),
                ]),
              ),
            ];
          },
          body:RefreshIndicator(onRefresh: ()async{
          setState(() {
            future =  currentUser.id == widget.profileId? Hasura.getUser():usersRef.doc(widget.profileId).get();
          });
       await   Future.delayed(Duration(milliseconds: 500));
          return;
        },
                  child:  Column(
            children: [
              if (_controller == null)
                Container()
              else
                Material(
                  color: Theme.of(context).backgroundColor,
                  child: StickyHeaderBuilder(
                      // controller: _controller == null?ScrollController():_controller  ,
                      builder: (BuildContext context, double stuckAmount) {
                        stuckAmount = 1.0 - stuckAmount.clamp(0.0, 1.0);
                        Widget button = Container(
                            height: 50.0,
                            color: Color.lerp(Theme.of(context).backgroundColor,
                                Theme.of(context).backgroundColor, stuckAmount),
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Center(
                              child: buildProfileButton(),
                            ));
                        if (stuckAmount > 0.0)
                          button = Container(
                              height: 50.0,
                              color: Theme.of(context).backgroundColor,
                              padding: EdgeInsets.symmetric(horizontal: 15.0),
                              child: Center(
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      profileName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19),
                                    )),
                                    buildProfileButton()
                                  ],
                                ),
                              ));
                        return AnimatedSwitcher(
                            duration: Duration(milliseconds: 100),
                            reverseDuration: Duration(milliseconds: 100),
                            child: button);
                      },
                      content: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1, color: Theme.of(context).cardColor),
                            color: Theme.of(context).backgroundColor,
                          ),
                          height: 36,
                          margin: EdgeInsets.only(
                              left: 10, right: 10, bottom: 6, top: 4),
                          child: Row(
                            children: [
                              sortTab(Sort.Recent),
                              Container(
                                width: 2,
                                height: 32,
                                color: Theme.of(context).cardColor,
                              ),
                              sortTab(Sort.Best),
                              Container(
                                width: 2,
                                height: 32,
                                color: Theme.of(context).cardColor,
                              ),
                              sortTab(Sort.Earliest),
                            ],
                          ))),
                ),
              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).cardColor,
              ),
              Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 100),
                    itemCount: posts.length+1,
                    itemBuilder: (context,i){
                      if(i == posts.length){
                        return loaded ? Container() : circularProgress();
                      }
                      return posts[i];

                    },
              ))
            ],
          ),)
        ),
      ),
    );
  }
}
