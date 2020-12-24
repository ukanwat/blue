import 'package:blue/screens/comments_screen.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/screens/post_view_screen.dart';
import 'package:blue/screens/profile_screen.dart';
import 'package:blue/widgets/post.dart';
import 'package:flutter/material.dart';

class GoTo{
   profileScreen(BuildContext context,String profileId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          profileId: profileId,
        ),
      ),
    );
  }
  showPost(BuildContext context,String postId,) async{
    var doc =  await postsRef.doc(postId).get();
    //TODO if fails show error
  Post post = Post.fromDocument(doc.data(),isCompact: false,commentsShown: true,);
Navigator.pushNamed(context, CommentsScreen.routeName, arguments: post);
}
}
