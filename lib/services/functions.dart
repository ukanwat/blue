// Package imports:
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:intl/intl.dart';
// Project imports:
import 'package:blue/main.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/home.dart';
import 'boxes.dart';

class Functions{
  handleFollowUser(String profileId, ) async{//TODO Batch writes and prefer server side
       Boxes.followingBox.put(profileId, null);
    usersRef.doc(profileId).update({'followers': FieldValue.increment(1) },);
     usersRef.doc(currentUser.id).update({'following': FieldValue.increment(1) },);
 
   QuerySnapshot _followersDoc =  await followersRef
        .doc(profileId)
        .collection('userFollowers')
        .orderBy('order').limit(1).get();
        if(_followersDoc.docs.length == 0){
           followersRef
        .doc(profileId)
        .collection('userFollowers').doc().set({'order':1,'followers':[currentUser.id]});
        }else if((_followersDoc.docs.length == 1) && (_followersDoc.docs.first.data()['followers'].length>9999 )  ){
                          followersRef
        .doc(profileId)
        .collection('userFollowers').doc().set({'order':_followersDoc.docs.first.data()['order']+1,'followers':[currentUser.id]}); 
        }else{
             followersRef
        .doc(profileId)
        .collection('userFollowers').doc(_followersDoc.docs.first.id).update({'followers':FieldValue.arrayUnion([currentUser.id])}); 
        }
       QuerySnapshot  _followingDoc =  await followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .orderBy('order').limit(1).get();
         if(_followingDoc.docs.length == 0){
           followingRef
        .doc(profileId)
        .collection('userFollowing').doc().set({'order':1,'following':[profileId]});
        }else if((_followingDoc.docs.length == 1) && (_followingDoc.docs.first.data()['following'].length>9999 )  ){
                          followingRef
        .doc(profileId)
        .collection('userFollowing').doc().set({'order':_followingDoc.docs.first.data()['order']+1,'following':[profileId]}); 
        }else{
          _followingDoc.docs.first.reference.update({'following':FieldValue.arrayUnion([profileId])}); 
        }
    activityFeedRef
        .doc(profileId)
        .collection('feedItems')
        .doc(currentUser.id)
        .set({
      'type': 'follow',
      'ownerId': profileId,
      'username': currentUser.username,
      'userId': currentUser.id,
      'userProfileImg': currentUser.photoUrl,
      'timestamp': timestamp,
    });
    
  }

    handleUnfollowUser(String profileId)async {// TODO batch writes and prefer server side
   if( Boxes.followingBox.containsKey(profileId)){
      Boxes.followingBox.delete(profileId);
   }
   
   
      usersRef.doc(profileId).update({'followers': FieldValue.increment(-1) },);
      usersRef.doc(currentUser.id).update({'following': FieldValue.increment(-1) },);
      
     QuerySnapshot _followersDocs =  await followersRef
        .doc(profileId)
        .collection('userFollowers')
        .where('followers',arrayContains: currentUser.id).get();
         _followersDocs.docs.forEach((doc) {
           doc.reference.update({'followers': FieldValue.arrayRemove([currentUser.id])});
          });
      
     QuerySnapshot _followingDocs =  await followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .where('following',arrayContains: profileId).get();
         _followingDocs.docs.forEach((doc) {
           doc.reference.update({'following': FieldValue.arrayRemove([profileId])});
          });

   
  }
    unblockUser(Map peer)async{
        PreferencesUpdate()
                  .removeFromList('blocked_accounts', peer['peerId']);

           Hasura.deleteUserInfo(peer['peerId'], UserInfo.block);
    }
    blockUser(Map peer)async{
         Hasura.blockUser(peer['peerId']);
                    PreferencesUpdate()
                        .addToList('blocked_accounts', peer['peerId']);
    }
    muteUser(Map peer)async{

        PreferencesUpdate()
                  .addToList('muted_messages', peer['peerId']);
             Hasura.muteUser(peer['peerId']);
    }
    unmuteUser(Map peer)async{
      PreferencesUpdate()
                  .removeFromList('muted_messages', peer['peerId']);
            Hasura.deleteUserInfo(peer['peerId'], UserInfo.mute);
    }

      reportUser(Map peer,Report option) async {
         Hasura.reportUser(peer['peerId'],option);
    PreferencesUpdate()
        .addToList('reported_accounts_$option', peer['peerId']);
   
  }
launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
static String abbreviateNumber(int value,{bool hideZero}) {
  if(hideZero == true){
    if(value == 0|| value == null){
 return ' ';
    }
   
  }
   if (value > 999 && value < 99999) {
        return "${(value / 1000).toStringAsFixed(1)}K";
      } else if (value > 99999 && value < 999999) {
        return "${(value / 1000).toStringAsFixed(0)}K";
      } else if (value > 999999 && value < 999999999) {
        return "${(value / 1000000).toStringAsFixed(1)}M";
      } else if (value > 999999999) {
        return "${(value / 1000000000).toStringAsFixed(1)}B";
      } else {
        return value.toString();
      }
}
}
