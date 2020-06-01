import 'package:blue/models/post_interaction.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
class PostInteractions{}
Map<String,PostInteraction> postInteractions = {};
 
   PostInteraction getById(String postId) {
    return postInteractions[postId];
  }
  // void setPostInteraction(
  //   String postId,
  //   String ownerId,
  //   bool upvoted,
  //   bool commented,
  //   bool saved,
  //   bool shared
  // ){
  //    postInteractions[postId] = PostInteraction( ownerId, upvoted, commented, saved, shared);
  // }
//}