// Package imports:
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'dart:math';
import 'package:intl/intl.dart';
// Project imports:
import 'package:blue/main.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/home.dart';
import 'boxes.dart';

class Functions{
  handleFollowUser(int profileId, ) async{
       Boxes.followingBox.put(profileId, DateTime.now().toString());
    Hasura.insertFollow(profileId);

    
  }

    handleUnfollowUser(int profileId)async {
   if( Boxes.followingBox.containsKey(profileId)){
      Boxes.followingBox.delete(profileId);
   }
     Hasura.deleteFollow(profileId);
 
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
