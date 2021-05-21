// Flutter imports:
import 'package:blue/widgets/comment.dart';
import 'package:blue/widgets/comment_reply.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommentNotifier extends ChangeNotifier {
  Map<String, dynamic> _commentState;

  Map<String, dynamic> get commentState {
    return _commentState;
  }

  FocusNode focusNode = new FocusNode();

  CommentNotifier() {
    _commentState = {'type': 'comment'};
    notifyListeners();
  }

  Map<int, List<CommentReply>> _userCommentReplies;

  Map<int, List<CommentReply>> get userCommentReplies {
    print(_userCommentReplies);
    return _userCommentReplies;
  }

  addCommentReply(int commentId, CommentReply reply) {
    if (_userCommentReplies == null) {
      _userCommentReplies = {};
      _userCommentReplies[commentId] = [];
    }
    if (_userCommentReplies[commentId] == null) {
      _userCommentReplies[commentId] = [];
    }

    _userCommentReplies[commentId].add(reply);
    print('reply key:');
    print(_userCommentReplies[commentId].length);
    notifyListeners();
  }

  changeCommentType(var value, {bool focus}) {
    _commentState = value;
    notifyListeners();
    if (focus == true) {
      focusNode.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show');
    }
  }
}
