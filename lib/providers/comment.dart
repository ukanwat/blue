// Flutter imports:
import 'package:blue/widgets/comment.dart';
import 'package:blue/widgets/comment_reply.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class CommentGet extends GetxController {
  Map<String, dynamic> commentState = {'type': 'comment'};

  FocusNode focusNode = new FocusNode();

  Map<int, List<CommentReply>> userCommentReplies = {};

  addCommentReply(
    int commentId,
    CommentReply reply,
  ) {
    if (userCommentReplies[commentId] == null) {
      userCommentReplies[commentId] = [];
    }

    userCommentReplies[commentId] = userCommentReplies[commentId] + [reply];

    update([commentId]);
  }

  changeCommentType(var value, {bool focus}) {
    commentState = value;
    if (focus == true) {
      focusNode.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show');
    }

    update(['input']);
  }
}
