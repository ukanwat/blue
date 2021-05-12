import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/post.dart';
import '../services/boxes.dart';
import 'hasura.dart';

class PostFunctions {
  handleUpvoteButton(int postId, Vote vote) async {
    print('vote:$vote');
    if (vote == Vote.up) {
      await Hasura.deletePostVote(postId);
    } else if (vote == Vote.down) {
      await Hasura.updatePostVote(postId, true);
    } else {
      await Hasura.insertPostVote(postId, true);
    }

    return;
  }

  handleDownvoteButton(int postId, Vote vote) async {
    if (vote == Vote.down) {
      await Hasura.deletePostVote(postId);
    } else if (vote == Vote.up) {
      await Hasura.updatePostVote(postId, false);
    } else {
      await Hasura.insertPostVote(postId, false);
    }

    return;
  }
}
