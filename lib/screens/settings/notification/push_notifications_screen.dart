// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';

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

  getPushNotificationPreferences() async {
    setState(() {
      reminders = PreferencesUpdate().getBool('push_features',def: true);
      features = PreferencesUpdate().getBool('push_reminders',def: true);
      directRequests = PreferencesUpdate().getBool('push_direct_requests',def: true);
      newFollowers  = PreferencesUpdate().getBool('push_new_followers',def: true);
      commentReplies = PreferencesUpdate().getBool('push_reminders',def: true);
        comments = PreferencesUpdate().getBool('push_comments',def: true);
          likes = PreferencesUpdate().getBool('push_likes',def: true);
      loading = false;
    });
  }

       
       saveNotifPref(String name, bool value,){
                PreferencesUpdate().updateBool(name, value);
                  preferencesRef.doc(currentUser.id).set(
                      {name: value},
                      SetOptions(merge: true));
       }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Push Notifications'),
      body: loading
          ? circularProgress()
          : ListView(
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
                ),Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
                settingsSwitchListTile(
                  'Likes',
                  likes,
                  (newValue) {
                    saveNotifPref( 'push_likes', newValue,);
                    setState(() {
                      likes = newValue;
                    });
                  },
                ),
                settingsSwitchListTile('Comments', comments, (newValue) {
                   saveNotifPref( 'push_comments', newValue,);
                    setState(() {
                      likes = newValue;
                    });
                   saveNotifPref( 'push_comments', newValue,);
                }),
                settingsSwitchListTile('Comment Replies', commentReplies,
                    (newValue) {


                       saveNotifPref( 'push_comment_replies', newValue,);
                    setState(() {
                  commentReplies = newValue;
                    });
                 
                }),
                settingsSwitchListTile('New Followers', newFollowers,
                    (newValue) {
                           saveNotifPref( 'push_new_followers', newValue,);
                    setState(() {
                   newFollowers = newValue;
                    });
                 
                
                }),
                settingsSwitchListTile('Direct Requests', directRequests,
                    (newValue) {
                             saveNotifPref( 'push_direct_requests', newValue,);
                    setState(() {
                  directRequests = newValue;
                    });
                
                }),
                settingsSwitchListTile('New Feature Updates', features,
                    (newValue) {
                                saveNotifPref( 'push_features', newValue,);
                    setState(() {
               features = newValue;
                    });
            
                }),
                settingsSwitchListTile('Notification Reminders', reminders,
                    (newValue) {
                                      saveNotifPref( 'push_reminders', newValue,);
                    setState(() {
               reminders = newValue;
                    });
                }),Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
              ],
            ),
    );
  }
}
