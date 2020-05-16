import 'package:flutter/material.dart';

import './home.dart';
import '../widgets/progress.dart';
import '../widgets/post.dart';
class PostViewScreen extends StatelessWidget { final String userId;
  final String postId;

  PostViewScreen(
    {this.userId,
     this.postId});
  
  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef
          .document(userId)
          .collection('userPosts')
          .document(postId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
           
            body: SafeArea(
                          child: ListView(
                children: <Widget>[
                  Container(
                    child: post,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  }
