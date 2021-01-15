import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/boxes.dart';
import 'hasura.dart';
class PostFunctions{
 handleUpvoteButton(String postId,Vote vote) async {
   if(vote == Vote.none){
      await Hasura.insertPostVote(postId,true);

   }
else{
   await Hasura.deletePostVote(postId,true);
}
 
 
 return;

  }
   handleDownvoteButton(String postId,Vote vote) async {
        if(vote == Vote.none){
      await Hasura.insertPostVote(postId,false);

   }
else{
   await Hasura.deletePostVote(postId,false);
}
 

 
 return;
   }
   
}