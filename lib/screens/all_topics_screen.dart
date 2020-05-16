import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/topic_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class AllTopicsScreen extends StatefulWidget {
  static const routeName = 'all-topics';
  @override
  _AllTopicsScreenState createState() => _AllTopicsScreenState();
}

class _AllTopicsScreenState extends State<AllTopicsScreen> {
  List<TopicCard> topics = [];
  bool loading;
  double screenWidth;
  @override
  void didChangeDependencies() {
    getAllTopics();
    super.didChangeDependencies();
  }

  getAllTopics() async {
    screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      loading = true;
    });
    QuerySnapshot snapshot = await topicsRef.getDocuments();
    print(snapshot);
    setState(() {
      loading = false;
      snapshot.documents.forEach((doc) {
        topics.add(
          TopicCard(doc['name'], doc['imageUrl'], doc['id'], doc['info'],
              (screenWidth - 16) / 3),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        title: Text(
          'All Topics',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        leadingButton: CupertinoNavigationBarBackButton(
          color: Theme.of(context).primaryColor
        ),
        actionButton: IconButton(
          icon: Icon(Icons.more_vert,
          color: Theme.of(context).primaryColor,),
          onPressed: null,
        ),
      ),
      body: 
      loading? circularProgress():
      Container(
      padding:  EdgeInsets.only(top: 5,
      left: 5,
      right: 5,
      
      ),
              child: GridView.count(
          crossAxisCount: 3,
          children: topics,
          shrinkWrap: true,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,

          addAutomaticKeepAlives: true,
        ),
      ),
    );
  }
}
