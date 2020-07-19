import 'package:blue/screens/topic/topic_popular_screen.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blue/main.dart';
import 'home.dart';

class CategoryPostsScreen extends StatefulWidget {
  final String name;
  CategoryPostsScreen(this.name);
  @override
  _CategoryPostsScreenState createState() => _CategoryPostsScreenState();
}

class _CategoryPostsScreenState extends State<CategoryPostsScreen> with AutomaticKeepAliveClientMixin<CategoryPostsScreen> {
  List<Post> posts = [];
  bool loading = true; 
   @override
  void initState() {
    super.initState();
    getPosts();
  }

  getPosts() async {
    print(currentUser);
    QuerySnapshot snapshot = await postsRef
    .where('topicName',isEqualTo: widget.name)
        .getDocuments(); 
  
    setState(() {
      posts =  snapshot.documents.map((doc) => Post.fromDocument(doc,isCompact: true,)).toList();
         loading = false;
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return loading? circularProgress():ListView(children: posts);
    
    }
}
