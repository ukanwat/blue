// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';
import '../../../main.dart';
import '../../home.dart';

class EmailNotificationsScreen extends StatefulWidget {
  static const routeName = 'email-notifications';
  @override
  _EmailNotificationsScreenState createState() =>
      _EmailNotificationsScreenState();
}

class _EmailNotificationsScreenState extends State<EmailNotificationsScreen> {
  bool feedbacks = true;
  bool announcements = true;
  // bool activities = true;
  SharedPreferences preferences;
  bool loading = true;
  @override
  void initState() {
    getPushNotificationPreferences();
    super.initState();
  }

  getPushNotificationPreferences() async {
    preferences = await SharedPreferences.getInstance();

    setState(() {
      feedbacks= PreferencesUpdate().getBool('email_feedbacks',def: true);
      announcements = PreferencesUpdate().getBool('email_announcements',def: true);
    
      // activities = preferences.getBool('email_activities') != null
      //     ? preferences.getBool('email_activities')
      //     : true;
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
    return Scaffold(backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Email Notifications'),
      body: loading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                settingsSwitchListTile(
                  'FeedBack Emails',
                  feedbacks,
                  (newValue) {
                      setState(() {
                   
                    feedbacks = newValue;
                         });
                          saveNotifPref('email_feedbacks',newValue);
                    
                  },
                  description: 'Give Feedback on app',
                ),Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
                settingsSwitchListTile(
                  'Announcement Emails',
                  announcements,
                  (newValue) {
                     setState(() {
                   
                  announcements = newValue;
                         });
                          saveNotifPref('email_announcements',newValue);
                 
                  },
                  description: 'Get new update announcements',
                ),Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
                // settingsSwitchListTile(
                //   'Activity Emails',
                //   activities,
                //   (newValue) {
                //      preferences.setBool('email_activities', newValue);
                //       setState(() {
                //        activities = newValue;
                //             });
                //         preferencesRef.doc(currentUser.id).set({'email_activities': newValue},SetOptions(merge: true));
                //   },
                //   description: 'Get Notifications related to your activity',
                // ),Container(width: double.infinity,decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).iconTheme.color.withOpacity(0.16),width: 1),)),),
              ],
            ),
    );
  }
}
