import 'package:blue/screens/tag_screen.dart';
import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/topic_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blue/main.dart';

import 'home.dart';

class AllTopicsScreen extends StatefulWidget {
  static const routeName = 'all-topics';
  @override
  _AllTopicsScreenState createState() => _AllTopicsScreenState();
}

class _AllTopicsScreenState extends State<AllTopicsScreen> {
  List<TopicCard> topics = [];
  List<String> tags = [];
  List<Widget> tagChips = [];
  bool tagLoading = true;
  bool topicLoading = true;
  double screenWidth;
  @override
  void didChangeDependencies() {
    getAllTopics();
    getFollowedTags();
    super.didChangeDependencies();
  }

  getAllTopics() async {
    screenWidth = MediaQuery.of(context).size.width;
    QuerySnapshot snapshot = await topicsRef.getDocuments();
    print(snapshot);
    setState(() {
      topicLoading = false;
      snapshot.documents.forEach((doc) {
        print(doc.data);
        topics.add(
          TopicCard(doc['name'], doc['imageUrl'], doc['id'], doc['info'],
              (screenWidth - 16) / 3),
        );
      });
    });
  }

  getFollowedTags() async {
    screenWidth = MediaQuery.of(context).size.width;
    var tagsDoc = await followedTagsRef.document(currentUser.id).get();
    setState(() {
      tagLoading = false;
      tags = tagsDoc.data.keys.toList();
      for (int i = 0; i < tags.length; i++) {
        tagChips.add(InkWell(
           onTap: () {
                              Navigator.of(context).pushNamed(TagScreen.routeName,
                                  arguments: tags[i]);
                            },
                  child: Chip(
            label: Text(tags[i], style: TextStyle(
              color: Theme.of(context).iconTheme.color
            ),),
            backgroundColor: Theme.of(context).cardColor,
          ),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
        appBar: header(
          context,
          title: Text(
            'Topics & Tags',
            style: TextStyle(),
          ),
          leadingButton: CupertinoNavigationBarBackButton(
              color: Colors.blue),
        ),
        body: tagLoading == false && topicLoading == false
            ? Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      top: 5,
                      left: 5,
                      right: 5,
                    ),
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: topics,
                      shrinkWrap: true,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      addAutomaticKeepAlives: true,
                    ),
                  ),
                  Padding(
                    child: Text('Tags you Follow',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                    ),
                    ),
                     padding: const EdgeInsets.only(
                    top: 10
                     ),
                  ),
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