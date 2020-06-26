import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../home.dart';

class TagRecentScreen extends StatefulWidget {
  final String tag;
  TagRecentScreen(this.tag);
  @override
  _TagRecentScreenState createState() => _TagRecentScreenState();
}

class _TagRecentScreenState extends State<TagRecentScreen> {
 List<Widget> posts = [];
 @override
  void didChangeDependencies() {
     getPopular();
    super.didChangeDependencies();
  }
    getPopular() async {
    QuerySnapshot snapshot =
     await topicPostsCollectionGroupRef
     .where("tags", arrayContains: widget.tag).
       getDocuments();
    setState(() {
      this.posts =  snapshot.documents.map((doc) => Post.fromDocument(doc)).toList() ;
    });
  }
    buildRecent() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        height: 400,

      );
    } else {
      return ListView.builder(
      padding: EdgeInsets.all(0),
        itemBuilder: (_,i){
          return posts[i];
        },
        itemCount: posts.length,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return 
        Container(
        
              child: buildRecent()
            
    
          
        );
  }
}