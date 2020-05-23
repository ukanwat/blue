import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class EmailNotificationsScreen extends StatefulWidget {
  static const routeName = 'email-notifications';
  @override
  _EmailNotificationsScreenState createState() => _EmailNotificationsScreenState();
}

class _EmailNotificationsScreenState extends State<EmailNotificationsScreen> {
  bool feedbackEmailsEnabled =  true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Email Notifications'),
      body: ListView(
        children: <Widget>[
          settingsSwitchListTile('FeedBack Emails', feedbackEmailsEnabled , (){},description: 'Give Feedback on app',),
          settingsSwitchListTile('Announcement Emails',feedbackEmailsEnabled , (){},description:  'Get new update announcements',),
          settingsSwitchListTile('Activity Emails', feedbackEmailsEnabled , (){},description: 'Get Notifications related to your activity',)
        ],
      ),
    );
  }
}