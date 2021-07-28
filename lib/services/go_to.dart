// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/screens/comments_screen.dart';
import 'package:blue/screens/post_view_screen.dart';
import 'package:blue/screens/profile_screen.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/post.dart';

class GoTo {
  profileScreen(BuildContext context, int profileId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          profileId: profileId,
        ),
      ),
    );
  }

  showPost(
    BuildContext context,
    int postId,
  ) async {
    dynamic doc = await Hasura.getPost(postId);
    Navigator.pushNamed(context, CommentsScreen.routeName,
        arguments: {'post': Post.fromDocument(doc)});
  }
}
