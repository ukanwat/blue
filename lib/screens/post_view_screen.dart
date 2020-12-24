// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../widgets/post.dart';
import '../widgets/progress.dart';
import './home.dart';

class PostViewScreen extends StatelessWidget { final String userId;
  final String postId;

  PostViewScreen(
    {this.userId,
     this.postId});
  
  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef
          .doc(userId)
          .collection('userPosts')
          .doc(postId)
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
