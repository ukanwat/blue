// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/main.dart';
import '../screens/home.dart';

class Functions{
  handleFollowUser(String profileId, ) async{//TODO Batch writes and prefer server side
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
             followingRef
        .doc(profileId)
        .collection('userFollowing').doc(_followingDoc.docs.first.id).update({'following':FieldValue.arrayUnion([profileId])}); 
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

}
