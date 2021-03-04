// Flutter imports:
import 'package:blue/services/hasura.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';

class AllSavedPostsScreen extends StatefulWidget {
  static const routeName  = 'all-saved-posts';
  @override
  _AllSavedPostsScreenState createState() => _AllSavedPostsScreenState();
}

class _AllSavedPostsScreenState extends State<AllSavedPostsScreen> {
 bool loaded = false;

  List<dynamic> posts = [];
  List<dynamic> postDocSnapshots = [];
  DocumentSnapshot lastDocument;
  int offset = 0;
  ScrollController _controller = ScrollController();

  getAllSavedPosts() async {
  dynamic _data =await  Hasura.getSavedPosts(offset);
    offset = offset + _data.length;
   if(_data.length < 8){
     setState(() {
       loaded =  true;
     });
   }
    setState(() {
      posts = posts +
          _data.map((doc) => Post.fromDocument(doc['post'])).toList();
    });
  }
  
  @override
  void didChangeDependencies() {
    getAllSavedPosts();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          !loaded) {
    
          getAllSavedPosts();
      }
    });


    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        title: Text('All Saved'),
        centerTitle: true,
        elevation: 1,
        leadingButton: CupertinoNavigationBarBackButton(color: Colors.blue),
      ),
      body:Container(
        color: Theme.of(context).backgroundColor,
        child: ListView.builder(controller: _controller,
        itemBuilder: (context,i){
          if(i ==  posts.length && !loaded){
            return circularProgress();
          }
          return posts[i];
        },
itemCount: loaded? posts.length:posts.length+1,
         
        )
    ));
  }
}
