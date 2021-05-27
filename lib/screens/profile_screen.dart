// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:blue/constants/strings.dart';
import 'package:blue/screens/follows_screen.dart';
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

import 'package:mk_drop_down_menu/mk_drop_down_menu.dart';
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

enum Sort { Recent, Oldest, Best }

class ProfileScreen extends StatefulWidget {
  final int profileId;
  final bool tabPage;
//  final PostInteractions postInteractions;
  ProfileScreen({this.profileId, this.tabPage
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
  bool postsAreLoading = false;
  bool repostsAreLoading = false;
  int postCount = 0;
  int repostCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<dynamic> posts = [];
  int documentLimit = 10; // documents to be fetched per request

  String sortBy = 'Recent';
  bool sortDropDown = false;
  ScrollController _controller = ScrollController();
  Sort sort = Sort.Recent;
  bool loaded = false;
  int lastDoc = 0;
  bool empty = false;
  bool _compact = false;
  var future;
  @override
  void didChangeDependencies() {
    print(widget.profileId);
    print('d');
    addPosts(Sort.Recent);
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          empty != true &&
          loaded != true) {
        print('');
        setState(() {
          addPosts(sort, changing: true);
        });
      }
    });

    print(widget.profileId);
    super.didChangeDependencies();
  }

  bool justFollowed = false;
  @override
  void initState() {
    super.initState();
    isFollowing = Boxes.followingBox.containsKey(widget.profileId);
    // _controller.addListener(onScroll);
  }

  addPosts(Sort sort, {bool changing}) async {
    if (changing == null ? false : changing)
      setState(() {
        loaded = false;
      });
    print('owner-${widget.profileId}');
    int length = Hasura.postLimit;
    int _id = widget.profileId;
    String _where = "{owner_id:{_eq:$_id}}";
    String _orderBy;
    if (sort == Sort.Recent) {
      _orderBy = "{created_at:desc}";
    } else if (sort == Sort.Best) {
      _orderBy = "{score:desc}"; //TODO  voted ordering
    } else {
      _orderBy = "{created_at:asc}";
    }

    if (lastDoc == 0) {
      dynamic _snapshot =
          await Hasura.getPosts(length, 0, _orderBy, where: _where);

      setState(() {
        posts = _snapshot
            .map((doc) => Post.fromDocument(
                  doc,
                  isCompact: _compact,
                  commentsShown: false,
                ))
            .toList();
      });

      if (_snapshot.length == 0 && lastDoc == 0) {
        setState(() {
          empty = true;
          loaded = true;
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
      var _snapshot = await Hasura.getPosts(
          length, lastDoc, "{created_at:desc}",
          where: _where);
      _snapshot.forEach((doc) {
        posts.add(Post.fromDocument(
          doc,
          isCompact: _compact,
          commentsShown: false,
        ));
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
      height: 30,
      width: 124,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        onPressed: function,
        child: Container(
          height: 30,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 14,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                text,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            border: Border.all(color: Theme.of(context).accentColor),
            borderRadius: BorderRadius.circular(80.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    bool isProfileOwner =
        Boxes.currentUserBox.get('user_id') == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
          text: 'Edit Profile',
          function: editProfile,
          icon: FlutterIcons.edit_ant);
    } else if (isFollowing) {
      return buildButton(
          text: 'Message',
          function: () async {
            if (_profileUser != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatMessagesScreen(
                    peerUser: _profileUser,
                  ),
                ),
              );
            }
          },
          icon: FlutterIcons.message1_ant);
    } else if (!isFollowing) {
      return buildButton(
          text: 'Follow',
          function: () {
            Functions().handleFollowUser(_profileUser.userId);
            setState(() {
              justFollowed = true;
              isFollowing = true;
            });
          },
          icon: FlutterIcons.adduser_ant);
    }
  }

  Widget buildProfileIconButton() {
    bool isProfileOwner =
        Boxes.currentUserBox.get('user_id') == widget.profileId;
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
          onPressed: () async {
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
    print('current user id ^');
    future = Hasura.getUser(
        id: widget.profileId,
        self: Boxes.currentUserBox.get('user_id') == widget.profileId
            ? true
            : false);
    return Container(
      color: Colors.white == Theme.of(context).iconTheme.color
          ? Colors.grey.shade900
          : Colors.white,
      child: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(height: 200, child: circularProgress());
          }
          print(snapshot.data['data']['users_by_pk']);
          User user = User.fromDocument(snapshot.data['data']['users_by_pk']);
          if (Boxes.currentUserBox.get('user_id') == widget.profileId) {
            Boxes.currentUserBox.put('avatar_url', user.avatarUrl);
          }

          _profileUser = user;
          profileName = user.name;
          return Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: [
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
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment(0, 0.3),
                              colors: [
                            Colors.black54.withOpacity(0.2),
                            Colors.transparent
                          ])),
                      height: 150,
                      width: double.infinity,
                    )
                  ],
                ),
                ListTile(
                    title: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Stack(
                        overflow: Overflow.visible,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, FollowsScreen.routeName,
                                          arguments: {
                                            'f': true,
                                            'i': widget.profileId
                                          });
                                    },
                                    child: Container(
                                        child: Column(
                                      children: [
                                        Text(
                                            '${Functions.abbreviateNumber(user.followingCount)}',
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w700)),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text('Following',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color
                                                    .withOpacity(0.6),
                                                fontWeight: FontWeight.w800)),
                                      ],
                                    ))),
                                SizedBox(
                                  width: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, FollowsScreen.routeName,
                                        arguments: {
                                          'f': false,
                                          'i': widget.profileId
                                        });
                                  },
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Text(
                                            '${Functions.abbreviateNumber(justFollowed ? user.followerCount + 1 : user.followerCount)}',
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w700)),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text('Followers',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color
                                                    .withOpacity(0.6),
                                                fontWeight: FontWeight.w800)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 60,
                            child: Text(
                              '${user.username}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 26,
                                  color: user.headerUrl != null &&
                                          user.headerUrl != ''
                                      ? Colors.white
                                      : Theme.of(context).iconTheme.color),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        Container(
                          height: 40,
                          width: 130,
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).backgroundColor),
                            padding: EdgeInsets.all(3),
                            child: CircleAvatar(
                              radius: 60.0,
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              backgroundImage: CachedNetworkImageProvider(user
                                      .avatarUrl ??
                                  "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
                            ),
                          ),
                        ),
                      ],
                    )),

                if (user.about != null && user.about != '')
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(user.about ?? '',
                        style: TextStyle(
                          fontSize: 16,
                        )),
                  ),
                if (user.about != null && user.about != '')
                  SizedBox(
                    height: 10,
                  ),
                if (user.website != null && user.website != '')
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Functions().launchURL(user.website, context);
                      },
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
                              onOpen: (link) {},
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // ],
              ],
            ),
          );
        },
      ),
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
                color: Colors.black38,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    icon.icon,
                    color: Colors.white,
                  ),
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
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  MKDropDownMenuController mKController = MKDropDownMenuController();
  sortTab(Sort value) {
    return Container(
        height: 40,
        color: Theme.of(context).canvasColor,
        child: Center(
          child: GestureDetector(
              onTap: () {
                setState(() {
                  sort = value;
                  posts = [];
                  lastDoc = 0;
                  addPosts(value, changing: true);
                  mKController.hideMenu();
                });
              },
              child: Center(
                  child: Text(
                value.toString().substring(5),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: sort == value
                      ? Colors.blue
                      : Theme.of(context).iconTheme.color,
                ),
              ))),
        ));
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
                        overlapHeaders: true, // controller: _controller,
                        builder: (BuildContext context, double stuckAmount) {
                          stuckAmount = 1.0 - stuckAmount.clamp(0.0, 1.0);
                          return Container(
                            height: 50.0,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                  Colors.black54.withOpacity(0.5),
                                  Colors.transparent
                                ])),
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: <Widget>[
                                if (widget.profileId ==
                                    Boxes.currentUserBox.get('user_id'))
                                  Padding(
                                    padding: EdgeInsets.only(right: 36),
                                  ),
                                widget.tabPage != true
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
                                if (!isFollowing &&
                                    Boxes.currentUserBox.get('user_id') !=
                                        widget.profileId)
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
                                if (!isFollowing &&
                                    Boxes.currentUserBox.get('user_id') !=
                                        widget.profileId)
                                  Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: headerButton(
                                        Icon(
                                          FluentIcons.chat_24_regular,
                                          size: 26,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ), () async {
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
                                if (widget.profileId ==
                                    Boxes.currentUserBox.get('user_id'))
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: headerButton(
                                        Icon(
                                          FluentIcons.bookmark_24_regular,
                                          size: 26,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ), () {
                                      Navigator.pushNamed(context,
                                          AllSavedPostsScreen.routeName);
                                    }),
                                  ),
                                widget.profileId ==
                                        Boxes.currentUserBox.get('user_id')
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
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Colors.black.withOpacity(0.32),
                                          ),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 3, vertical: 3),
                                          child: PopupMenuButton(
                                            padding: EdgeInsets.zero,
                                            color:
                                                Theme.of(context).canvasColor,
                                            iconSize: 20,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            itemBuilder: (_) => [
                                              if (isFollowing)
                                                PopupMenuItem(
                                                    child: Text(
                                                        'Unfollow $profileName'),
                                                    value: 'Unfollow'),
                                              PopupMenuItem(
                                                  child: Text(
                                                      'Report $profileName'),
                                                  value: 'Report'),
                                              PopupMenuItem(
                                                  child: Text(
                                                      '${PreferencesUpdate().containsInList('blocked_accounts', widget.profileId) ? "Unblock" : "Block"} $profileName'),
                                                  value: PreferencesUpdate()
                                                          .containsInList(
                                                              'blocked_accounts',
                                                              _profileUser
                                                                  .userId)
                                                      ? "Unblock"
                                                      : "Block"),
                                              PopupMenuItem(
                                                  child: Text(
                                                      '${PreferencesUpdate().containsInList('muted_messages', _profileUser.userId) ? "Unmute" : "Mute"} $profileName'),
                                                  value: PreferencesUpdate()
                                                          .containsInList(
                                                              'muted_messages',
                                                              _profileUser
                                                                  .userId)
                                                      ? "Unmute"
                                                      : "Mute"),
                                            ],
                                            icon: Icon(
                                              Icons.more_horiz_outlined,
                                              size: 24,
                                              color: Colors.white,
                                            ),
                                            onSelected: (selectedValue) async {
                                              Map peer = {
                                                'peerId': widget.profileId,
                                                'peerUsername':
                                                    _profileUser.username,
                                                'peerImageUrl':
                                                    _profileUser.photoUrl,
                                                'peerName': _profileUser.name
                                              };
                                              print(
                                                  '$selectedValue user $peer');
                                              switch (selectedValue) {
                                                case 'Unfollow':
                                                  Functions()
                                                      .handleUnfollowUser(
                                                          _profileUser.userId);
                                                  setState(() {
                                                    justFollowed = false;
                                                    isFollowing = false;
                                                  });
                                                  break;
                                                case 'Report':
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return UserReportDialog(
                                                          peer: peer);
                                                    },
                                                  );
                                                  break;
                                                case 'Block':
                                                  Functions().blockUser(peer);
                                                  break;
                                                case 'Unblock':
                                                  Functions().unblockUser(peer);
                                                  break;
                                                case 'Mute':
                                                  Functions().muteUser(peer);
                                                  break;
                                                case 'Unmute':
                                                  Functions().unmuteUser(peer);
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
            body: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  Hasura.getUser(self: true);
                });
                await Future.delayed(Duration(milliseconds: 500));
                return;
              },
              child: Column(
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
                                color: Color.lerp(
                                    Theme.of(context).backgroundColor,
                                    Theme.of(context).backgroundColor,
                                    stuckAmount),
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    MKDropDownMenu(
                                      controller: mKController,
                                      menuBuilder: () {
                                        return Container(
                                          child: Material(
                                            child: Column(
                                              children: [
                                                sortTab(Sort.Recent),
                                                Divider(
                                                  indent: 10,
                                                  endIndent: 10,
                                                  thickness: 1,
                                                  height: 1,
                                                  color: Colors.grey
                                                      .withOpacity(0.4),
                                                ),
                                                sortTab(Sort.Best),
                                                Divider(
                                                  indent: 10,
                                                  endIndent: 10,
                                                  thickness: 1,
                                                  height: 1,
                                                  color: Colors.grey
                                                      .withOpacity(0.4),
                                                ),
                                                sortTab(Sort.Oldest),
                                              ],
                                            ),
                                          ),
                                          width:
                                              MediaQuery.of(context).size.width,
                                        );
                                      },
                                      menuMargin: 8,
                                      headerBuilder: (b) {
                                        if (true) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  b
                                                      ? FluentIcons
                                                          .chevron_up_12_filled
                                                      : FluentIcons
                                                          .chevron_down_12_filled,
                                                  size: 16,
                                                ),
                                                Text(
                                                  sort.toString().substring(5),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                )
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _compact = false;
                                              loaded = false;
                                              lastDoc = 0;
                                              empty = false;
                                              posts = [];
                                            });
                                            addPosts(sort, changing: true);
                                          },
                                          child: Container(
                                            height: 24,
                                            width: 24,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 4),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              // color: Theme.of(context)
                                              //     .iconTheme
                                              //     .color
                                              //     .withOpacity(
                                              //         _compact ? 1 : 0.7)
                                              children: [
                                                Container(
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .iconTheme
                                                          .color
                                                          .withOpacity(!_compact
                                                              ? 1
                                                              : 0.7),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(3),
                                                              topRight: Radius
                                                                  .circular(3),
                                                              bottomLeft: Radius
                                                                  .circular(1),
                                                              bottomRight:
                                                                  Radius.circular(
                                                                      1))),
                                                ),
                                                Container(
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .iconTheme
                                                          .color
                                                          .withOpacity(!_compact
                                                              ? 1
                                                              : 0.7),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(1),
                                                              topRight: Radius
                                                                  .circular(1),
                                                              bottomLeft: Radius
                                                                  .circular(3),
                                                              bottomRight:
                                                                  Radius.circular(
                                                                      3))),
                                                ),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: _compact
                                                        ? Theme.of(context)
                                                            .backgroundColor
                                                        : Colors.grey
                                                            .withOpacity(0.4)),
                                                color: _compact
                                                    ? Theme.of(context)
                                                        .backgroundColor
                                                    : Theme.of(context)
                                                        .canvasColor,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 3,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _compact = true;
                                              loaded = false;
                                              lastDoc = 0;
                                              empty = false;
                                              posts = [];
                                            });
                                            addPosts(sort, changing: true);
                                          },
                                          child: Container(
                                            height: 24,
                                            width: 24,
                                            padding: EdgeInsets.all(4),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  height: 3.4,
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .iconTheme
                                                          .color
                                                          .withOpacity(_compact
                                                              ? 1
                                                              : 0.7),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              1)),
                                                ),
                                                Container(
                                                  height: 3.4,
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .iconTheme
                                                          .color
                                                          .withOpacity(_compact
                                                              ? 1
                                                              : 0.7),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              1)),
                                                ),
                                                Container(
                                                  height: 3.4,
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .iconTheme
                                                          .color
                                                          .withOpacity(_compact
                                                              ? 1
                                                              : 0.7),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              1)),
                                                ),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: !_compact
                                                        ? Theme.of(context)
                                                            .backgroundColor
                                                        : Colors.grey
                                                            .withOpacity(0.4)),
                                                color: !_compact
                                                    ? Theme.of(context)
                                                        .backgroundColor
                                                    : Theme.of(context)
                                                        .canvasColor,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    buildProfileButton()
                                  ],
                                ));
                            if (stuckAmount > 0.0 && _profileUser != null)
                              button = Container(
                                  height: 68.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 0.0),
                                  child: Center(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Icon(
                                            FluentIcons.chevron_left_24_filled,
                                            size: 26,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Center(
                                          child: CircleAvatar(
                                            maxRadius: 24,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    _profileUser?.avatarUrl ??
                                                        Strings.emptyAvatarUrl),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8),
                                                      child: Text(
                                                        profileName,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 19),
                                                      ),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Expanded(
                                                    child: MKDropDownMenu(
                                                      controller: mKController,
                                                      menuBuilder: () {
                                                        return Container(
                                                          child: Material(
                                                            child: Column(
                                                              children: [
                                                                sortTab(Sort
                                                                    .Recent),
                                                                Divider(
                                                                  indent: 10,
                                                                  endIndent: 10,
                                                                  thickness: 1,
                                                                  height: 1,
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.4),
                                                                ),
                                                                sortTab(
                                                                    Sort.Best),
                                                                Divider(
                                                                  indent: 10,
                                                                  endIndent: 10,
                                                                  thickness: 1,
                                                                  height: 1,
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.4),
                                                                ),
                                                                sortTab(Sort
                                                                    .Oldest),
                                                              ],
                                                            ),
                                                          ),
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                        );
                                                      },
                                                      menuMargin: 10,
                                                      headerBuilder: (b) {
                                                        if (true) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 0),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  b
                                                                      ? FluentIcons
                                                                          .chevron_up_12_filled
                                                                      : FluentIcons
                                                                          .chevron_down_12_filled,
                                                                  size: 16,
                                                                ),
                                                                Text(
                                                                  sort
                                                                      .toString()
                                                                      .substring(
                                                                          5),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800),
                                                                )
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  buildProfileButton()
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                            return AnimatedSwitcher(
                                duration: Duration(milliseconds: 100),
                                reverseDuration: Duration(milliseconds: 100),
                                child: button);
                          },
                          content: Container(
                              // decoration: BoxDecoration(
                              //   borderRadius: BorderRadius.circular(10),
                              //   border: Border.all(
                              //       width: 1,
                              //       color: Theme.of(context).cardColor),
                              //   color: Theme.of(context).backgroundColor,
                              // ),
                              // height: 36,
                              // margin: EdgeInsets.only(
                              //     left: 10, right: 10, bottom: 6, top: 4),
                              child: Container()
                              // Row(
                              //   children: [
                              //     sortTab(Sort.Recent),
                              //     Container(
                              //       width: 2,
                              //       height: 32,
                              //       color: Theme.of(context).cardColor,
                              //     ),
                              //     sortTab(Sort.Best),
                              //     Container(
                              //       width: 2,
                              //       height: 32,
                              //       color: Theme.of(context).cardColor,
                              //     ),
                              //     sortTab(Sort.Oldest),
                              //   ],
                              // )
                              )),
                    ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).cardColor,
                  ),
                  Expanded(
                      child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 100),
                    itemCount: posts.length + 1,
                    itemBuilder: (context, i) {
                      if (i == posts.length) {
                        return !loaded
                            ? Container(child: circularProgress())
                            : empty
                                ? Container(
                                    height: 400,
                                    child: emptyState(
                                        context, 'Nothing Here!', 'none'))
                                : Container();
                      }
                      return posts[i];
                    },
                  ))
                ],
              ),
            )),
      ),
    );
  }
}
