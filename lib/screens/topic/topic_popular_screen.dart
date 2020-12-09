import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../home.dart';

class TopicPopularScreen extends StatefulWidget {
  final String topicId;
  TopicPopularScreen(this.topicId);
  @override
  _TopicPopularScreenState createState() => _TopicPopularScreenState();
}

class _TopicPopularScreenState extends State<TopicPopularScreen> {
 List<Widget> posts = [

 ];
  @override
  void initState() {
    getPopular();
    super.initState();
  }
    getPopular() async {
    QuerySnapshot snapshot =
     await postsRef
        .
       get();
   
        
    setState(() {
      this.posts =  snapshot.docs.map((doc) => Post.fromDocument(doc)).toList() ;
    });
  }
    buildPopular() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        height: 0,
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
        
              child: buildPopular()
            
    
          
        );
  }
}