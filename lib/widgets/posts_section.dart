import 'package:blue/screens/tag_screen.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/functions.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
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
    data.forEach((element) {
      posts.add(Post.fromDocument(element,
          isCompact: true,
          commentsShown: false,
          color: Theme.of(context).canvasColor));
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
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Theme.of(context).canvasColor,
        elevation: 0.5,
        margin: EdgeInsets.symmetric(vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 45,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          Text(
                            '#${widget.tag}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                color: clr,
                                fontSize: 26,
                                fontWeight: FontWeight.w800),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 19,
                              ),
                              Text(
                                '${widget.sectionLabel}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color
                                        .withOpacity(0.5),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  isFollowing
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () async {
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
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(width: 3, color: Colors.blue)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 4),
                                child: Text(
                                  'Follow',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontFamily: 'Stark Sans',
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                        )
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
            if (!loading)
              ...posts
            else
              Container(
                child: Center(
                  child: circularProgress(),
                ),
                height: 435,
              ),
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(TagScreen.routeName, arguments: tagMap);
              },
              child: Container(
                height: 32,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'MORE FROM',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .iconTheme
                                  .color
                                  .withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Center(
                        child: Text(
                          widget.tag,
                          style: TextStyle(
                              color: clr,
                              fontSize: 17,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(FluentIcons.arrow_circle_right_24_regular),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
