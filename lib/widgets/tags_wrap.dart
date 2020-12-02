import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/screens/tag_screen.dart';
import 'package:blue/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class TagsWrap extends StatefulWidget {
  @override
  _TagsWrapState createState() => _TagsWrapState();
}
class _TagsWrapState extends State<TagsWrap> {
  List<String> tags = [];
  List<Widget> tagChips = [];
  bool tagLoading = true;

  @override
  void initState() {
    getFollowedTags();
    super.initState();
  }

  getFollowedTags() async {
    var tagsDoc = await followedTagsRef.document(currentUser.id).get();
    List<String> followedTags = [];
    setState(() {
      tagLoading = false;
      tags = tagsDoc.data.keys.toList();
      for (int i = 0; i < tags.length; i++) {
        followedTags.add(tags[i]);
        tagChips.add(InkWell(
          onTap: () {
            Navigator.of(context)
                .pushNamed(TagScreen.routeName, arguments: tags[i]);
          },
          child: Chip(
            padding: EdgeInsets.all(12),
            label: Text(
              tags[i],
              style: TextStyle(
                  color: Theme.of(context).iconTheme.color, fontSize: 18),
            ),
            backgroundColor: Theme.of(context).cardColor,
          ),
        ));
      }
    });
    if (preferences == null)
      preferences = await SharedPreferences.getInstance();
    preferences.setStringList('followed_tags', followedTags);
  }

  @override
  Widget build(BuildContext context) {
    return tagLoading
        ? circularProgress()
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 12,
                children: tagChips,
              ),
            ),
          );
  }
}
