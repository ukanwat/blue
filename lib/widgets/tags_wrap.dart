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
  List<String> tags = [];
  List<Widget> tagChips = [];
  bool wrapped = true;

  List<Widget> tagListTiles = [];
  bool tagLoading = true;
  @override
  void didChangeDependencies() {
    getFollowedTags();
    wrapped = PreferencesUpdate().getBool('isWrapped');
    if (wrapped == null) {
      wrapped = true;
    PreferencesUpdate().updateBool('isWrapped', true);
    }
    super.didChangeDependencies();
  }

 
  getFollowedTags() async {
    tags =  PreferencesUpdate().getStringList('followed_tags');
    if(tags.length == 0 || tags == null) {
     dynamic tagsData =  await Hasura.getFollowedTags();
     print(tagsData);
     tagsData.forEach((tag) { 
       tags.add(tag['label']);
     });
  
       
    }

    setState(() {
      tagLoading = false;

      for (int i = 0; i < tags.length; i++) {
        tagChips.add(InkWell(
          onTap: () async {
            Navigator.of(context).pushNamed(TagScreen.routeName,
                arguments: tags[i]);
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

        tagListTiles.add(InkWell(
          onTap: () async {
        Navigator.of(context).pushNamed(TagScreen.routeName,
                arguments: tags[i]);
            tagsInfoUpdate(tags, i);
          },
          child: Container(
            alignment: Alignment.center,
            height: 50,
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            padding: EdgeInsets.all(12),
            child: Text(
              tags[i],
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
  PreferencesUpdate().updateStringList('followed_tags', tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Text('Tags you Follow',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17)),
            ),
            Expanded(
              child: Container(),
            ),
            IconButton(
                icon: Icon(
                    wrapped
                        ? FluentIcons.grid_kanban_20_regular
                        : FluentIcons.row_triple_24_regular,
                    size: 28,
                    color: Theme.of(context).iconTheme.color),
                onPressed: () {
                  setState(() {
                    wrapped = !wrapped;
              PreferencesUpdate().updateBool('tagsWrapped', wrapped);
                  });
                }),
            IconButton(
                icon: Icon(Icons.keyboard_arrow_down,
                    size: 28, color: Theme.of(context).iconTheme.color),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        ),
        Expanded(
            child: tagLoading
                ? circularProgress()
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: SingleChildScrollView(
                      child: !wrapped
                          ? Column(
                              children: tagListTiles,
                            )
                          : Wrap(
                              spacing: 10,
                              runSpacing: 12,
                              children: wrapped ? tagChips : tagListTiles,
                            ),
                    ),
                  )),
      ],
    );
  }
tagsInfoUpdate(List sortedPriorityList,int i){
 String tagOpenInfo = PreferencesUpdate().getString('tags_open_info');
            if (tagOpenInfo == null) {
         PreferencesUpdate().updateString('tags_open_info', json.encode({}));
              tagOpenInfo = json.encode({});
            }
            DateTime nowTime = DateTime.now();
            String todayTime = DateTime.parse(
                "${nowTime.year}-${nowTime.month}-${nowTime.day}").toString();
            Map tagOpenMap = json.decode(tagOpenInfo);
            if (tagOpenMap.containsKey(todayTime)) {
              if (tagOpenMap[todayTime].containsKey(sortedPriorityList[i]))
                tagOpenMap[todayTime][sortedPriorityList[i]] =
                    tagOpenMap[todayTime][sortedPriorityList[i]] + 1;
              else
                tagOpenMap[todayTime][sortedPriorityList[i]] = 1;
            } else {
              tagOpenMap[todayTime] = {
                sortedPriorityList[i]: 1
              };
            }
            print(tagOpenMap);
           PreferencesUpdate().updateString('tags_open_info', json.encode(tagOpenMap));
}
}
