// Project imports:
import 'package:blue/main.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/post.dart';
import '../services/boxes.dart';
import 'hasura.dart';

class PostFunctions {
  handleUpvoteButton(int postId, Vote vote, bool actionExists) async {
    if (!actionExists) {
      Hasura.insertPostAction(postId, 'up:${_boolVote(vote, true)}');
    } else {
      Hasura.updatePostAction(postId, 'up:${_boolVote(vote, true)}');
    }
    return;
  }

  _boolVote(Vote v, bool up) {
    if (v == Vote.none) {
      if (up) {
        return true;
      } else {
        return false;
      }
    } else if (v == Vote.up) {
      return up ? null : false;
    } else if (v == Vote.down) {
      return up ? true : null;
    }
  }

  handleDownvoteButton(int postId, Vote vote, bool actionExists) async {
    if (!actionExists) {
      Hasura.insertPostAction(postId, 'up:${_boolVote(vote, false)}');
    } else {
      Hasura.updatePostAction(postId, 'up:${_boolVote(vote, false)}');
    }
  }
}
