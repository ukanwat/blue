import 'package:blue/screens/tag_screen.dart';
import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blue/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class AllTopicsScreen extends StatefulWidget {
  static const routeName = 'all-topics';
  @override
  _AllTopicsScreenState createState() => _AllTopicsScreenState();
}

class _AllTopicsScreenState extends State<AllTopicsScreen> {

  List<String> tags = [];
  List<Widget> tagChips = [];
  bool tagLoading = true;
  bool topicLoading = true;
  double screenWidth;
  @override
  void didChangeDependencies() {
    getFollowedTags();
    super.didChangeDependencies();
  }

 

  getFollowedTags() async {
    screenWidth = MediaQuery.of(context).size.width;
    var tagsDoc = await followedTagsRef.doc(currentUser.id).get();
    List<String> followedTags = [];
    setState(() {
      tagLoading = false;
      tags = tagsDoc.data().keys.toList();
      for (int i = 0; i < tags.length; i++) {
        followedTags.add(tags[i]);
        tagChips.add(InkWell(
          onTap: () {
            Navigator.of(context)
                .pushNamed(TagScreen.routeName, arguments: tags[i]);
          },
          child: Chip(
            label: Text(
              tags[i],
              style: TextStyle(color: Theme.of(context).iconTheme.color),
            ),
            backgroundColor: Theme.of(context).cardColor,
          ),
        ));
      }
    });
    if(preferences == null)
 preferences = await SharedPreferences.getInstance();
    preferences.setStringList('followed_tags', followedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: header(
          context,
          title: Text(
            'Tags you Follow',
            style: TextStyle(),
          ),
          leadingButton: CupertinoNavigationBarBackButton(color: Colors.blue),
        ),
        body: tagLoading == false && topicLoading == false
            ? Column(
                children: <Widget>[
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      runSpacing: 6,
                      spacing: 6,
                      children: tagChips,
                      alignment: WrapAlignment.start,
                    ),
                  ),
                ],
              )
            : circularProgress());
  }
}
