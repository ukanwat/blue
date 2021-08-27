// Flutter imports:
import 'package:blue/widgets/button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Project imports:
import 'package:blue/screens/tag_screen.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/functions.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:flutter_icons/flutter_icons.dart';
import '../constants/app_colors.dart';

class PostsSection extends StatefulWidget {
  final String tag;
  final String sectionLabel;
  PostsSection(this.tag, this.sectionLabel);

  @override
  _PostsSectionState createState() => _PostsSectionState();
}

class _PostsSectionState extends State<PostsSection>
    with AutomaticKeepAliveClientMixin {
  Map tagMap;
  bool isFollowing = false;
  setTag() async {
    tagMap = await Hasura.getTag(widget.tag);
  }

  List<Post> posts = [];
  bool loading = true;
  getPosts() async {
    List<dynamic> data =
        await Hasura.getTagPosts(3, 0, '{score:desc}', tag: widget.tag);
    int i = 0;
    data.forEach((element) {
      i == 2
          ? posts.add(Post.fromDocument(
              element,
              isCompact: true,
              commentsShown: false,
              color: Theme.of(context).canvasColor,
              moreCompact: true,
              radius: 0,
            ))
          : posts.add(Post.fromDocument(
              element,
              isCompact: true,
              commentsShown: false,
              color: Theme.of(context).canvasColor,
              moreCompact: true,
            ));
      i++;
    });
    setState(() {
      loading = false;
    });
  }

  @override
  void didChangeDependencies() {
    List tags = PreferencesUpdate().getStringList('followed_tags');

    tags = PreferencesUpdate().getStringList('followed_tags');

    if (tags != null) {
      setState(() {
        tags.forEach((_tag) {
          if (widget.tag == _tag['tag']) {
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
    super.didChangeDependencies();
  }

  Color clr;
  @override
  void initState() {
    getPosts();
    clr = AppColors().rndColor;
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Colors.transparent,
              Colors.transparent,
            ])),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(TagScreen.routeName, arguments: tagMap);
              },
              child: Container(
                height: 46,
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 8,
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            '${widget.sectionLabel.toUpperCase()}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .iconTheme
                                    .color
                                    .withOpacity(0.5),
                                fontSize: 11,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${widget.tag}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                height: 1,
                                color: clr,
                                fontSize: 24,
                                fontWeight: FontWeight.w800),
                          ),
                        ]),
                    SizedBox(
                      width: 8,
                    ),
                    isFollowing
                        ? Container()
                        : ActionButton(() async {
                            setState(() {
                              PreferencesUpdate().addToList(
                                'followed_tags',
                                tagMap,
                              );
                            });
                            Hasura.followTag(tagMap['tag_id']);
                            setState(() {
                              isFollowing = true;
                            });
                          }, AppColors.blue, 'Follow', true),
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                      height: 32,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                'MORE',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color
                                        .withOpacity(0.5),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              FluentIcons.arrow_circle_right_24_filled,
                              color: clr,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!loading)
              Card(
                margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    children: posts,
                  ),
                ),
              )
            // CarouselSlider(
            //     items: posts
            //         .map(
            //           (e) => Container(
            //             margin:
            //                 EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            //             decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(10)),
            //             child: Center(child: e),
            //           ),
            //         )
            //         .toList(),
            //     options: CarouselOptions(
            //       initialPage: 0,
            //       height: 200,
            //       pageSnapping: true,
            //       enableInfiniteScroll: false,
            //     ))
            // if (!loading)
            //   ...posts
            else
              Container(
                child: Center(
                  child: circularProgress(),
                ),
                height: 190,
              ),
          ],
        ));
  }
}
