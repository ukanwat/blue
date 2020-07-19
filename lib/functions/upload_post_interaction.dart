import 'package:blue/screens/home.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:blue/main.dart';
uploadPostInteraction(
  String postId,
  String ownerId,
  bool viewed,
 bool upvoted,
 bool commented,
 bool shared,
 bool saved,
){

    usersDatabase.child('${currentUser.id}').child('post-views').child('$postId').set({
      'postId': postId,
      'ownerId': ownerId,
      'viewed': true,
      'upvoted': upvoted,
      'commented': commented,
      'shared': shared,
      'saved': saved,
      'time': ServerValue.timestamp
    });

}