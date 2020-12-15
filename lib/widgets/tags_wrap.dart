import 'dart:collection';
import 'dart:convert';

import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/screens/tag_screen.dart';
import 'package:blue/widgets/progress.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sortedmap/sortedmap.dart';

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
  void initState() {
    getFollowedTags();
    wrapped = preferences.getBool('isWrapped');
    if (wrapped == null) {
      wrapped = true;
      preferences.setBool('isWrapped', true);
    }
    super.initState();
  }

  getFollowedTags() async {
    DocumentSnapshot tagsDoc = await followedTagsRef.doc(currentUser.id).get();
   
    if(tagsDoc.data() != null)
    tags = tagsDoc.data().keys.toList();
    else
    tags = [];
    var priorityInfo = await openedTagsRef.doc(currentUser.id).get();
     SortedMap priorityMap = new SortedMap(Ordering.byValue());
    if(  priorityInfo.data() != null){
    priorityInfo.data().forEach((key, value) {
      value.forEach((k, v) {
         if(tags.contains(k)){
        if (priorityMap[k] == null) {
          priorityMap[k] = 1;
        } else {
          priorityMap[k] = priorityMap[k] + 1;
        }

        }
      });
    });}
 
    List sortedPriorityList = priorityMap.keys.toList();
    setState(() {
      tagLoading = false;

      for (int i = 0; i < sortedPriorityList.length; i++) {
        tagChips.add(InkWell(
          onTap: () async {
              Navigator.of(context).pushNamed(
                                  TagScreen.routeName,
                                  arguments: sortedPriorityList[i]);
              String tagOpenInfo = preferences.getString('tags_open_info');
                                if(tagOpenInfo == null){
                                preferences.setString('tags_open_info', json.encode( {}));
                                tagOpenInfo =  json.encode( {}); }
                                Map tagOpenMap = json.decode(tagOpenInfo);
                                if(tagOpenMap.containsKey(sortedPriorityList[i]))
                                tagOpenMap[sortedPriorityList[i]] =  tagOpenMap[sortedPriorityList[i]]+1;
                                else
                                tagOpenMap[sortedPriorityList[i]] = 1;
                                preferences.setString('tags_open_info', json.encode( tagOpenMap));
          },
          child: Chip(
            padding: EdgeInsets.all(12),
            label: Text(
             sortedPriorityList[i],
              style: TextStyle(
                  color: Theme.of(context).iconTheme.color, fontSize: 18),
            ),
            backgroundColor: Theme.of(context).cardColor,
          ),
        ));

        tagListTiles.add(InkWell(
          onTap: () async {
            DateTime timeNow = DateTime.now();
            int year = timeNow.year;
            int month = timeNow.month;
            int day = timeNow.day;
            Navigator.of(context)
                .pushNamed(TagScreen.routeName, arguments: sortedPriorityList[i]);
            DocumentSnapshot _doc =
                await openedTagsRef.doc(currentUser.id).get();
            if (_doc.data() == null) {
              openedTagsRef.doc(currentUser.id).set(
                {
                  DateTime.parse("$year-$month-$day").toIso8601String(): {
                    sortedPriorityList[i]: 1
                  }
                },
              );
            } else if (_doc.data()[
                    DateTime.parse("$year-$month-$day").toIso8601String()] ==
                null) {
              openedTagsRef.doc(currentUser.id).set(
                {
                  DateTime.parse("$year-$month-$day").toIso8601String(): {
                    sortedPriorityList[i]: 1
                  }
                },
              );
            } else if (_doc.data()[DateTime.parse("$year-$month-$day")
                    .toIso8601String()][sortedPriorityList[i]] ==
                null) {
              openedTagsRef.doc(currentUser.id).set({
                DateTime.parse("$year-$month-$day").toIso8601String(): {
                  sortedPriorityList[i]: 1
                },
              }, SetOptions(merge: true));
            } else {
              openedTagsRef.doc(currentUser.id).set({
                DateTime.parse("$year-$month-$day").toIso8601String(): {
                  sortedPriorityList[i]: _doc.data()[DateTime.parse("$year-$month-$day")
                          .toIso8601String()][sortedPriorityList[i]] +
                      1
                }
              }, SetOptions(merge: true));
            }
          },
          child: Container(
            alignment: Alignment.center,
            height: 50,
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            padding: EdgeInsets.all(12),
            child: Text(
             sortedPriorityList[i],
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
    if (preferences == null)
      preferences = await SharedPreferences.getInstance();
    preferences.setStringList('followed_tags', tags);
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
                    preferences.setBool('tagsWrapped', wrapped);
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
}
