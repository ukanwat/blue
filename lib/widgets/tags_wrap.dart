// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:blue/services/hasura.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:sortedmap/sortedmap.dart';

// Project imports:
import 'package:blue/screens/tag_screen.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/progress.dart';

class TagsWrap extends StatefulWidget {
  @override
  _TagsWrapState createState() => _TagsWrapState();
}

class _TagsWrapState extends State<TagsWrap> {
  List<dynamic> tags = [];

  List<Widget> tagListTiles = [];
  bool tagLoading = true;
  @override
  void didChangeDependencies() {
    getFollowedTags();

    super.didChangeDependencies();
  }

  getFollowedTags() async {
    tags = PreferencesUpdate().getStringList('followed_tags');

    bool b = tags == null;
    if (!b) {
      b = tags.length == 0;
    } else {
      tags = [];
    }
    if (b) {
      dynamic tagsData = await Hasura.getFollowedTags();
      tagsData.forEach((tag) {
        tags.add({
          'tag': tag['tag']['tag'],
          'label': tag['tag']['label'],
          'tag_id': tag['tag']['tag_id'],
          'image_url': tag['tag']['image_id'],
          'follower_count': tag['tag']['follower_count'],
          'post_count': tag['tag']['post_count'],
        });
      });
      PreferencesUpdate().setStringList('followed_tags', tags);
    }

    setState(() {
      tagLoading = false;

      for (int i = 0; i < tags.length; i++) {
        tagListTiles.add(InkWell(
          onTap: () async {
            Navigator.of(context)
                .pushNamed(TagScreen.routeName, arguments: tags[i]);
          },
          child: Container(
            alignment: Alignment.center,
            height: 50,
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            padding: EdgeInsets.all(12),
            child: Text(
              tags[i]['tag'],
              style: TextStyle(
                  color: Theme.of(context).iconTheme.color, fontSize: 18),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            tagLoading
                ? circularProgress()
                : tagListTiles.length == 0
                    ? Container()
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: tagListTiles,
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
