// Dart imports:
import 'dart:math';
import 'dart:ui';
import 'package:blue/constants/app_colors.dart';
// Flutter imports:
import 'package:customizable_space_bar/customizable_space_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_gradients/flutter_gradients.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/tag/tag_popular_screen.dart';
import 'package:blue/screens/tag/tag_recent_screen.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/custom_image.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';

class TagScreen extends StatefulWidget {
  static const routeName = 'tag';
  @override
  _TagScreenState createState() => _TagScreenState();
}

class _TagScreenState extends State<TagScreen> with TickerProviderStateMixin {
  String tag;
  dynamic tagMap;
  bool isFollowing = false;
  String label;
  int followerCount;
  int postCount;
  Gradient gradient;
  setTag() async {
    tagMap = await Hasura.getTag(tag);
  }

  getTag() async {
    dynamic _tagMap = ModalRoute.of(context).settings.arguments;
    if (_tagMap.runtimeType == String) {
      _tagMap = await Hasura.getTag(_tagMap);
    }

    tagMap = _tagMap;

    setState(() {
      tag = tagMap['tag'];
    });
    try {
      getThumbnail();
    } catch (e) {}
    label = tagMap['label'];
    followerCount = tagMap['follower_count'];
    postCount = tagMap['post_count'];
    List tags = PreferencesUpdate().getStringList('followed_tags');

    tags = PreferencesUpdate().getStringList('followed_tags');
    if (tags != null) {
      setState(() {
        tags.forEach((_tag) {
          if (tag == _tag['tag']) {
            isFollowing = true;
            tagMap = _tag;
          }
        });
      });

      if (!isFollowing) {
        setTag();
      }
      PreferencesUpdate().setStringList('followed_tags', tags);
    }
  }

  @override
  void didChangeDependencies() {
    getTag();
    gradient = FlutterGradients.findByName(FlutterGradientNames
        .values[Random().nextInt(FlutterGradientNames.values.length - 2)]);
    super.didChangeDependencies();
  }

  getThumbnail() async {
    dynamic doc = await Hasura.getTagPosts(1, 0, '{created_at:desc}', tag: tag);

    setState(() {
      thumbUrl = doc[0]['thumbnail'];
    });
  }

  TabController controller;

  String thumbUrl;

  List colors = [
    Colors.red,
    Colors.green,
    Colors.yellow,
    AppColors.blue,
    Colors.amber,
    Colors.deepOrange,
    Colors.indigo,
  ];
  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          //  CustomScrollView(
          //     slivers: [
          //       SliverAppBar(
          //         brightness: Brightness.dark,
          //         pinned: true,
          //         leading: IconButton(
          //           onPressed: () {
          //             Navigator.pop(context);
          //           },
          //           icon: Icon(
          //             CupertinoIcons.back,
          //             color: Colors.white,
          //           ),
          //         ),
          //         backgroundColor: Theme.of(context).backgroundColor,
          //         actions: [
          //           isFollowing
          //               ? PopupMenuButton(
          //                   padding: EdgeInsets.zero,
          //                   color: Theme.of(context).canvasColor,
          //                   shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(8),
          //                   ),
          //                   itemBuilder: (_) => [
          //                     PopupMenuItem(
          //                         child: Text('Unfollow'), value: 'Unfollow'),
          //                   ],
          //                   icon: Icon(
          //                     Icons.more_vert,
          //                     color: Colors.white,
          //                   ),
          //                   onSelected: (selectedValue) async {
          //                     if (selectedValue == 'Unfollow') {
          //                       setState(() {
          //                         followerCount = followerCount - 1;
          //                         PreferencesUpdate().removeFromList(
          //                           'followed_tags',
          //                           tagMap,
          //                         );
          //                       });
          //                       Hasura.unfollowTag(tagMap['tag_id']);
          //                       setState(() {
          //                         isFollowing = false;
          //                       });
          //                     }
          //                   },
          //                 )
          //               : IconButton(
          //                   onPressed: () async {
          //                     setState(() {
          //                       PreferencesUpdate().addToList(
          //                         'followed_tags',
          //                         tagMap,
          //                       );
          //                     });

          //                     Hasura.followTag(tagMap['tag_id']);
          //                     setState(() {
          //                       isFollowing = true;
          //                       followerCount++;
          //                     });
          //                   },
          //                   icon: Icon(
          //                     Icons.add,
          //                     size: 34,
          //                     color: Colors.white,
          //                   ),
          //                 )
          //         ],

          //         /// This is the part you use this package
          //         flexibleSpace: CustomizableSpaceBar(
          //           builder: (context, scrollingRate) {
          //             /// Example content
          //             return Stack(
          //               children: [
          //                 Stack(
          //                   children: [
          //                     Center(
          //                       child: Container(
          //                         width: MediaQuery.of(context).size.width,
          //                         height: 160 + MediaQuery.of(context).padding.top,
          //                         child: thumbUrl == null
          //                             ? Container()
          //                             : ImageFiltered(
          //                                 imageFilter: ImageFilter.blur(
          //                                     sigmaX: scrollingRate * 10,
          //                                     sigmaY: scrollingRate * 3),
          //                                 child: CachedNetworkImage(
          //                                   imageUrl: thumbUrl,
          //                                   fit: BoxFit.cover,
          //                                 ),
          //                               ),
          //                         decoration: BoxDecoration(
          //                             gradient: LinearGradient(
          //                                 colors: [
          //                                   Colors.black.withOpacity(0.4),
          //                                   Colors.black.withOpacity(0.4),
          //                                 ],
          //                                 begin: Alignment.topCenter,
          //                                 end: Alignment.bottomCenter),
          //                             color: Colors.transparent,
          //                             borderRadius: BorderRadius.circular(15)),
          //                       ),
          //                     ),
          //                     Visibility(
          //                       visible: scrollingRate < 0.001,
          //                       child: Center(
          //                         child: Column(
          //                           crossAxisAlignment: CrossAxisAlignment.center,
          //                           mainAxisAlignment: MainAxisAlignment.start,
          //                           children: [
          //                             SizedBox(
          //                                 height: MediaQuery.of(context).padding.top),
          //                             Padding(
          //                               padding:
          //                                   const EdgeInsets.symmetric(vertical: 14),
          //                               child: Text(
          //                                 label ?? '',
          //                                 style: TextStyle(
          //                                     color: Colors.white.withOpacity(0.9),
          //                                     fontFamily: 'Stark Sans',
          //                                     fontWeight: FontWeight.w800,
          //                                     fontSize: 20),
          //                               ),
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //                 Padding(
          //                   padding: EdgeInsets.only(
          //                       bottom: 10, left: 12 + 40 * scrollingRate),
          //                   child: Align(
          //                       alignment: Alignment.bottomLeft,
          //                       child: Column(
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         mainAxisSize: MainAxisSize.min,
          //                         children: [
          //                           Visibility(
          //                             visible: scrollingRate < 0.001,
          //                             child: Container(
          //                               height: 45 * (1 - scrollingRate),
          //                               padding: EdgeInsets.only(left: 5),
          //                               child: Row(
          //                                 mainAxisSize: MainAxisSize.min,
          //                                 children: [
          //                                   if (followerCount != null)
          //                                     Row(
          //                                       mainAxisSize: MainAxisSize.min,
          //                                       children: [
          //                                         Text(
          //                                           '$followerCount',
          //                                           style: TextStyle(
          //                                               color: Colors.white,
          //                                               fontSize: 20,
          //                                               fontWeight: FontWeight.w800),
          //                                         ),
          //                                         SizedBox(
          //                                           width: 2,
          //                                         ),
          //                                         Text(
          //                                           'members',
          //                                           style: TextStyle(
          //                                               color: Colors.white,
          //                                               fontWeight: FontWeight.bold),
          //                                         ),
          //                                       ],
          //                                     ),
          //                                   SizedBox(
          //                                     width: 8,
          //                                   ),
          //                                   if (postCount != null)
          //                                     Row(
          //                                         mainAxisSize: MainAxisSize.min,
          //                                         children: [
          //                                           Text(
          //                                             '$postCount',
          //                                             style: TextStyle(
          //                                                 fontSize: 20,
          //                                                 color: Colors.white,
          //                                                 fontWeight:
          //                                                     FontWeight.w800),
          //                                           ),
          //                                           SizedBox(
          //                                             width: 2,
          //                                           ),
          //                                           Text(
          //                                             'posts',
          //                                             style: TextStyle(
          //                                                 color: Colors.white,
          //                                                 fontWeight:
          //                                                     FontWeight.bold),
          //                                           ),
          //                                         ])
          //                                 ],
          //                               ),
          //                             ),
          //                           ),
          //                           ClipRRect(
          //                               borderRadius: BorderRadius.circular(15),
          //                               child: new BackdropFilter(
          //                                 filter: new ImageFilter.blur(
          //                                     sigmaX: 10.0, sigmaY: 10.0),
          //                                 child: Container(
          //                                   padding: EdgeInsets.symmetric(
          //                                       horizontal: 10, vertical: 4),
          //                                   decoration: BoxDecoration(
          //                                       borderRadius:
          //                                           BorderRadius.circular(15),
          //                                       color: Colors.transparent),
          //                                   child: Text('#${tag == null ? '' : tag}',
          //                                       style: TextStyle(
          //                                           fontSize: 42 - 18 * scrollingRate,
          //                                           color: Colors.white,
          //                                           fontWeight: FontWeight.w700)),
          //                                 ),
          //                               )),
          //                         ],
          //                       )),
          //                 ),
          //               ],
          //             );
          //           },
          //         ),

          //         /// End of the part

          //         expandedHeight: 160,
          //       ),
          //       SliverPersistentHeader(
          //         delegate: _SliverAppBarDelegate(
          //           TabBar(
          //             controller: controller,
          //             indicatorColor: Theme.of(context).accentColor,
          //             tabs: [
          //               Tab(
          //                 child: Row(
          //                   children: [
          //                     Icon(FluentIcons.arrow_trending_24_filled),
          //                     Text(
          //                       'Top',
          //                       style: TextStyle(
          //                           fontWeight: FontWeight.bold, fontSize: 18),
          //                     )
          //                   ],
          //                 ),
          //               ),
          //               Tab(
          //                 child: Row(
          //                   children: [
          //                     Icon(FluentIcons.new_24_filled),
          //                     Text(
          //                       'Latest',
          //                       style: TextStyle(
          //                           fontWeight: FontWeight.bold, fontSize: 18),
          //                     )
          //                   ],
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //         pinned: true,
          //       ),
          //       SliverToBoxAdapter(
          //           child: (tag == null)
          //               ? Container(
          //                   height: 100,
          //                   width: MediaQuery.of(context).padding.top,
          //                   child: Center(child: circularProgress()))
          //               : Container(
          //                   padding: EdgeInsets.zero,
          //                   margin: EdgeInsets.zero,
          //                   child:
          //                       TabBarView(controller: controller, children: <Widget>[
          //                     Transform.translate(
          //                         offset: Offset.fromDirection(
          //                             1.57, -MediaQuery.of(context).padding.top),
          //                         child: TagPopularScreen(tag)),
          //                     Transform.translate(
          //                         offset: Offset.fromDirection(
          //                             1.57, -MediaQuery.of(context).padding.top),
          //                         child: TagRecentScreen(tag)),
          //                   ]),
          //                 )),
          //     ],
          //   ),
          // ),
          DefaultTabController(
        length: 2,
        child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  brightness: Brightness.dark,
                  pinned: true,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Theme.of(context).backgroundColor,
                  actions: [
                    isFollowing
                        ? PopupMenuButton(
                            padding: EdgeInsets.zero,
                            color: Theme.of(context).canvasColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                  child: Text('Unfollow'), value: 'Unfollow'),
                            ],
                            icon: Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                            onSelected: (selectedValue) async {
                              if (selectedValue == 'Unfollow') {
                                setState(() {
                                  followerCount = followerCount - 1;
                                  PreferencesUpdate().removeFromList(
                                    'followed_tags',
                                    tagMap,
                                  );
                                });
                                Hasura.unfollowTag(tagMap['tag_id']);
                                setState(() {
                                  isFollowing = false;
                                });
                              }
                            },
                          )
                        : IconButton(
                            onPressed: () async {
                              setState(() {
                                PreferencesUpdate().addToList(
                                  'followed_tags',
                                  tagMap,
                                );
                              });

                              Hasura.followTag(tagMap['tag_id']);
                              setState(() {
                                isFollowing = true;
                                followerCount++;
                              });
                            },
                            icon: Icon(
                              Icons.add,
                              size: 34,
                              color: Colors.white,
                            ),
                          )
                  ],

                  /// This is the part you use this package
                  flexibleSpace: CustomizableSpaceBar(
                    builder: (context, scrollingRate) {
                      /// Example content
                      return Stack(
                        children: [
                          Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      160 + MediaQuery.of(context).padding.top,
                                  child: thumbUrl == null
                                      ? Container()
                                      : ClipRect(
                                          child: ImageFiltered(
                                            imageFilter: ImageFilter.blur(
                                                sigmaX: scrollingRate * 10,
                                                sigmaY: scrollingRate * 3),
                                            child: CachedNetworkImage(
                                              imageUrl: thumbUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withOpacity(0.4),
                                            Colors.black.withOpacity(0.4),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter),
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    160 + MediaQuery.of(context).padding.top,
                                color: Colors.black26,
                              ),
                              Visibility(
                                visible: scrollingRate < 0.001,
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                              .padding
                                              .top),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        child: Text(
                                          label ?? '',
                                          style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              fontFamily: 'Stark Sans',
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: 10, left: 12 + 40 * scrollingRate),
                            child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Visibility(
                                      visible: scrollingRate < 0.001,
                                      child: Container(
                                        height: 45 * (1 - scrollingRate),
                                        padding: EdgeInsets.only(left: 5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (followerCount != null)
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '$followerCount',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                  SizedBox(
                                                    width: 2,
                                                  ),
                                                  Text(
                                                    'Followers',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            if (postCount != null)
                                              Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '$postCount',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      'Posts',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ])
                                          ],
                                        ),
                                      ),
                                    ),
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: new BackdropFilter(
                                          filter: new ImageFilter.blur(
                                              sigmaX: 10.0, sigmaY: 10.0),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.transparent),
                                            child: Text(
                                                '#${tag == null ? '' : tag}',
                                                style: TextStyle(
                                                    fontSize:
                                                        42 - 18 * scrollingRate,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ),
                                        )),
                                  ],
                                )),
                          ),
                        ],
                      );
                    },
                  ),

                  /// End of the part

                  expandedHeight: 160,
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      indicatorColor: Theme.of(context).accentColor,
                      tabs: [
                        Tab(
                          child: Row(
                            children: [
                              Icon(FluentIcons.arrow_trending_24_filled),
                              Text(
                                'Top',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              )
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            children: [
                              Icon(FluentIcons.new_24_filled),
                              Text(
                                'Latest',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: tag == null
                ? Container(
                    height: 100,
                    width: MediaQuery.of(context).padding.top,
                    child: Center(child: circularProgress()))
                : Container(
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    child: TabBarView(children: <Widget>[
                      Transform.translate(
                          offset: Offset.fromDirection(
                              1.57, -MediaQuery.of(context).padding.top),
                          child: TagPopularScreen(tag)),
                      Transform.translate(
                          offset: Offset.fromDirection(
                              1.57, -MediaQuery.of(context).padding.top),
                          child: TagRecentScreen(tag)),
                    ]),
                  )),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Theme.of(context).backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
