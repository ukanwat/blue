import 'package:blue/screens/settings/about/acknowledgements_screen.dart';
import 'package:blue/screens/settings/general/account_screen.dart';
import 'package:blue/screens/settings/advanced_settings/autoplay_screen.dart';
import 'package:blue/screens/settings/advanced_settings/content_cache_screen.dart';
import 'package:blue/screens/settings/advanced_settings/gestures_screen.dart';
import 'package:blue/screens/settings/feedback/give_a_suggestion_screen.dart';
import 'package:blue/screens/settings/feedback/report_a_bug_screen.dart';
import 'package:blue/screens/settings/general/collections_screen.dart';
import 'package:blue/screens/settings/general/drafts_screen.dart';
import 'package:blue/screens/settings/general/personalize_screen.dart';
import 'package:blue/screens/settings/notification/email_notifications_screen.dart';
import 'package:blue/screens/settings/notification/push_notifications_screen.dart';
import 'package:blue/screens/settings/notification/sound_screen.dart';
import 'package:blue/screens/settings/privacy/activity_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/settings_widgets.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = 'settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: settingsHeader(context, 'Settings'),
      body: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 5,
          ),
          settingsSectionTitle(
              icon: Icon(Icons.account_circle), title: 'General'),
          settingsPageNavigationTile(
              context, 'Account', AccountScreen.routeName),
          settingsPageNavigationTile(
              context, 'Personalize', PersonalizeScreen.routeName),
          settingsPageNavigationTile(
              context, 'Collection', CollectionsScreen.routeName),
          settingsPageNavigationTile(context, 'Drafts', DraftsScreen.routeName),
          settingsSectionTitle(
              icon: Icon(Icons.notifications_active), title: 'Notifications'),
          settingsPageNavigationTile(context, 'Email Notifications',
              EmailNotificationsScreen.routeName),
          settingsPageNavigationTile(
              context, 'Push Notifications', PushNotificationsScreen.routeName),
          settingsPageNavigationTile(context, 'Sound', SoundScreen.routeName),
          settingsSectionTitle(
            icon: Icon(Icons.category),
            title: 'Advanced Settings',
          ),
          settingsPageNavigationTile(
              context, 'Autoplay', AutoplayScreen.routeName),
          settingsPageNavigationTile(
              context, 'ContentCache', ContentCacheScreen.routeName),
          settingsPageNavigationTile(
              context, 'Gestures', GesturesScreen.routeName),
          settingsSectionTitle(
            icon: Icon(Icons.person_outline),
            title: 'Privacy',
          ),
          settingsPageNavigationTile(context, 'Safety', SafetyScreen.routeName),
          settingsPageNavigationTile(
              context, 'Activity', ActivityScreen.routeName),
          settingsSectionTitle(
            icon: Icon(Icons.feedback),
            title: 'Feedback',
          ),
          settingsPageNavigationTile(
              context, 'Give a Suggestion', GiveASuggestionScreen.routeName),
          settingsPageNavigationTile(
              context, 'Report a Bug', ReportABugScreen.routeName),
          settingsSectionTitle(
            icon: Icon(Icons.info_outline),
            title: 'About',
          ),
          settingsPageNavigationTile(context, 'Terms Of Service', AcknowledgementsScreen.routeName),
          settingsPageNavigationTile(context, 'Privacy Policy', AcknowledgementsScreen.routeName),
          settingsPageNavigationTile(
              context, 'Acknowledgements', AcknowledgementsScreen.routeName),
              Container(
                width: double.infinity,
                height: 40, child: Center(child: Text('Build v1.1')),)
        ],
      )),
    );
  }
}
