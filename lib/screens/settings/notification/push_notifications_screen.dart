import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class PushNotificationsScreen extends StatefulWidget {
  static const routeName = 'push-notifications';
  @override
  _PushNotificationsScreenState createState() =>
      _PushNotificationsScreenState();
}

class _PushNotificationsScreenState extends State<PushNotificationsScreen> {
  bool feedbackEmailsEnabled = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Push Notifications'),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            child: FlatButton(
              onPressed: null,
              child: Text(
                'Mute All Notifications',
                style: TextStyle(color: Colors.white),
              ),
              disabledColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
          ),
          settingsSwitchListTile(
            'Likes',
            feedbackEmailsEnabled,
            (newValue) {feedbackEmailsEnabled = newValue; },
          ),
          settingsSwitchListTile('Comments', feedbackEmailsEnabled, (newValue) {feedbackEmailsEnabled = newValue; }),
          settingsSwitchListTile(
              'Comment Replies', feedbackEmailsEnabled, (newValue) {feedbackEmailsEnabled = newValue; }),
          settingsSwitchListTile('New Followers', feedbackEmailsEnabled, (newValue) {feedbackEmailsEnabled = newValue; }),
          settingsSwitchListTile(
              'Direct Requests', feedbackEmailsEnabled, (newValue) {feedbackEmailsEnabled = newValue; }),
          settingsSwitchListTile(
              'New Feature Updates', feedbackEmailsEnabled, (newValue) {feedbackEmailsEnabled = newValue; }),
          settingsSwitchListTile(
              'Notification Reminders', feedbackEmailsEnabled,(newValue) {feedbackEmailsEnabled = newValue; })
        ],
      ),
    );
  }
}
