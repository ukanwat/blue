// Package imports:
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
                  .removeStringFromList('blocked_accounts', peer['peerId']);

              try {
               await userReportsRef.doc(currentUser.id).update({
                  'blocked': FieldValue.arrayRemove([peer['peerId']])
                });
              await  userReportsRef.doc(peer['peerId']).update({
                  'blockedBy': FieldValue.arrayRemove([currentUser.id])
                });
              } catch (e) {
// show toast or something
              }
    }
    blockUser(Map peer)async{
         var _userDoc =
                        await accountReportsRef.doc(currentUser.id).get();
                    var _peerDoc =
                        await accountReportsRef.doc(peer['peerId']).get();
                    if (_userDoc.data() == null||_userDoc.data() == {}) {
                      userReportsRef.doc(currentUser.id).set(
                        {
                          'blocked': [peer['peerId']]
                        },
                        SetOptions(merge: true)
                      );
                    } else if (_userDoc.data()['blocked'] == null) {
                      userReportsRef.doc(currentUser.id).set({
                        'blocked': [peer['peerId']]
                      }, SetOptions(merge: true));
                    } else {
                      userReportsRef.doc(currentUser.id).update(
                        {
                          'blocked': FieldValue.arrayUnion([peer['peerId']])
                        },
                      );
                    }
                        print(_peerDoc.data() );
                    if (_peerDoc.data() == null || _peerDoc.data().isEmpty ) {
                      userReportsRef.doc(peer['peerId']).set(
                        {
                          'blockedBy': [currentUser.id]
                        },
                      );
                    } else if (_peerDoc.data()['blockedBy'] == null) {
                      userReportsRef.doc(peer['peerId']).set({
                        'blockedBy': [currentUser.id]
                      }, SetOptions(merge: true));
                    } else {
                      userReportsRef.doc(peer['peerId']).update(
                        {
                          'blockedBy': FieldValue.arrayUnion([currentUser.id])
                        },
                      );
                    }
                    PreferencesUpdate()
                        .addStringToList('blocked_accounts', peer['peerId']);
    }
    muteUser(Map peer)async{
        PreferencesUpdate()
                  .addStringToList('muted_messages', peer['peerId']);
              var _userDoc = await userReportsRef.doc(currentUser.id).get();
              print('sdfffffffffffff');
              if(_userDoc != null)
              print(_userDoc.data());
               print('sdfffffffffffff');
              if (_userDoc.data() == null) {
                userReportsRef.doc(currentUser.id).set(
                  {
                    'muted': [peer['peerId']]
                  },
                );
              } else if (_userDoc.data()['muted'] == null) {
                userReportsRef.doc(currentUser.id).set({
                  'muted': [peer['peerId']]
                }, SetOptions(merge: true));
              } else {
                userReportsRef.doc(currentUser.id).update(
                  {
                    'muted': FieldValue.arrayUnion([peer['peerId']])
                  },
                );
              }
    }
    unmuteUser(Map peer)async{
      PreferencesUpdate()
                  .removeStringFromList('muted_messages', peer['peerId']);
              try {
                userReportsRef.doc(currentUser.id).update(
                  {
                    'muted': FieldValue.arrayRemove([peer['peerId']])
                  },
                );
             
              } catch (e) {
                //error TODO
              }
    }

      updateReportFirebase(Map peer,String option) async {
    PreferencesUpdate()
        .addStringToList('reported_accounts_$option', peer['peerId']);
    var _accountDoc = await accountReportsRef.doc(peer['peerId']).get();
    if (_accountDoc.data() != null) {
      accountReportsRef
          .doc(peer['peerId'])
          .update({'$option': FieldValue.increment(1)});
    } else {
      accountReportsRef.doc(peer['peerId']).set({'$option': 1});
    }
    var _userDoc = await userReportsRef.doc(currentUser.id).get();
    if (_userDoc.data() == null) {
      userReportsRef.doc(currentUser.id).set(
        {
          '$option': [peer['peerId']]
        },
      );
    } else if (_userDoc.data()['$option'] == null) {
      userReportsRef.doc(peer['$option']).set({
        '$option': [peer['peerId']]
      }, SetOptions(merge: true));
    } else {
      userReportsRef.doc(peer['peerId']).update(
        {
          '$option': FieldValue.arrayUnion([peer['peerId']])
        },
      );
    }
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
    if(value == 0){
 return ' ';
    }
   
  }
   if (value > 999 && value < 99999) {
        return "${(value / 1000).toStringAsFixed(1)} K";
      } else if (value > 99999 && value < 999999) {
        return "${(value / 1000).toStringAsFixed(0)} K";
      } else if (value > 999999 && value < 999999999) {
        return "${(value / 1000000).toStringAsFixed(1)} M";
      } else if (value > 999999999) {
        return "${(value / 1000000000).toStringAsFixed(1)} B";
      } else {
        return value.toString();
      }
}
}
