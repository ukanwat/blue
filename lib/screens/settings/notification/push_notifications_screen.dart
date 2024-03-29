// Flutter imports:
import 'package:blue/services/functions.dart';
import 'package:flutter/material.dart';
import 'package:blue/constants/app_colors.dart';
// Package imports:

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/dialogs/empty_dialog.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:intl/intl.dart';

class PushNotificationsScreen extends StatefulWidget {
  static const routeName = 'push-notifications';
  @override
  _PushNotificationsScreenState createState() =>
      _PushNotificationsScreenState();
}

class _PushNotificationsScreenState extends State<PushNotificationsScreen> {
  bool upvotes = true;
  bool comments = true;
  bool commentReplies = true;
  bool newFollowers = true;
  bool directRequests = true;
  bool features = true;
  bool reminders = true;
  bool loading = true;
  DateTime allMuteTime;
  @override
  void initState() {
    getPushNotificationPreferences();
    super.initState();
  }

  getPushNotificationPreferences() async {
    String timeStr = PreferencesUpdate().getString('mute_push_time');

    setState(() {
      if (timeStr != null) {
        if (DateTime.parse(timeStr).isAfter(DateTime.now())) {
          upvotes = false;
          comments = false;
          commentReplies = false;
          newFollowers = false;
          directRequests = false;
          features = false;
          reminders = false;
          allMuteTime = DateTime.parse(timeStr);
        } else {
          reminders = PreferencesUpdate().getBool('push_features', def: true);
          features = PreferencesUpdate().getBool('push_reminders', def: true);
          directRequests =
              PreferencesUpdate().getBool('push_direct_requests', def: true);
          newFollowers =
              PreferencesUpdate().getBool('push_new_followers', def: true);
          commentReplies =
              PreferencesUpdate().getBool('push_reminders', def: true);
          comments = PreferencesUpdate().getBool('push_comments', def: true);
          upvotes = PreferencesUpdate().getBool('push_upvotes', def: true);
        }
      } else {
        reminders = PreferencesUpdate().getBool('push_features', def: true);
        features = PreferencesUpdate().getBool('push_reminders', def: true);
        directRequests =
            PreferencesUpdate().getBool('push_direct_requests', def: true);
        newFollowers =
            PreferencesUpdate().getBool('push_new_followers', def: true);
        commentReplies =
            PreferencesUpdate().getBool('push_reminders', def: true);
        comments = PreferencesUpdate().getBool('push_comments', def: true);
        upvotes = PreferencesUpdate().getBool('push_upvotes', def: true);
      }
      loading = false;
    });
  }

  disable() {
    setState(() {
      upvotes = false;
      comments = false;
      commentReplies = false;
      newFollowers = false;
      directRequests = false;
      features = false;
      reminders = false;
    });
  }

  saveNotifPref(
    String name,
    bool value,
  ) {
    PreferencesUpdate().updateBool(name, value, upload: true);
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
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return EmptyDialog(
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 10.0),
                                    Container(
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                      child: ClipRRect(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        child: Text(
                                          'Set Mute Time',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'Stark Sans',
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Theme.of(context).cardColor,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        DateTime now = DateTime.now();
                                        DateTime time = DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            now.hour + 1,
                                            now.minute,
                                            now.second,
                                            now.millisecond,
                                            now.microsecond);
                                        PreferencesUpdate().updateString(
                                            'mute_push_time', time.toString(),
                                            upload: true);
                                        Navigator.of(context).pop();
                                        disable();
                                      },
                                      child: Container(
                                        height: 40,
                                        width: double.infinity,
                                        margin:
                                            EdgeInsets.symmetric(vertical: 2),
                                        child: Center(
                                          child: Text(
                                            "1 Hour",
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Theme.of(context).cardColor,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        DateTime now = DateTime.now();
                                        DateTime time = DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            now.hour + 6,
                                            now.minute,
                                            now.second,
                                            now.millisecond,
                                            now.microsecond);
                                        PreferencesUpdate().updateString(
                                            'mute_push_time', time.toString(),
                                            upload: true);
                                        Navigator.of(context).pop();
                                        disable();
                                      },
                                      child: Container(
                                        height: 40,
                                        width: double.infinity,
                                        margin:
                                            EdgeInsets.symmetric(vertical: 2),
                                        child: Center(
                                          child: Text(
                                            "6 Hours",
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Theme.of(context).cardColor,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        DateTime now = DateTime.now();
                                        DateTime time = DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            now.hour + 12,
                                            now.minute,
                                            now.second,
                                            now.millisecond,
                                            now.microsecond);
                                        PreferencesUpdate().updateString(
                                            'mute_push_time', time.toString(),
                                            upload: true);
                                        Navigator.of(context).pop();
                                        disable();
                                      },
                                      child: Container(
                                        height: 40,
                                        width: double.infinity,
                                        margin:
                                            EdgeInsets.symmetric(vertical: 2),
                                        child: Center(
                                          child: Text(
                                            "12 Hours",
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Theme.of(context).cardColor,
                                    ),
                                    SizedBox(height: 10.0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: FlatButton(
                                        minWidth: double.maxFinite,
                                        color: Theme.of(context).cardColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // To close the dialog
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                noHorizontalPadding: true);
                          });
                    },
                    child: Text(
                      'Mute All Notifications', //TODO
                      style: TextStyle(color: Colors.white),
                    ),
                    disabledColor: AppColors.blue,
                    highlightColor: AppColors.blue,
                    color: AppColors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                if (allMuteTime != null)
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                        'All Notifications are muted till ${Functions().date(allMuteTime)}, ${DateFormat.jm().format(allMuteTime)}'),
                  )),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border(
                    bottom: BorderSide(
                        color:
                            Theme.of(context).iconTheme.color.withOpacity(0.16),
                        width: 1),
                  )),
                ),
                settingsSwitchListTile(
                  'Post info',
                  upvotes,
                  (newValue) {
                    saveNotifPref(
                      'push_upvotes',
                      newValue,
                    );
                    setState(() {
                      upvotes = newValue;
                    });
                  },
                ),
                settingsSwitchListTile('Comments', comments, (newValue) {
                  saveNotifPref(
                    'push_comments',
                    newValue,
                  );
                  setState(() {
                    comments = newValue;
                  });
                  saveNotifPref(
                    'push_comments',
                    newValue,
                  );
                }),
                settingsSwitchListTile('Comment Replies', commentReplies,
                    (newValue) {
                  saveNotifPref(
                    'push_comment_replies',
                    newValue,
                  );
                  setState(() {
                    commentReplies = newValue;
                  });
                }),
                settingsSwitchListTile('New Followers', newFollowers,
                    (newValue) {
                  saveNotifPref(
                    'push_new_followers',
                    newValue,
                  );
                  setState(() {
                    newFollowers = newValue;
                  });
                }),
                settingsSwitchListTile('Direct Requests', directRequests,
                    (newValue) {
                  saveNotifPref(
                    'push_direct_requests',
                    newValue,
                  );
                  setState(() {
                    directRequests = newValue;
                  });
                }),
                settingsSwitchListTile('New Feature Updates', features,
                    (newValue) {
                  saveNotifPref(
                    'push_features',
                    newValue,
                  );
                  setState(() {
                    features = newValue;
                  });
                }),
                settingsSwitchListTile('Notification Reminders', reminders,
                    (newValue) {
                  saveNotifPref(
                    'push_reminders',
                    newValue,
                  );
                  setState(() {
                    reminders = newValue;
                  });
                }),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border(
                    bottom: BorderSide(
                        color:
                            Theme.of(context).iconTheme.color.withOpacity(0.16),
                        width: 1),
                  )),
                ),
              ],
            ),
    );
  }
}
