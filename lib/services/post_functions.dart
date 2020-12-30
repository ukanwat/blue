import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostFunctions{
 handleUpvoteButton(String postId,Vote vote) async {
    if(vote == Vote.none){
     postsRef.doc(postId).update({
       'upvotes': FieldValue.increment(1),
       'votes': FieldValue.increment(1),
     });
    }else if(vote == Vote.up){
 postsRef.doc(postId).update({
       'upvotes': FieldValue.increment(-1),
       'votes': FieldValue.increment(-1),
     });
    }else{
       postsRef.doc(postId).update({
       'upvotes': FieldValue.increment(2),
       'votes': FieldValue.increment(2),
     });
    }

   if(vote == Vote.up){
    return;
   }

  
   
    
    if (PreferencesUpdate().getBool('votes_downloaded') == null ||
        PreferencesUpdate().getBool('votes_downloaded') == false) {
      QuerySnapshot query = await postsVotersRef
          .doc(currentUser.id)
          .collection('userVotes')
          .where('ids', arrayContains: postId)
          .limit(1)
          .get();
      List<String> ids = query.docs.first.data()['ids'];
      List<bool> votes = query.docs.first.data()['votes'];
      int index = ids.indexOf(postId);
      if (!votes[index]) {
        votes[index] = true;
        await postsVotersRef
            .doc(currentUser.id)
            .collection('userVotes')
            .doc(query.docs.first.id)
            .set({'votes': votes}, SetOptions(merge: true));
      }
    } else if (PreferencesUpdate().getBool('votes_downloaded')) {
       var _vote = voteBox.get(postId);
      if (_vote == null ? true : !_vote) {
        voteBox.put(postId, true);
      }
    }
  }
   handleDownvoteButton(String postId,Vote vote) async {
      if(vote == Vote.none){
     postsRef.doc(postId).update({
       'upvotes': FieldValue.increment(-1),
       'votes': FieldValue.increment(-1),
     });
    }else if(vote == Vote.down){
 postsRef.doc(postId).update({
       'upvotes': FieldValue.increment(1),
       'votes': FieldValue.increment(1),
     });
    }else{
       postsRef.doc(postId).update({
       'upvotes': FieldValue.increment(-2),
       'votes': FieldValue.increment(-2),
     });
    }
   if(vote == Vote.down){
    
    return;
   
   }
    if (PreferencesUpdate().getBool('votes_downloaded') == null ||
        PreferencesUpdate().getBool('votes_downloaded') == false) {
      QuerySnapshot query = await postsVotersRef
          .doc(currentUser.id)
          .collection('userVotes')
          .where('ids', arrayContains: postId)
          .limit(1)
          .get();
      List<String> ids = query.docs.first.data()['ids'];
      List<bool> votes = query.docs.first.data()['votes'];
      int index = ids.indexOf(postId);
      if (votes[index]) {
        votes[index] = false;
        await postsVotersRef
            .doc(currentUser.id)
            .collection('userVotes')
            .doc(query.docs.first.id)
            .set({'votes': votes}, SetOptions(merge: true));
      }
    } else if (PreferencesUpdate().getBool('votes_downloaded')) {
      var _vote = voteBox.get(postId);
      if (_vote == null ? true : _vote) {
        voteBox.put(postId, false);
      }
    }
  }
   
}