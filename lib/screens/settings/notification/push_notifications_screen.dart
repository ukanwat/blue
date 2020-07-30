import 'package:blue/screens/home.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blue/main.dart';

class PushNotificationsScreen extends StatefulWidget {
  static const routeName = 'push-notifications';
  @override
  _PushNotificationsScreenState createState() =>
      _PushNotificationsScreenState();
}

class _PushNotificationsScreenState extends State<PushNotificationsScreen> {
   SharedPreferences preferences;
  bool likes = true;
  bool comments = true;
  bool commentReplies = true;
  bool newFollowers = true;
  bool directRequests = true;
  bool features = true;
  bool reminders = true;
  bool loading = true;
  @override
  void initState() {
    getPushNotificationPreferences();
    super.initState();
  }
  getPushNotificationPreferences()async{
 
 preferences =  await SharedPreferences.getInstance();

setState(() {
   likes = preferences.getBool('push_likes') != null?preferences.getBool('push_likes'): true  ;
 comments = preferences.getBool('push_comments') != null?preferences.getBool('push_comments'): true ;
 commentReplies = preferences.getBool('push_comment_replies')!= null?preferences.getBool('push__comment_replies'): true  ;
 newFollowers =preferences.getBool('push_new_followers')!= null?preferences.getBool('push_new_followers'): true  ;
 directRequests = preferences.getBool('push_direct_requests') != null?preferences.getBool('push_direct_requests'): true ;
 features = preferences.getBool('push_features')!= null?preferences.getBool('push_features'): true  ;
 reminders = preferences.getBool('push_reminders')!= null?preferences.getBool('push_reminders'): true  ;
 loading  = false;
});


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Push Notifications'),
      body: loading? circularProgress():ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            child: FlatButton(
              onPressed: null,
              child: Text(
                'Mute All Notifications', //TODO
                style: TextStyle(color: Colors.white),
              ),
              disabledColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
          ),
          settingsSwitchListTile(
            'Likes',
            likes,
            (newValue) {
              preferences.setBool('push_likes', newValue);
                            likes = newValue;
              preferencesRef.document(currentUser.id).setData({'push_likes': newValue},merge: true);
            },
          ),
          settingsSwitchListTile('Comments', comments, (newValue) {
               preferences.setBool('push_comments', newValue);
            comments = newValue;
             preferencesRef.document(currentUser.id).setData({'push_comments': newValue},merge: true);
          }),
          settingsSwitchListTile('Comment Replies', commentReplies, (newValue) {
               preferences.setBool('push_comment_replies', newValue);
            commentReplies = newValue;
             preferencesRef.document(currentUser.id).setData({'push_comment_replies': newValue},merge: true);
          }),
          settingsSwitchListTile('New Followers', newFollowers, (newValue) {
               preferences.setBool('push_new_followers', newValue);
            newFollowers = newValue;
             preferencesRef.document(currentUser.id).setData({'push_new_followers': newValue},merge: true);
          }),
          settingsSwitchListTile('Direct Requests', directRequests, (newValue) {
               preferences.setBool('push_direct_requests', newValue);
            directRequests = newValue;
             preferencesRef.document(currentUser.id).setData({'push_direct_requests': newValue},merge: true);
          }),
          settingsSwitchListTile('New Feature Updates', features, (newValue) {
               preferences.setBool('push_features', newValue);
            features = newValue;
             preferencesRef.document(currentUser.id).setData({'push_features': newValue},merge: true);
          }),
          settingsSwitchListTile('Notification Reminders', reminders,
              (newValue) {
                   preferences.setBool('push_reminders', newValue);
            reminders = newValue;
             preferencesRef.document(currentUser.id).setData({'push_reminders': newValue},merge: true);
          })
        ],
      ),
    );
  }
  
}
