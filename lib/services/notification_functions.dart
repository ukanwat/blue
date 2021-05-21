import 'package:blue/screens/comments_screen.dart';
import 'package:blue/services/go_to.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/comment.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:flutter/material.dart';

class NotifFunctions {
  static goToComment(int commentId, BuildContext context) async {
    dynamic doc;
    try {
      doc = await Hasura.getCommentWithPost(commentId);
    } catch (e) {
      snackbar('comment was deleted', context, color: Colors.red);
      return;
    }
    Navigator.pushNamed(context, CommentsScreen.routeName, arguments: {
      'post': Post.fromDocument(doc['post']),
      'comment':
          Comment.fromDocument(doc, doc['post']['post_id'], doc['comment_id'])
    });
  }

  static goToPost(int postId, BuildContext context) async {
    dynamic doc = await Hasura.getPost(postId);
    Navigator.pushNamed(context, CommentsScreen.routeName,
        arguments: {'post': Post.fromDocument(doc)});
  }

  static goToCommentReply(int commentReplyId, BuildContext context) async {
    dynamic doc;
    try {
      doc = await Hasura.getReplyCommentWithPost(commentReplyId);
    } catch (e) {
      snackbar('comment Reply was deleted', context, color: Colors.red);
      return;
    }

    List l = doc['comment_replies'];
    l.forEach((element) {
      if (element['reply_id'] == commentReplyId) {
        l.remove(element);
        l.insert(0, element);
      }
    });
    doc['comment_replies'] = l;
    Navigator.pushNamed(context, CommentsScreen.routeName, arguments: {
      'post': Post.fromDocument(doc['post']),
      'comment':
          Comment.fromDocument(doc, doc['post']['post_id'], doc['comment_id'])
    });
  }

  static goToProfile(int profileId, BuildContext context) async {
    GoTo().profileScreen(context, profileId);
  }
}
