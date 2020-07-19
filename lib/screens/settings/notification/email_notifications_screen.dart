import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool activities = true;
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
      feedbacks = preferences.getBool('email_feedbacks') != null
          ? preferences.getBool('email_feedbacks')
          : true;
      announcements = preferences.getBool('email_announcements') != null
          ? preferences.getBool('email_announcements')
          : true;
      activities = preferences.getBool('email_activities') != null
          ? preferences.getBool('email_activities')
          : true;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Email Notifications'),
      body: loading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                settingsSwitchListTile(
                  'FeedBack Emails',
                  feedbacks,
                  (newValue) {
                     preferences.setBool('email_feedbacks', newValue);
                    feedbacks = activities;
                     preferencesRef.document(currentUser.id).setData({'email_feedbacks': newValue},merge: true);
                  },
                  description: 'Give Feedback on app',
                ),
                settingsSwitchListTile(
                  'Announcement Emails',
                  announcements,
                  (newValue) {
                     preferences.setBool('email_announcements', newValue);
                       announcements = activities;
                        preferencesRef.document(currentUser.id).setData({'email_announcements': newValue},merge: true);
                  },
                  description: 'Get new update announcements',
                ),
                settingsSwitchListTile(
                  'Activity Emails',
                  activities,
                  (newValue) {
                     preferences.setBool('email_activities', newValue);
                       activities = activities;
                        preferencesRef.document(currentUser.id).setData({'email_activities': newValue},merge: true);
                  },
                  description: 'Get Notifications related to your activity',
                )
              ],
            ),
    );
  }
}
